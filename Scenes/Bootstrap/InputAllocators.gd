extends Node
@onready var look_axis_alloc: InputAxisAllocator = $LookAxisAlloc
@onready var move_axis_alloc: InputAxisAllocator = $MoveAxisAlloc

func _ready() -> void:
	GameManager.look_axis = look_axis_alloc
	GameManager.move_axis = move_axis_alloc
