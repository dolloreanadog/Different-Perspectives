@tool
## An area that changes the player type
class_name ChangePlayerTypeArea
extends Area3D

@export var player_type: PlayerController.PlayerType
@export var time: float = 0

signal player_entered()
## Same as above, but enter how much time before something happens
signal player_entered_time(time_amount: float)

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
		player_entered_time.emit(time)
