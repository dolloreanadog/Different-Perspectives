@tool
## This pushes the player. If it doesn't work, check [CollisionObject3D.collision_layer].
class_name PushArea3D
extends Area3D

@export var force: Vector3 
@export var magnitude: float = 1.0

var collider: CollisionShape3D
var players: Array[PlayerController]

func _ready() -> void:
	# automatically set it to detect players
	collision_layer = 2
	collision_mask = 2
	input_ray_pickable = false
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	collider = get_child(0)
	print("is body_entered connected: %s" % [body_entered.is_connected(_on_body_entered)])

func _on_body_entered(body: Node3D) -> void: # We need to constantly push, this only does once
	if body is PlayerController:
		players.append(body)

func _on_body_exited(body: Node3D) -> void: 
	if body is PlayerController:
		players.erase(body)

func force_move() -> void:
	for player: PlayerController in players:
		player.force_move(force, magnitude)

func disable() -> void:
	if is_instance_valid(collider):
		collider.call_deferred("set_disabled", true)

func enable() -> void:
	if is_instance_valid(collider):
		collider.call_deferred("set_disabled", false)

func _process(_delta: float) -> void:
	if !players.is_empty():
		force_move()
