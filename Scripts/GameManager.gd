extends Node

const GAME_DATA_PATH := "user://game_data.json"

const STARTING_BEAT := StoryBeat.b06_GET_SHOTGUN
enum StoryBeat {
	# see obsidian notes for details
	b00_HUNGRY=0,
	b01_ENTER_KONBINI=1,
	b02_CHECKOUT=2,
	b03_MAKING_FOOD=3,
	b04_EATING=4,
	b05_NEED_PAPERS=5,
	b06_GET_SHOTGUN=6,
	b07_KILL=7,
	b08_BAD_ENDING=8,
	b09_FURFUR_RISES=9,
	b10_FLEE_TO_FOREST=10,
	b11_RESTOCK_AND_RELOAD=11,
	b12_FIGHT_TO_KONBINI=12,
	b13_KILL_FURFUR=13,
}

enum ReticleMode {
	HIDDEN, INTERACT, AIMING
}

#region Public API

signal on_story_progress_changes(new_story_beat : StoryBeat)
signal request_interact_label(label : String)
signal player_has_shotgun(has : bool)
signal cutscene_kill_margaret
signal cutscene_kill_peryton
signal request_player_can_move(can_move : bool)
signal update_reticle_mode(mode : ReticleMode)
var story_progress := STARTING_BEAT

var look_axis : InputAxisAllocator
var move_axis : InputAxisAllocator

var current_track : Node

func load_cutscene(cutscene : String) -> void:
	match cutscene:
		"kill_margaret": 
			request_player_can_move.emit(false)
			cutscene_kill_margaret.emit()
		"kill_peryton": 
			request_player_can_move.emit(false)
			cutscene_kill_peryton.emit()
		_: 
			push_warning("Unhandled cutscene! '%s'" % cutscene)

func set_story_beat(n_beat : StoryBeat) -> void:
	if story_progress == n_beat:
		return
	story_progress = n_beat
	on_story_progress_changes.emit(story_progress)
	print(story_progress)

func trigger_dialog_track(track_name : String) -> void:
	request_player_can_move.emit(false)
	current_track = Dialogic.start(track_name)
	current_track.tree_exiting.connect( \
		Callable(self, "emit_signal") \
		.bind("request_player_can_move", true), CONNECT_DEFERRED) 

func give_player_shotgun() -> void:
	player_has_shotgun.emit(true)

func set_player_has_shotgun(does_has : bool) -> void:
	player_has_shotgun.emit(does_has)

func get_player() -> PlayerCharacter:
	return get_tree().get_first_node_in_group("player") as PlayerCharacter

#endregion


#region Internals

func _ready() -> void:
	_load()
	CoreGlobals.config.graphics.mark_dirty() # forces loading of saved/default graphics settings (includes window and FSR settings)
	print(story_progress)
	Dialogic.signal_event.connect(_internal_dialogic_event)
	update_reticle_mode.emit(ReticleMode.HIDDEN)

func _internal_dialogic_event(event_data) -> void:
	if event_data == "queue_free_me":
		get_tree().quit()

func _load() -> void:
	var sdb := SaveDataBuilder.new()
	sdb.load(GAME_DATA_PATH)

func _save() -> void:
	var sdb := SaveDataBuilder.new()
	sdb.save(GAME_DATA_PATH)

func _exit_tree() -> void:
	_save()
#endregion
