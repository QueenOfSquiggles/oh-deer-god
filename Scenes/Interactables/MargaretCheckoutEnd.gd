extends DialogProvider

@export_file("*.json") var track_has_shotgun : String
@export_file("*.json") var track_no_shotgun : String


func _on_on_interacted() -> void:
	var track := track_no_shotgun
	if CoreDialog.blackboard_query("shotgun == true"):
		track = track_has_shotgun
	dialogic_track = track
	super._on_on_interacted()
