extends BoneAttachment3D

@export var turn_speed := 3.0
@export var target_pos_offset := Vector3.ZERO
var player : Node3D = null
func _process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player") as Node3D
		return
	var target := global_transform.looking_at( \
		player.global_position + target_pos_offset, \
		Vector3.UP, \
		true \
	)
	global_transform = global_transform.interpolate_with(target, delta * turn_speed)
