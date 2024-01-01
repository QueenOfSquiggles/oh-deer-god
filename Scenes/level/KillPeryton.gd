extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	GameManager.cutscene_kill_peryton.connect(_start)

func _start() -> void:
	GameManager.request_player_can_move.emit(false)
	anim.play("cutscene")


func _end() -> void:
	push_error("This should open a game over card")

