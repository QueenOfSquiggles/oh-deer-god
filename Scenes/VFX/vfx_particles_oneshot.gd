extends GPUParticles3D


func _ready():
	emitting = true
	one_shot = true
	var tween := create_tween()
	tween.tween_interval(lifetime * 1.2) # buffer space for some variation
	tween.tween_callback(Callable(self, "queue_free"))
