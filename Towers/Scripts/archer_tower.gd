extends Node2D

@export var health: float 

@onready var health_label : Label = $HealthLabel
@onready var hit_timer : Timer = $HitTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var queen : AnimatedSprite2D = $EnemyQueen
@onready var lower_part: Sprite2D = $LowerPart
@onready var upper_part: Sprite2D = $UpperPart
@onready var spawn_timer: Timer = $SpawnTimer

var arrow = preload("res://Towers/Scenes/archer_arrow.tscn")

var enemy 

var is_destroyed: bool = false
var enemy_in_range: bool = false
var can_attack: bool = false

func _ready() -> void:
	tween_queen_movement()
	spawn_timer.wait_time = randf_range(15.0, 20.0) # Spawn a troop every 15 to 20 secs
	spawn_timer.start()

func _process(_delta: float) -> void:
	if is_destroyed:
		Global.towers_left.erase(self) # Erase tower from tower_left 
		queen.hide()
		lower_part.modulate = Color(0, 0, 0, 1) # Make it black just for now, because we dont have a destory animtion yet
		upper_part.modulate = Color(0, 0, 0, 1)
		
		for piece in get_tree().get_nodes_in_group("Unit"):
			if piece.has_method("find_target_tower"):
				piece.find_target_tower() # Reset every pieces' target
		
		set_process(false) # Stop processing if tower is destroyed
		return
	
	health_label.text = str(health) # Update health for debugging
	
	if enemy_in_range:
		if attack_timer.is_stopped():
			attack_timer.start() # Only start timer if its hasn't started yet
		
		if can_attack:
			attack()
	
	if health <= 0:
		is_destroyed = true

func spawn_troop():
	var new_pawn_unit = preload("res://Units/Scenes/Enemy/enemy_pawn_unit.tscn").instantiate()
	var level = get_tree().root.get_child(1)
	var units = level.find_child("EnemyUnits")
	
	units.add_child(new_pawn_unit)
	
	new_pawn_unit.global_position = $SpawnTroops.global_position

func tween_queen_movement() -> void:
	# Simple animation movement for the enemy queen
	# Move from left to right in a loop
	queen.play("Walking")
	
	
	while true:
		var tween = create_tween()
		tween.tween_property(queen, "position", Vector2(15.0, -20.0), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
	
		tween = create_tween()
		tween.tween_property(queen, "position", Vector2(-15.0, -20.0), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await tween.finished

func attack():
	if enemy == null:
		return
	
	var new_arrow = arrow.instantiate()
	var level = get_tree().root.get_child(1)
	
	level.find_child("Projectiles").add_child(new_arrow)
	new_arrow.global_position = $EnemyQueen/ShootPosition.global_position
	new_arrow.direction = (enemy.global_position - $EnemyQueen/ShootPosition.global_position).normalized()
	new_arrow.rotation = new_arrow.direction.angle() + PI / 2
	new_arrow.user = "enemy"
	
	# Attack cooldown
	can_attack = false
	attack_timer.start()

func take_damage(damage: int):
	health -= damage
	lower_part.modulate = Color(1, 0, 0, 1) # Make color red
	upper_part.modulate = Color(1, 0, 0, 1) # Make color red
	hit_timer.start()

func _on_hit_timer_timeout() -> void:
	lower_part.modulate = Color(1, 1, 1, 1) # Reset color to normal
	upper_part.modulate = Color(1, 1, 1, 1) # Reset color to normal

func _on_dectection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Unit"):
		enemy_in_range = true
		enemy = area.get_parent()

func _on_dectection_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("Unit"):
		enemy_in_range = false
		enemy = null

func _on_attack_timer_timeout() -> void:
	can_attack = true

func _on_spawn_timer_timeout() -> void:
	if is_destroyed:
		return
	spawn_troop()
	
	# RESET
	spawn_timer.wait_time = randf_range(15.0, 20.0) # Assign new random spawn time
	spawn_timer.start() # Start the timer

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Projectiles") and area.get_parent().user == "Player":
		take_damage(area.get_parent().damage)
		area.get_parent().queue_free()
