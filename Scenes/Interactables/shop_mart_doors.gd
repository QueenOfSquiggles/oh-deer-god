extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer
@export var is_open := false
@export var close_timer := 15.0

var timer : SceneTreeTimer

func _on_interaction_object_area_3d_on_interacted() -> void:
	if is_open or anim.is_playing():
		return
	anim.play("open")

func _on_interaction_object_area_3d_body_entered(body: Node3D) -> void:
	if anim.is_playing() or is_open:
		return
	if body.is_in_group("player"):
		anim.play("open") # auto-open if player walks to door

func _try_close() -> void:
	if not timer:
		timer = get_tree().create_timer(close_timer)
		timer.timeout.connect(Callable(anim, "play").bind("close"))
	timer.time_left = close_timer
