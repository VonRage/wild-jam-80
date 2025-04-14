extends Node

# -- Unit Scenes -- #
var pawn_unit: PackedScene = preload("res://Units/Scenes/pawn_unit.tscn")
var rook_unit: PackedScene = preload("res://Units/Scenes/rook_unit.tscn")
var bishop_unit: PackedScene = preload("res://Units/Scenes/bishop_unit.tscn")
var knight_unit: PackedScene = preload("res://Units/Scenes/knight_unit.tscn")
var queen_unit: PackedScene = preload("res://Units/Scenes/queen_unit.tscn")

var towers_left: Array = []

var pawn_cost: int = 25
var rook_cost: int = 45
var bishop_cost: int = 35
var knight_cost: int = 35
var queen_cost: int = 50

func spawn_pawn_unit():
	var new_pawn_unit = pawn_unit.instantiate()
	var level = get_tree().root.get_child(1)
	var units = level.find_child("Units")
	
	units.add_child(new_pawn_unit)
	
	var start_mark = level.find_child("StartMark")
	if start_mark:
		new_pawn_unit.global_position = start_mark.global_position

func spawn_rook_unit():
	var new_rook_unit = rook_unit.instantiate()
	var level = get_tree().root.get_child(1)
	var units = level.find_child("Units")
	
	units.add_child(new_rook_unit)
	
	var start_mark = level.find_child("StartMark")
	if start_mark:
		new_rook_unit.global_position = start_mark.global_position

func spawn_bishop_unit():
	var new_bishop_unit = bishop_unit.instantiate()
	var level = get_tree().root.get_child(1)
	var units = level.find_child("Units")
	
	units.add_child(new_bishop_unit)
	
	var start_mark = level.find_child("StartMark")
	if start_mark:
		new_bishop_unit.global_position = start_mark.global_position

func spawn_knight_unit():
	var new_knight_unit = knight_unit.instantiate()
	var level = get_tree().root.get_child(1)
	var units = level.find_child("Units")
	
	units.add_child(new_knight_unit)
	
	var start_mark = level.find_child("StartMark")
	if start_mark:
		new_knight_unit.global_position = start_mark.global_position

func spawn_queen_unit():
	var new_queen_unit = queen_unit.instantiate()
	var level = get_tree().root.get_child(1)
	var units = level.find_child("Units")
	
	units.add_child(new_queen_unit)
	
	var start_mark = level.find_child("StartMark")
	if start_mark:
		new_queen_unit.global_position = start_mark.global_position
