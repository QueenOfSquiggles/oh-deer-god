extends FiniteState

func on_enter() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GameManager.update_reticle_mode.emit(GameManager.ReticleMode.HIDDEN)

func on_exit() -> void:
	pass

func tick(_delta : float) -> void:
	pass
