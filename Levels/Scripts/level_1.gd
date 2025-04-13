extends Node2D

@export var coins : int = 500

@onready var win_screen: Control = $UI/WinScreen

var attacker_cost : int = 25

func _process(_delta: float) -> void:
	$UI/Coins.text = str(coins)

func _on_spawn_attackers_pressed() -> void:
	if coins >= attacker_cost:
		Global.spawn_attacker_unit()
		coins -= attacker_cost
	


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Unit"):
		win_screen.show()
		get_tree().paused = true


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
