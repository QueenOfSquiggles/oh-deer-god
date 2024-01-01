extends Node3D
@export var sway_max_deg := 45.0 : 
	set(value):
		var d := deg_to_rad(value)
		sway_max_rad3 = Vector3(d, d, d)
		sway_max_deg = value

@export var sway_factor := 4.0
@export var sway_speed := 4.0

var look_amount : Vector2 = Vector2.ZERO
var sway_max_rad3 : Vector3

func _ready() -> void:
	var d := deg_to_rad(sway_max_deg)
	sway_max_rad3 = Vector3(d, d, d)

func _process(delta: float) -> void:
	var target : Vector3 = Vector3(-look_amount.y, look_amount.x, 0) * sway_factor
	rotation = rotation.lerp(target, delta * sway_speed)
	rotation = rotation.clamp(-sway_max_rad3, sway_max_rad3)
