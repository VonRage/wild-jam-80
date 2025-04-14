extends CharacterBody2D

@export_group("Stats")
@export var movement_speed: float 
@export var damage: float
@export var health: float 
@export var max_health: float 

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_timer: Timer = $HitTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_label: Label = $HealthLabel
@onready var attack_timer: Timer = $AttackTimer

const ATTACK_RANGE: float = 16.0 

var target: Node2D = null
var targets_in_range: Array[Node2D] = []

var stop_moving: bool = false
var is_attacking: bool = false
var piece_in_range: bool = false

func _ready() -> void:
	call_deferred("find_target")

func _physics_process(delta: float) -> void:
	health_label.text = str(health)
	
	if health <= 0:
		queue_free()
		return
	
	if target and not is_instance_valid(target):
		target = null
	
	if target == null:
		find_target()
		stop_moving = false
		return
	
	var distance_to_target = global_position.distance_to(target.global_position)
	piece_in_range = distance_to_target <= ATTACK_RANGE or target in targets_in_range
	
	if piece_in_range:
		stop_moving = true
		velocity = Vector2.ZERO
		navigation_agent_2d.target_position = global_position
		if not is_attacking:
			attack()
	else:
		stop_moving = false
	
	if not stop_moving:
		navigation_agent_pathfinding(delta)
		animated_sprite_2d.play("Walking")
	
	move_and_slide()

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

func find_target():
	var closest_piece = null
	var closest_distance = INF
	
	for piece in get_tree().get_nodes_in_group("Unit"):
		var unit = piece.get_parent() 
		var distance = global_position.distance_to(unit.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_piece = unit
	
	if closest_piece:
		target = closest_piece
		navigation_agent_2d.target_position = target.global_position

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func attack():
	if target == null:
		return
	
	is_attacking = true
	animated_sprite_2d.play("Attacking")
	
	if target.global_position.x < global_position.x:
		animation_player.play("AttackAnimationLeft")
	else:
		animation_player.play("AttackAnimationRight")

func take_damage(damage_taken: int):
	health -= damage_taken
	animated_sprite_2d.modulate = Color(1, 0, 0, 1)
	hit_timer.start()

func deal_attack_damage():
	if target and is_instance_valid(target):
		if target.is_in_group("EnemyUnit"):
			target.take_damage(damage)

func _on_detection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Unit"):
		var unit = area.get_parent()
		if unit not in targets_in_range:
			targets_in_range.append(unit)
		
		if target == null:
			target = unit
		piece_in_range = true

func _on_detection_area_area_exited(area: Area2D) -> void:
	var unit = area.get_parent()
	if unit in targets_in_range:
		targets_in_range.erase(unit)
	
	if unit == target:
		target = null
	
	piece_in_range = not targets_in_range.is_empty()
	
	if target == null and not targets_in_range.is_empty():
		target = targets_in_range[0]

func _on_hit_timer_timeout() -> void:
	animated_sprite_2d.modulate = Color(1, 1, 1, 1)

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "AttackAnimationLeft" or anim_name == "AttackAnimationRight":
		if target and is_instance_valid(target):
			target.take_damage(damage)
			if target.health <= 0:
				targets_in_range.erase(target)
				target = null
		
		is_attacking = false
		stop_moving = false
		
		if not targets_in_range.is_empty():
			target = targets_in_range[0]
			piece_in_range = true
			attack_timer.start()
		else:
			piece_in_range = false

func _on_attack_timer_timeout() -> void:
	attack()
