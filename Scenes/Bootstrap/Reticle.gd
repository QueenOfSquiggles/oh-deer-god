extends TextureRect

@export var texture_normal : Texture2D
@export var texture_aiming : Texture2D
@export var bump_scale := 1.2
var tween : Tween
var base_scale := Vector2()

func _ready() -> void:
	GameManager.update_reticle_mode.connect(_update_reticle)
	GameManager.request_interact_label.connect(_bump_reticle)
	base_scale = scale

func _bump_reticle(text : String) -> void:
	if text == "":
		return
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", base_scale * bump_scale, 0.1)
	tween.tween_property(self, "scale", base_scale, 0.3)


func _update_reticle(mode : GameManager.ReticleMode) -> void:
	match mode:
		GameManager.ReticleMode.HIDDEN:
			texture = null
		GameManager.ReticleMode.INTERACT:
			texture = texture_normal
		GameManager.ReticleMode.AIMING:
			texture = texture_aiming
