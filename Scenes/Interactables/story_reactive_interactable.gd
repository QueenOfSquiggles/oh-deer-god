extends InteractionObjectArea3D
class_name DialogProvider

enum TriggerMode {
	TRIGGER_INTERACT,
	TRIGGER_COLLIDE,
	TRIGGERE_BOTH
}
@export var dialogic_track := ""
@export var active_story_beat : Array[GameManager.StoryBeat] = []
@export var queue_free_on_inactive := true
@export var trigger_mode := TriggerMode.TRIGGER_INTERACT
@export var is_one_shot := false

func _ready() -> void:
	GameManager.on_story_progress_changes.connect(_on_new_story_beat)
	_on_new_story_beat(GameManager.story_progress)

func _on_new_story_beat(beat : GameManager.StoryBeat) -> void:
	if active_story_beat.has(beat):
		is_active = true
	else:
		is_active = false
	if queue_free_on_inactive and beat > active_story_beat.max():
		queue_free()

func _on_on_interacted() -> void:
	if trigger_mode != TriggerMode.TRIGGER_COLLIDE:
		_do_thing()

func _on_body_entered(body: Node3D) -> void:
	if trigger_mode != TriggerMode.TRIGGER_INTERACT and body.is_in_group("player"):
		_do_thing()

func _do_thing() -> void:
	if dialogic_track.is_empty():
		return
	GameManager.trigger_dialog_track(dialogic_track)
	if is_one_shot:
		queue_free()
