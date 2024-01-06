extends Node3D
@onready var anim: AnimationPlayer = $AnimationPlayer

func play_death_anim() -> void:
	anim.play(&"DeathAnim")

func play_rise_from_death_anim() -> void:
	anim.play(&"rise_from_death")

func play_talking_anim() -> void:
	anim.play(&"Talking")

func play_idle_anim() -> void:
	anim.play(&"Idle")
