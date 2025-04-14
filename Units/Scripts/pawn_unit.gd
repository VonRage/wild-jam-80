extends CharacterBody2D

@export_group("Stats")
@export var movement_speed: float
@export var damage: float
@export var health: float 
@export var max_health: float 

@onready var attack_timer: Timer = $AttackTimer
@onready var health_label: Label = $HealthLabel
@onready var hit_timer: Timer = $HitTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var tower: Node = null
var target: Node2D = null
var at_tower: bool = false
var can_attack: bool = true

func _ready() -> void:
	call_deferred("navigation_agent_setup")
	find_target_tower()

func _physics_process(delta: float) -> void:
	health_label.text = str(health)
	
	if health <= 0:
		queue_free()
		return
	
	if tower and tower.is_destroyed:
		at_tower = false
		tower = null
		target = null
	
	if target == null:
		find_target_tower()
	
	if not at_tower:
		navigation_agent_pathfinding(delta)
		animated_sprite_2d.play("Walking")
	else:
		velocity = Vector2.ZERO
		if attack_timer.is_stopped():
			attack_timer.start()
		if can_attack:
			attack()
	
	move_and_slide()

func find_target_tower():
	var closest_dist = INF
	var closest_tower = null
	
	for tower_candidate in Global.towers_left:
		var tower_node = tower_candidate
		if not tower_node.is_destroyed:
			var dist = global_position.distance_to(tower_node.global_position)
			if dist < closest_dist:
				closest_dist = -dist
				closest_tower = tower_node
	
	if closest_tower:
		target = closest_tower
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

func deal_attack_damage():
	if target and is_instance_valid(target):
		if tower:
			tower.take_damage(damage)

func attack():
	if tower == null:
		return
	
	animated_sprite_2d.play("Attacking")
	
	if target.global_position.x < global_position.x:
		animation_player.play("AttackAnimationLeft")
	else:
		animation_player.play("AttackAnimationRight")
	
	can_attack = false

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "AttackAnimationLeft" or anim_name == "AttackAnimationRight":
		if target and is_instance_valid(target):
			if target == tower:
				attack_timer.start()

func take_damage(damage_taken: int):
	health -= damage_taken
	animated_sprite_2d.modulate = Color(1, 0, 0, 1)
	hit_timer.start()

func heal(heal_power: int):
	health += heal_power
	if health > max_health:
		health = max_health

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Tower"):
		at_tower = true
		tower = area.get_parent()
	
	if area.is_in_group("Projectiles"):
		take_damage(area.get_parent().damage)
		area.get_parent().queue_free()

func _on_hit_box_area_exited(area: Area2D) -> void:
	if area.is_in_group("Tower"):
		at_tower = false
		tower = null

func _on_attack_timer_timeout() -> void:
	can_attack = true

func _on_hit_timer_timeout() -> void:
	animated_sprite_2d.modulate = Color(1, 1, 1, 1)
