extends Button
class_name LevelButton

@export var map: MapInfo

func _ready() -> void:
	pass

func _open_map_confirmation() -> void:
	pass # TODO: This should open a dialogue option on whether to play the map.

func _pressed() -> void:
	Global.map_spawner.spawn(map.map.resource_path) # TODO: This miuht not be synced
	Global.map_manager.level_select_panel.hide()
	
