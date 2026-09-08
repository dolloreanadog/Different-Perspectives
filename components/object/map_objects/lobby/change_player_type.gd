class_name ChangePlayerTypeArea
extends Area3D

@export var player_type: PlayerController.PlayerType

signal player_entered()

func _ready() -> void:
	body_entered.connect(_on_change_player_type_area_body_entered)

func _on_change_player_type_area_body_entered(body: Node3D) -> void:
	print("Something entered")
	if body is PlayerController:
		var player: PlayerController = body
		player.player_type_selected = player_type
		player_entered.emit()
