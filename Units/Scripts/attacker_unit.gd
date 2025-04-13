extends Node2D

@export var movement_speed : float = 50.0
@export var damage : int = 1
@export var health : int = 5

@onready var attack_timer: Timer = $AttackTimer
@onready var health_label: Label = $HealthLabel # TEMP
@onready var hit_timer: Timer = $HitTimer

var path_follow : PathFollow2D

var tower 

var at_tower : bool = false
var can_attack : bool = true

func _physics_process(delta: float) -> void:
	health_label.text = str(health)
	
	if path_follow == null: # If unit doesn't have path return
		return
	
	if tower:
		if tower.is_destroyed:
			at_tower = false
			tower = null
	
	if not at_tower:
		path_follow.progress += delta * movement_speed
	else:
		if attack_timer.is_stopped():
			attack_timer.start() # Only start timer if its hasn't started yet
		
		if can_attack:
			attack()

func attack():
	if tower == null:
		return
	tower.take_damage(damage)
	
	# Attack cooldown
	can_attack = false
	attack_timer.start()
	

func take_damage(damage_taken: int):
	health -= damage_taken
	$Sprite2D.modulate = Color(1, 0, 0, 1) # Make color red
	hit_timer.start()

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Tower"):
		at_tower = true # Stop unit when it comes close to a tower to attack
		tower = area.get_parent().get_parent() # Get tower reference
	
	if area.is_in_group("Projectiles"):
		take_damage(area.get_parent().damage)
		area.get_parent().queue_free() # Destory projectile after hit


func _on_hit_box_area_exited(area: Area2D) -> void:
	if area.is_in_group("Tower"):
		at_tower = false # Move after destorying tower
		tower = null


func _on_attack_timer_timeout() -> void:
	can_attack = true


func _on_hit_timer_timeout() -> void:
	$Sprite2D.modulate = Color(1, 1, 1, 1) # Reset color to normal
