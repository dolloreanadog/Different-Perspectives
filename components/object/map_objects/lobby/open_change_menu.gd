class_name OpenChangeMenuArea3D extends Area3D

const LEVEL_SELECT_PANEL = preload("uid://beplc6j5rx7ww")

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		var player: PlayerController = body
		print("Check 1")
		if player.get_multiplayer_authority() == multiplayer.get_unique_id():
			print("Check 2")
			if multiplayer.is_server():
				print("Check 3")
				_open_level_select()

func _open_level_select() -> void:
	print("Opening Level Select")
	Global.map_manager.level_select_panel.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _close_level_select() -> void:
	print("Closing Level Select")
	Global.map_manager.level_select_panel.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
