extends Node3D

func _input(event: InputEvent) -> void:
	print("receiving inputs")

func _unhandled_input(event: InputEvent) -> void:
	print("Receiving unhandled inputs")
