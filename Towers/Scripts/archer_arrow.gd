extends Node2D

var user # Owner of the arrow

var direction : Vector2

var speed : float = 20.0

var damage : int = 1

func _process(_delta: float) -> void:
	global_position += direction * speed
