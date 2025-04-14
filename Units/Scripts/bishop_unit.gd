extends CharacterBody2D
class_name Healer

@export_group("Stats")
@export var movement_speed: float
@export var damage: float
@export var health: float
@export var healing_power: float

@onready var heal_timer: Timer = $HealTimer
@onready var health_label: Label = $HealthLabel
@onready var hit_timer: Timer = $HitTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

var target: Node2D = null

var pieces_to_heal: Array = []

func _ready() -> void:
	call_deferred("navigation_agent_setup")
	find_wounded_unit()

func _physics_process(delta: float) -> void:
	health_label.text = str(health)
	if health <= 0:
		queue_free()
		return
	
	if target == null or not is_instance_valid(target):
		target = null
		find_wounded_unit()
	
	# Healing logic
	if pieces_to_heal.is_empty():
		find_wounded_unit()
		navigation_agent_pathfinding(delta)
		animated_sprite_2d.play("Walking")
	else:
		find_wounded_unit()
		velocity = Vector2.ZERO
		animated_sprite_2d.play("Heal")
		if heal_timer.is_stopped():
			heal_timer.start()
	
	move_and_slide()

func find_wounded_unit():
	var closest_dist = INF
	var closest_piece = null
	
	for piece in get_tree().get_nodes_in_group("Unit"):
		if not piece.get_parent().is_in_group("Healer"):
			if piece != null:
				var dist = global_position.distance_to(piece.global_position)
				if dist < closest_dist:
					closest_dist = -dist
					closest_piece = piece
	
	if closest_piece:
		target = closest_piece.get_parent()
	else:
		var end_mark = get_tree().root.get_child(1).find_child("EndMark")
		if end_mark:
			target = end_mark

func navigation_agent_setup():
	await get_tree().physics_frame
	if target:
		navigation_agent_2d.target_position = target.global_position

func navigation_agent_pathfinding(delta: float) -> void:
	if target:
		navigation_agent_2d.target_position = target.global_position
	
	if navigation_agent_2d.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	
	var next_path_position = navigation_agent_2d.get_next_path_position()
	var direction = (next_path_position - global_position).normalized()
	var new_velocity = direction * movement_speed * delta
	
	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func take_damage(damage_taken: int):
	health -= damage_taken
	animated_sprite_2d.modulate = Color(1, 0, 0, 1)
	hit_timer.start()

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Projectiles"):
		take_damage(area.get_parent().damage)
		area.get_parent().queue_free()

func _on_hit_box_area_exited(_area: Area2D) -> void:
	pass

func _on_hit_timer_timeout() -> void:
	animated_sprite_2d.modulate = Color(1, 1, 1, 1)

func _on_healing_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("CanBeHealed"):
		if area.get_parent() != self:
			pieces_to_heal.append(area.get_parent())
		target = null
		find_wounded_unit()

func _on_healing_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("CanBeHealed"):
		pieces_to_heal.erase(area.get_parent())
		target = null
		find_wounded_unit()

func _on_heal_timer_timeout() -> void:
	if pieces_to_heal.is_empty():
		return
	
	var lowest_health_piece = pieces_to_heal[0]
	for piece in pieces_to_heal:
		if piece.health < lowest_health_piece.health:
			lowest_health_piece = piece
	
	lowest_health_piece.heal(healing_power)
