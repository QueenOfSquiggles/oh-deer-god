extends CharacterBody3D
class_name PlayerCharacter

@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var state_action_moving := $FiniteStateMachine/StateActionMoving
@onready var state_movement_disabled := $FiniteStateMachine/StateMovementDisabled
@onready var state_shotgun_aiming := $FiniteStateMachine/StateShotgunAiming
@onready var shotgun: Node3D = $VirtualCamera3D/Marker3D/shotgun2

@onready var interact_raycast_3d := $VirtualCamera3D/InteractRaycast3D

@export var look_speed := 0.06
var has_shotgun := false


func _ready() -> void:
	state_action_moving.on_aim.connect(Callable( \
		fsm, "push_state") \
		.bind(state_shotgun_aiming), CONNECT_DEFERRED)
	state_shotgun_aiming.on_release_aim.connect(Callable( \
		fsm, "push_state") \
		.bind(state_action_moving), CONNECT_DEFERRED)

	_handle_get_shotgun(has_shotgun)
	GameManager.player_has_shotgun.connect(_handle_get_shotgun)
	GameManager.request_player_can_move.connect(request_able_to_move)

func request_able_to_move(can_move) -> void:
	if can_move:
		fsm.push_state(state_action_moving)
	else:
		fsm.push_state(state_movement_disabled)

func _handle_get_shotgun(has : bool) -> void:
	has_shotgun = has
	shotgun.visible = has_shotgun
	if not has:
		return
