extends Label

func _ready() -> void:
	GameManager.request_interact_label.connect(_set_label)
	text = ""

func _set_label(label : String) -> void:
	text = label
