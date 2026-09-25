## Hides the object it is attached to, can't have this in the lobby
class_name HideObject extends Node


@export var seen_only_by: PlayerController.PlayerType

func _ready() -> void:
	# Check if our player can see that obstacle or not
	# TODO: Players Load first -> Then the map does
	Global.player.got_player_type.connect(got_player_type) # INFO: This crashes the game in the lobby
	
	check_to_hide()

#@rpc("any_peer", "call_local", "reliable")
func check_to_hide() -> void:
	push_warning(Global.player.player_type_selected)
	if !Global.player.player_type_selected == seen_only_by:
		get_parent().hide()

func got_player_type() -> void:
	check_to_hide()
