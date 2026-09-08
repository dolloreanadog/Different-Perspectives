extends Panel
class_name PlayerPanel

var steam_id: int = -1
var id: int = -1

@onready var name_label: Label = $NameLabel
@onready var option_button: OptionButton = $OptionButton

func _ready() -> void:
	_can_use()

func _setup() -> void:
	name_label.text

func _can_use() -> void:
	if !multiplayer.is_server():
		option_button.disabled = true

func _on_option_button_item_selected(index: int) -> void:
	var player: PlayerController = Global.get_player_from_steam_id(steam_id)
	match index:
		0:
			player.player_type_selected = PlayerController.PlayerType.PLAYER1
		1:
			player.player_type_selected = PlayerController.PlayerType.PLAYER2
		2:
			player.player_type_selected = PlayerController.PlayerType.PLAYER3
		_:
			push_error("Not a valid item")
