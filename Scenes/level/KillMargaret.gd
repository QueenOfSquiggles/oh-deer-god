extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	GameManager.cutscene_kill_margaret.connect(_start)

func _start() -> void:
	GameManager.request_player_can_move.emit(false)
	anim.play("cutscene")


func _end() -> void:
	GameManager.trigger_dialog_track("story_09_furfur_rises")

