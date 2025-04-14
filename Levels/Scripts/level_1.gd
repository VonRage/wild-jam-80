extends Node2D

@export var coins: int = 500

@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var win_screen: Control = $CanvasLayer/UI/WinScreen

var tiles_variants: Array[Vector2i] = [Vector2i(5, 1), Vector2i(1, 1), Vector2i(0, 6), # First is the green tile
	Vector2i(1, 6), Vector2i(0, 7), Vector2i(1, 7)] # Decro tiles 

func _ready() -> void:
	for tower in $Towers.get_children():
		Global.towers_left.append(tower)
	
	randomize_tiles()

func _process(_delta: float) -> void:
	$CanvasLayer/UI/Coins.text = str(coins)

func randomize_tiles(): # Alesart request 
	# -- Needs more work -- #
	var used_cells = tile_map.get_used_cells()
	var main_tile = tiles_variants[0]
	var other_tiles = tiles_variants.slice(1)
	
	for cell in used_cells:
		if tile_map.get_cell_atlas_coords(cell) == main_tile:
			if randf() <= 0.99: # 5% chance to make a green tile a decro tile
				tile_map.set_cell(cell, 2, main_tile)
			else:
				tile_map.set_cell(cell, 2, other_tiles.pick_random())

func _on_spawn_pawn_pressed() -> void:
	if coins >= Global.pawn_cost:
		Global.spawn_pawn_unit()
		coins -= Global.pawn_cost

func _on_spawn_rook_pressed() -> void:
	if coins >= Global.rook_cost:
		Global.spawn_rook_unit()
		coins -= Global.rook_cost

func _on_spawn_bishop_pressed() -> void:
	if coins >= Global.bishop_cost:
		Global.spawn_bishop_unit()
		coins -= Global.bishop_cost

func _on_spawn_knight_pressed() -> void:
	if coins >= Global.knight_cost:
		Global.spawn_knight_unit()
		coins -= Global.knight_cost

func _on_spawn_queen_pressed() -> void:
	if coins >= Global.queen_cost:
		Global.spawn_queen_unit()
		coins -= Global.queen_cost

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Unit"):
		win_screen.show()
		get_tree().paused = true

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
