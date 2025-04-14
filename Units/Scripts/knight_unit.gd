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

var target: Node2D = null
var can_attack: bool = true

func _ready() -> void:
	call_deferred("navigation_agent_setup")
	find_target_enemy()

func _physics_process(delta: float) -> void:
	health_label.text = str(health)
	if health <= 0:
		queue_free()
		return
	
	if target and target.is_in_group("EnemyUnit") and is_instance_valid(target):
		var distance = global_position.distance_to(target.global_position)
		if distance <= 8.0:
			velocity = Vector2.ZERO
			navigation_agent_2d.target_position = global_position
			if can_attack:
				attack_enemy()
		else:
			navigation_agent_pathfinding(delta)
			animated_sprite_2d.play("Walking")
		move_and_slide()
		return
	
	if target == null:
		animated_sprite_2d.play("Attacking") # Attacking is basicly idle if your not using the animation player alongside it
		find_target_enemy()
	
	navigation_agent_pathfinding(delta)
	animated_sprite_2d.play("Attacking")
	move_and_slide()

func find_target_enemy():
	var closest_dist = INF
	var closest_enemy = null
	
	for enemy in get_tree().get_nodes_in_group("EnemyUnit"):
		var enemy_node = enemy
		if is_instance_valid(enemy_node):
			var dist = global_position.distance_to(enemy_node.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_enemy = enemy_node
	
	if closest_enemy:
		target = closest_enemy

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

func attack_enemy():
	if target == null or not is_instance_valid(target):
		return
	
	can_attack = false
	animated_sprite_2d.play("Attacking")
	
	if target.global_position.x < global_position.x:
		animation_player.play("AttackAnimationLeft")
	else:
		animation_player.play("AttackAnimationRight")

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "AttackAnimationLeft" or anim_name == "AttackAnimationRight":
		if target and is_instance_valid(target):
			if target.is_in_group("EnemyUnit"):
				animated_sprite_2d.play("Attacking")
				attack_timer.start()

func deal_attack_damage():
	if target and is_instance_valid(target):
		if target.is_in_group("EnemyUnit"):
			target.take_damage(damage)

func take_damage(damage_taken: int):
	health -= damage_taken
	animated_sprite_2d.modulate = Color(1, 0, 0, 1)
	hit_timer.start()

func heal(heal_power: int):
	health += heal_power
	if health > max_health:
		health = max_health

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Projectiles"):
		take_damage(area.get_parent().damage)
		area.get_parent().queue_free()

func _on_hit_box_area_exited(_area: Area2D) -> void:
	# No need to track towers for the knight
	pass

func _on_attack_timer_timeout() -> void:
	if target == null:
		return
	if target.is_in_group("EnemyUnit"):
		attack_enemy()
		return
	can_attack = true

func _on_hit_timer_timeout() -> void:
	animated_sprite_2d.modulate = Color(1, 1, 1, 1)

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("EnemyUnit"):
		target = body
		velocity = Vector2.ZERO
		navigation_agent_2d.target_position = global_position
		if can_attack:
			attack_enemy()

func _on_hit_box_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
