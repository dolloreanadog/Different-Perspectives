class_name PlayerSpawner extends MultiplayerSpawner

@export var player_scene: PackedScene

@export_category("Configurations")
@export var group: Node

var players = {}
var spawn_position: Vector3

signal player_spawned()

## INFO: When host connects, peer_connected -> spawn method from the player_spawner (so we don't instance multiple maps)

func _ready() -> void:
	spawn_function = spawn_player

func spawn_host() -> void:
	if is_multiplayer_authority():
		var player: PlayerController = spawn(1)
		
		var node: Node = get_tree().get_first_node_in_group("SpawnPoints")
		if is_instance_valid(node):
			spawn_position = node.global_position
		
		player.global_position = spawn_position
		multiplayer.peer_connected.connect(spawn)
		player_spawned.connect(player.init_player_type)
		multiplayer.peer_disconnected.connect(remove_player)

func spawn_player(data: int) -> PlayerController:
	var player = player_scene.instantiate()
	player.set_multiplayer_authority(data)
	players[data] = player
	
	player_spawned.emit()
	return player



func remove_player(data) -> void:
	players[data].queue_free()
	players.erase(data)
