extends Node

@export var player: PlayerController

func get_player_from_steam_id(id: int) -> PlayerController:
	var players: Array[Node] = get_tree().get_nodes_in_group("players")
	var selected_player: PlayerController
	for player_cycle: PlayerController in players:
		if player_cycle.steam_id == id:
			selected_player = player_cycle
			break
	return selected_player
