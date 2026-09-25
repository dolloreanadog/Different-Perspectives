class_name InteractableButton3D
extends StaticBody3D

## Which player that cannot interact
@export var player_type: PlayerController.PlayerType
var disabled: bool = false
var is_pressed: bool = false

@export var unpress_time: float = 0

signal pressed()
signal unpressed()

func _ready() -> void:
	pass

@rpc("any_peer", "call_local", "reliable")
func _is_pressed_wait() -> void:
	await get_tree().create_timer(unpress_time).timeout
	bypass_unpress_button()

@rpc("any_peer", "call_local", "reliable")
func _press() -> void:
	if Global.player.player_type == player_type && is_pressed == false && !disabled:
		pressed.emit()
		is_pressed = true

@rpc("any_peer", "call_local", "reliable")
func _unpress() -> void:
	if Global.player.player_type == player_type:
		unpressed.emit()
		is_pressed = false

func press_button() -> void:
	_press.rpc()
	_is_pressed_wait.rpc()

func unpress_button() -> void:
	_unpress.rpc()

## This won't require player type
func bypass_press_button() -> void:
	_press.rpc()

## This won't require player type
func bypass_unpress_button() -> void:
	_unpress.rpc()
