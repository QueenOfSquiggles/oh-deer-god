extends FiniteState

@onready var cam: VirtualCamera3D = $"../../VirtualCamera3D"
@onready var actor: PlayerCharacter = $"../.."
@onready var shotgun := $"../../VirtualCamera3D/Marker3D/shotgun2"
@onready var anim: AnimationPlayer = $"../../AnimationPlayer"
@onready var muzzle_flash: GPUParticles3D = $"../../VirtualCamera3D/Marker3D/shotgun2/MuzzleFlash"

@export var look_max := 70.0
@export var look_min := -70.0
@export var look_speed_factor := 0.9
@export var shotgun_sway_limit := 5.0
@export_group("Shotgun Shooting", "shotgun_")
@export var shotgun_shot_count := 16
@export var shotgun_spread_angle_degrees := 15.0
@export var shotgun_range := 20.0
@export var shotgun_rate_of_fire := 0.5
@export var shotgun_hit_solid_vfx : PackedScene

var look_max_rads : float = 0
var look_min_rads : float = 0
var is_active := false
var shotgun_reset_sway_value := 0.0
var can_shoot := true
var tween : Tween

signal on_release_aim

func _ready() -> void:
	look_max_rads = deg_to_rad(look_max)
	look_min_rads = deg_to_rad(look_min)

func on_enter() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	is_active = true
	shotgun_reset_sway_value = shotgun.sway_max_deg
	shotgun.sway_max_deg = shotgun_sway_limit
	GameManager.update_reticle_mode.emit(GameManager.ReticleMode.AIMING)
	print("Entering state: %s" % name)
	anim.play("Idle", 0.1)


func on_exit() -> void:
	is_active = false
	shotgun.sway_max_deg = shotgun_reset_sway_value

func tick(_delta : float) -> void:
	do_look()
	if not actor.is_on_floor():
		actor.velocity = Vector3.DOWN * 9.8
		actor.move_and_slide()
	if can_shoot and Input.is_action_pressed("shoot"):
		do_shoot()


func do_look() -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		GameManager.look_axis.get_value()
		return
	var rot_by := -GameManager.look_axis.get_value() * actor.look_speed * look_speed_factor
	shotgun.look_amount = rot_by
	#print("look_intent = %s" % str(rot_by))
	actor.rotate_y(rot_by.x)
	cam.rotate_x(rot_by.y)
	cam.rotation.x = clamp(cam.rotation.x, look_min_rads, look_max_rads)


func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event.is_action_released("aim"):
		on_release_aim.emit()
		get_viewport().set_input_as_handled()

func do_shoot() -> void:
	can_shoot = false
	_shotgun_pellets()
	anim.play("shoot")
	muzzle_flash.emitting = true
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_interval(shotgun_rate_of_fire)
	tween.tween_property(self, "can_shoot", true, 0.01)

func _shotgun_pellets() -> void:
	var angle := (2.0 * PI) / float(shotgun_shot_count)
	var shot_normals :Array[Vector3]= []
	var normal_forwards := Vector3(0,0,-1)
	for i in range(shotgun_shot_count):
		var a := angle * float(i)
		var angle90 := Vector3(cos(a), sin(a), 0) # unit circle making it a 90 degree angle away from straigh ahead
		var offset_degrees := randf() * deg_to_rad(shotgun_spread_angle_degrees)
		var factor := offset_degrees / (PI/2.0)
		# lerping between pure accuracy and pure inaccuracy based on the given random angle, which has a max value based on the spread angle.
		var normal := normal_forwards.slerp(angle90, factor).normalized()
		var globalized := Vector3()
		globalized += cam.global_basis.z * normal.z
		globalized += cam.global_basis.x * normal.x
		globalized += cam.global_basis.y * normal.y
		shot_normals.push_back(globalized.normalized())
	for normal in shot_normals:
		var dss := actor.get_world_3d().direct_space_state
		var params := PhysicsRayQueryParameters3D.new()
		params.exclude.push_back(actor.get_rid())
		params.from = cam.global_position
		params.to = params.from + (normal * shotgun_range)
		var results := dss.intersect_ray(params)
		if results.has("position"):
			var vfx :Node3D = shotgun_hit_solid_vfx.instantiate()
			actor.get_parent_node_3d().add_child(vfx)
			vfx.global_position = results.position
		if results.has("collider"):
			var coll :Node= results.collider
			if coll and "damage" in coll:
				coll.damage()


