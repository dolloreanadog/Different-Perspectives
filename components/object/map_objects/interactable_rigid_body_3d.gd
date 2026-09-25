## Something the player can pick up
class_name InteractableRigidBody3D
extends RigidBody3D

## Which player that cannot interact
@export var player_type: PlayerController.PlayerType
@export var is_picked_up: bool
var timer: Timer

# TODO: sync this among other players

#func _ready() -> void:
	#timer = Timer.new()
	#
