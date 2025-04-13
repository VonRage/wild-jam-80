extends Node2D

@export var health : int = 10

@onready var health_label : Label = $HealthLabel
@onready var archer: Node2D = $Archer
@onready var hit_timer : Timer = $HitTimer
@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer

var arrow = preload("res://Towers/Scenes/archer_arrow.tscn")

var enemy 

var is_destroyed : bool = false
var enemy_in_range : bool = false
var can_attack : bool = false

func _process(_delta: float) -> void:
	if is_destroyed:
		return
	
	health_label.text = str(health) # Update health for debugging
	
	if enemy_in_range:
		if attack_timer.is_stopped():
			attack_timer.start() # Only start timer if its hasn't started yet
		
		if can_attack:
			attack()
	
	if health <= 0:
		is_destroyed = true
		destory()

func attack():
	if enemy == null:
		print("enemy null")
		return
	
	var new_arrow = arrow.instantiate()
	var level = get_tree().root.get_child(1)
	
	level.find_child("Projectiles").add_child(new_arrow)
	new_arrow.global_position = $ShootPosition.global_position
	new_arrow.direction = (enemy.global_position - $ShootPosition.global_position).normalized()
	new_arrow.rotation = new_arrow.direction.angle() + PI / 2
	
	# Attack cooldown
	can_attack = false
	attack_timer.start()
	

func destory():
	archer.hide()
	animated_sprite_2d.play("Destory_1")
	animated_sprite_2d.connect("animation_looped", destory_animation_finished)

func take_damage(damage: int):
	health -= damage
	animated_sprite_2d.modulate = Color(1, 0, 0, 1) # Make color red
	hit_timer.start()

func _on_hit_timer_timeout() -> void:
	animated_sprite_2d.modulate = Color(1, 1, 1, 1) # Reset color to normal

func destory_animation_finished():
	animated_sprite_2d.stop()
	animated_sprite_2d.frame = 3

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
