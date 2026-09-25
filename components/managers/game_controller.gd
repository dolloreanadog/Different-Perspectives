extends Node
class_name GameController

@onready var lobby_manager: LobbyManager = %LobbyManager
@onready var network_manager: NetworkManager = %NetworkManager
@onready var menu_manager: MenuManager = %MenuManager
@onready var map_manager: MapManager = %MapManager
@onready var map_spawner: MultiplayerSpawner = %MapSpawner

func _ready() -> void:
	Global.map_manager = map_manager
	Global.menu_manager = menu_manager
	Global.network_manger = network_manager
	Global.lobby_manger = lobby_manager
	Global.map_spawner = map_spawner
	Global.game_controller = self
