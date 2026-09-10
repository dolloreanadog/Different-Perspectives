## This pushes the player. If it doesn't work, check [CollisionObject3D.collision_layer].
class_name PushArea3D
extends Area3D

@export var force: Vector3 
@export var magnitude: float = 1.0

var players: Array[PlayerController]

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	print("is body_entered connected: %s" % [body_entered.is_connected(_on_body_entered)])

func _on_body_entered(body: Node3D) -> void: # We need to constantly push, this only does once
	print("Body Entered 1")
	if body is PlayerController:
		print("Body Entered 2")
		players.append(body)
	else:
		print("Not Player")

func _on_body_exited(body: Node3D) -> void: 
	if body is PlayerController:
		print("Body Exit 2")
		players.erase(body)

func force_move() -> void:
	for player: PlayerController in players:
		player.force_move(force, magnitude)

func _process(_delta: float) -> void:
	if !players.is_empty():
		force_move()
