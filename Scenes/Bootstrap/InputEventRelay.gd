extends SubViewportContainer

@onready var sub_viewport: SubViewport = $SubViewport

func _input(event: InputEvent) -> void:
	sub_viewport.push_input(event)

#func _unhandled_input(event: InputEvent) -> void:
	#sub_viewport.push_unhandled_input(event)
