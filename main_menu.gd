extends Control



func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Scenes/level_1.tscn") # Change this later with a transition


func _on_credits_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()
