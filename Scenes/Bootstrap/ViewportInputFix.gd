extends SubViewport

func _ready() -> void:
	get_parent().ready.connect(_do_setup, CONNECT_DEFERRED | CONNECT_ONE_SHOT)

func _do_setup() -> void:
	handle_input_locally = true
