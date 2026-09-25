class_name DebugMessageNode
extends Node

@export_multiline("Stuff") var text: String

func _say() -> void:
	print(text)
