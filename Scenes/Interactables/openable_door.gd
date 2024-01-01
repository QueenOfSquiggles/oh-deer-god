extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer
@export var is_open := false

func _on_interact_area_3d_on_interacted() -> void:
	if anim.is_playing():
		return
	var anim_name := "close" if is_open else "open"
	anim.play(anim_name)


func _on_interact_area_3d_body_entered(body: Node3D) -> void:
	if anim.is_playing():
		return
	if body.is_in_group("player") and not is_open:
		anim.play("open") # auto-open if player walks to door
