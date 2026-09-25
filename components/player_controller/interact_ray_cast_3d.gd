@tool
class_name InteractRayCast3D
extends RayCast3D

signal on_interaction(object: Node3D)

@export var player_controller: PlayerController
@export_group("Pickup")
@export var object_position: Marker3D:
	set(marker):
		object_position = marker
		update_configuration_warnings()
@export_range(0, 10, 0.1) var pickup_speed: float = 5
@export_group("Object Movement")
## How far it can be until we dislodge from player. So if it gets stuck on a wall we just remove it.
@export var influence_max_range: float = 5
@export var influence_min_range: float = 0.15
## @deprecated: I'll fix the infinite rotation, but right now it's bad
@export_group("Object Rotation")
@export_range(0, 10, 0.1) var rotation_speed: float = 5
@export var rot_influence_min_range: float = 0.15
@export var rotation_time: float = 1
var current_rotation_time: float = 1
@export var current_object: RigidBody3D
@export_group("Interaction Cooldown")
@export var cooldown: float = 0.25
var is_on_cooldown: bool = false

func _notification(what: int) -> void:
	pass

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !is_instance_valid(object_position):
		warnings.append("There is no object position marker")
	return warnings

func _physics_process(delta: float) -> void:
	if is_instance_valid(current_object):
		# INFO: We are dealing with jitter, look into gmod, It has also jitter. We're boned (Unfixable)
		var distance: float = current_object.global_position.distance_to(object_position.global_position)
		#var rot_distance: float = current_object.global_rotation.distance_to(object_position.global_rotation)
#region Rotation
		current_object.global_rotation = object_position.global_rotation
		#if rot_distance > rot_influence_min_range and current_rotation_time > 0:
			#print("current distance: %s" % [rot_distance])
			#var direction: Vector3 = current_object.global_rotation.direction_to(object_position.global_rotation)
			#current_object.angular_velocity = direction * rotation_speed
			#current_rotation_time -= delta
		#else:
			#print("Set Back")
			#
			#current_object.angular_velocity = Vector3.ZERO
			#current_rotation_time = rotation_time
#endregion
#region Movement
		if distance > influence_min_range:
			#print("current distance: %s" % [distance])
			var direction: Vector3 = current_object.global_position.direction_to(object_position.global_position)
			current_object.linear_velocity = direction * pickup_speed
		else:
			current_object.linear_velocity = Vector3.ZERO
		if distance > influence_max_range:
			print("release object")
			release_object(current_object)
#endregion



func get_object() -> Node3D:
	print("collider %s" % [get_collider()])
	return get_collider()

func pick_up(object: Node3D) -> void: 
	if !is_multiplayer_authority(): return
	if is_on_cooldown: return
	# TODO: We should probably turn rigid body into its own class InteractableRigidBody3D
	
	var object_released: bool = release_object(current_object)
	if object_released: return
	
	if object is InteractableRigidBody3D:
		print("Is rigid body")
		var rigid_body: InteractableRigidBody3D = object
		give_object(rigid_body)
	is_on_cooldown = true
	await get_tree().create_timer(cooldown).timeout
	is_on_cooldown = false

func give_object(rigid_body: InteractableRigidBody3D) -> void:
		if !is_instance_valid(current_object):
			if rigid_body.is_picked_up: return
			print("Picked Up")
			rigid_body.is_picked_up = true
			current_object = rigid_body
			current_object.gravity_scale = 0
			enabled = false

func release_object(rigid_body: InteractableRigidBody3D) -> bool:
	# release the object
	if is_instance_valid(current_object):
		print("released")
		current_object.is_picked_up = false
		# TODO: Maybe can have it use the current velocity of the player
		current_object.linear_velocity = player_controller.velocity
		current_object.gravity_scale = 1
		current_object = null
		enabled = true
		return true
	return false

func press_button(object: Node3D) -> void:
	if !is_multiplayer_authority(): return
	if is_on_cooldown: return
	if object is InteractableButton3D:
		(object as InteractableButton3D).press_button()
