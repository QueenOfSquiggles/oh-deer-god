extends Control

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_gui"):
		visible = not visible
