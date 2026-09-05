extends Node
class_name HideObject

@export var seen_only_by: PlayerController.PlayerType

func _ready() -> void:
	# Check if our player can see that obstacle or not
	# TODO: Players Load first -> Then the map does
	Global.player.got_player_type.connect(got_player_type)
	
	check_to_hide.rpc()

@rpc("any_peer", "call_local", "reliable")
func check_to_hide() -> void:
	get_parent().hide()

func got_player_type() -> void:
	check_to_hide.rpc()
