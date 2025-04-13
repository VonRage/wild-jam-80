extends Node

# -- Unit Scenes -- #
var attacker_unit = preload("res://Units/Scenes/attacker_unit.tscn")

func spawn_attacker_unit():
	var new_attacker_unit = attacker_unit.instantiate()
	var level = get_tree().root.get_child(1)
	var path_2d = level.find_child("Path")
	
	var path_follow = PathFollow2D.new()
	path_follow.rotates = false
	
	path_2d.add_child(path_follow)
	path_follow.add_child(new_attacker_unit)
	
	var start_mark = level.find_child("StartMark")
	if start_mark:
		path_follow.global_position = start_mark.global_position
		new_attacker_unit.path_follow = path_follow


func spawn_archer_unit():
	pass

func spawn_healer_unit():
	pass
