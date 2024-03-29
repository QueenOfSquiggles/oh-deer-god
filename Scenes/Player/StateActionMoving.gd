extends FiniteState

@onready var actor: PlayerCharacter = $"../.."
@onready var cam: VirtualCamera3D = $"../../VirtualCamera3D"
@onready var interact_ray: InteractRaycast3D = $"../../VirtualCamera3D/InteractRaycast3D"
@onready var shotgun: Node3D = $"../../VirtualCamera3D/Marker3D/shotgun2"
@onready var anim: AnimationPlayer = $"../../AnimationPlayer"


@export var look_max := 70.0
@export var look_min := -70.0
@export var move_speed := 5.0
@export var sprint_speed := 12.0
@export var acceleration := 10.0
@export var jump_str := 5.0

signal on_aim

var look_max_rads : float = 0
var look_min_rads : float = 0
var gravity := 9.8
var can_interact := false
var is_active := false;

func _ready() -> void:
	look_max_rads = deg_to_rad(look_max)
	look_min_rads = deg_to_rad(look_min)

func on_enter() -> void:
	is_active = true
	#print("Starting %s" % name)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# clear out axis buffers
	if GameManager.look_axis:
		GameManager.look_axis.get_value()
	if GameManager.move_axis:
		GameManager.move_axis.get_value()
	GameManager.update_reticle_mode.emit(GameManager.ReticleMode.INTERACT)

func on_exit() -> void:
	is_active = false
	GameManager.request_interact_label.emit("")
	anim.speed_scale = 1.0


func tick(delta : float) -> void:
	do_move(delta)
	do_jump(delta)
	do_look()
	actor.move_and_slide()
	do_interact()
	update_anim()
	
	
func do_move(delta : float) -> void:
	var intent := GameManager.move_axis.get_value().normalized()
	#print("move_intent = %s" % str(intent))
	var dir := Vector3(0,0,0)
	dir += -cam.global_basis.z * intent.y
	dir += cam.global_basis.x * intent.x
	dir.y = 0
	var accel = acceleration * delta
	if dir.length_squared() > 1.0:
		dir = dir.normalized()
	elif dir.length_squared() < 0.2:
		accel = 1.0 # makes the lerp instant
	var speed :float = sprint_speed if Input.is_action_pressed("sprint") else move_speed
	var target = dir * speed
	actor.velocity.x = lerp(actor.velocity.x, target.x, accel)
	actor.velocity.z = lerp(actor.velocity.z, target.z, accel)

func do_jump(delta : float) -> void:
	actor.velocity.y -= gravity * delta
	if not Input.is_action_pressed("jump"):
		return
	if actor.is_on_floor() and actor.velocity.y <= 0:
		actor.velocity.y = jump_str

func do_look() -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		GameManager.look_axis.get_value()
		return
	var rot_by := -GameManager.look_axis.get_value() * actor.look_speed
	shotgun.look_amount = rot_by
	actor.rotate_y(rot_by.x)
	cam.rotate_x(rot_by.y)
	cam.rotation.x = clamp(cam.rotation.x, look_min_rads, look_max_rads)

func do_interact() -> void:
	if not can_interact:
		return
	if not Input.is_action_just_pressed("interact"):
		return
	interact_ray.call_deferred("do_interact")

func update_anim() -> void:
	var track := "walking" if actor.velocity.length_squared() > 1.0 else "Idle"
	var speed := 2.0 if Input.is_action_pressed("sprint") else 1.0
	# apply
	if anim.current_animation != track:
		anim.play(track, 0.5)
	if anim.speed_scale != speed:
		var tween := create_tween()
		tween.tween_property(anim, "speed_scale", speed, 0.2)
		

func _on_interact_raycast_3d_can_interact(is_able_to_interact: bool) -> void:
	if not is_active:
		return
	can_interact = is_able_to_interact
	var target = interact_ray.target
	if is_able_to_interact and target and "get_active_name" in target:
		GameManager.request_interact_label.emit(target.get_active_name())
	else:
		GameManager.request_interact_label.emit("")


func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if actor.has_shotgun and event.is_action_pressed("aim"):
		on_aim.emit()
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()

