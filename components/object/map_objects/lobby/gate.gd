class_name Gate
extends Node3D

var closed_position: Vector3
@export var open_position: Vector3
@export var switch_time: float = 1
var is_open: bool

signal gate_opened()
signal gate_closed()

func _ready() -> void:
	closed_position = global_position
	
	## TODO: Remove this when done with debugging
	#await get_tree().create_timer(2).timeout
	#_open_gate(true)
	#await get_tree().create_timer(2).timeout
	#_open_gate(false)

func _check_can_pass() -> bool:
	var player_1_amount: int = 0
	var player_2_amount: int = 0
	var player_3_amount: int = 0
	
	for player: PlayerController in get_tree().get_nodes_in_group("players"):
		match player.player_type_selected:
			PlayerController.PlayerType.PLAYER1:
				player_1_amount += 1
			PlayerController.PlayerType.PLAYER2:
				player_2_amount += 1
			PlayerController.PlayerType.PLAYER3:
				player_3_amount += 1
			_:
				push_error("Not a valid player type")
	
	if player_1_amount == 1 and player_2_amount == 1 and player_3_amount == 1:
		print("Can pass")
		return true
	else:
		print("Cannot pass")
		return false

func _open_gate(value: bool) -> void:
	is_open = value
	if value:
		get_tree().create_tween().tween_property(self, "global_position", open_position, switch_time)
		gate_opened.emit()
	else: # TODO: We can crash the game if we move to another level when this happens
		get_tree().create_tween().tween_property(self, "global_position", closed_position, switch_time)
		gate_closed.emit()


func _on_player_entered_change_player_type_area() -> void:
	_open_gate(_check_can_pass())


func _on_change_player_type_area_player_entered_time(time_amount: float) -> void:
	if _check_can_pass():
		_open_gate(true)
		await get_tree().create_timer(time_amount).timeout
		_open_gate(false)
	else:
		_open_gate(false)
