extends StaticBody3D

@export var hp := 10
@onready var label = $Label3D

func _ready():
	_on_hp_changed() # updates relevate data

func damage() -> void:
	hp -= 1
	_on_hp_changed()

func _on_hp_changed() -> void:
	label.text = "{0} HP".format([hp])
	if hp < 0:
		queue_free()
