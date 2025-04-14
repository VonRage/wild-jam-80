extends Camera2D

@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 4.0
@export var pan_speed: float = 1.0

var is_panning: bool = false
var last_mouse_position: Vector2

func _input(event: InputEvent) -> void:
	# Zoom with scroll wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom *= 1.0 - zoom_step
			zoom = zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
		
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom *= 1.0 + zoom_step
			zoom = zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
		
		# Start/stop panning
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = event.pressed
			if is_panning:
				last_mouse_position = get_viewport().get_mouse_position()
	
	elif event is InputEventMouseMotion and is_panning:
		var mouse_pos = get_viewport().get_mouse_position()
		var delta = mouse_pos - last_mouse_position
		position -= delta * zoom * pan_speed
		last_mouse_position = mouse_pos
