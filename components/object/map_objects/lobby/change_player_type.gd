@tool
## An area that changes the player type
class_name ChangePlayerTypeArea
extends Area3D

@export var player_type: PlayerController.PlayerType

signal player_entered()

func _ready() -> void:
	body_entered.connect(_on_change_player_type_area_body_entered)
	
	# Automatically set it so it detects players
	collision_layer = 2
	collision_mask = 2
	input_ray_pickable = false

func _on_change_player_type_area_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		print("Something entered")
		var player: PlayerController = body
		player.player_type_selected = player_type
		player_entered.emit()
