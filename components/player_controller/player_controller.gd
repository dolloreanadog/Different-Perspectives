class_name PlayerController extends CharacterBody3D

@onready var head: Node3D = %Head
@onready var camera: Camera3D = %Camera
@onready var audio_listener: AudioListener3D = %AudioListener
@onready var prox_network: AudioStreamPlayer3D = %ProxNetwork
@onready var prox_local: AudioStreamPlayer3D = %ProxLocal
@onready var animation_tree: AnimationTree = %AnimationTree

@export_category("Movement")
@export var move_speed: float = 5.0
@export var acceleration: float = 15.0
@export var jump_velocity: float = 4.0

## The higher it is the fast it decays, the lower it is the slower it decays
@export var horizontal_decay: float = 1.0
## The higher it is the fast it decays, the lower it is the slower it decays
@export var vertical_decay: float = 1.0

@export_category("Camera")
@export var camera_sensitivity: float = 0.1

@export_category("Proximity")
@export var has_loopback: bool = false
@export var max_distance: float = 30.0

var horizontal_input_dir: Vector2 = Vector2.ZERO
var vertical_input_dir: float
var input_smoothed: Vector2 = Vector2.ZERO
var direction: Vector3 = Vector3.ZERO

#region Proximity Variables
var current_sample_rate: int = 4800
var local_playback: AudioStreamGeneratorPlayback = null
var local_voice_buffer: PackedByteArray = PackedByteArray()
var network_playback: AudioStreamGeneratorPlayback = null
var network_voice_buffer: PackedByteArray = PackedByteArray()
var packet_read_limit: int = 5
#endregion

var player_name: String = "Larry"
var steam_id: int = 0

var player_type_selected: PlayerType:
	set(value):
		player_type_selected = value
		got_player_type.emit()

enum PlayerType {
	PLAYER1, 
	PLAYER2,
	PLAYER3
	}

signal got_player_type()

func _ready() -> void:
	Global.player = self

	prox_local.max_distance = max_distance
	prox_local.stream.mix_rate = current_sample_rate
	prox_local.play()
	local_playback = prox_local.get_stream_playback()

	prox_local.max_distance = max_distance
	prox_network.stream.mix_rate = current_sample_rate
	prox_network.play()
	network_playback = prox_network.get_stream_playback()

	camera.current = is_multiplayer_authority()
	audio_listener.current = is_multiplayer_authority()

	if is_multiplayer_authority():
		player_name = SteamManager.steam_username
		steam_id = SteamManager.steam_id

		for child in %WorldModel.find_children("*", "VisualInstance3D"):
			child.set_layer_mask_value(1, false)
			child.set_layer_mask_value(20, true)
	else:
		if multiplayer.multiplayer_peer is SteamMultiplayerPeer:
			var peer: SteamMultiplayerPeer = multiplayer.multiplayer_peer
			steam_id = peer.get_steam64_from_peer_id(get_multiplayer_authority())
		else:
			steam_id = Steam.getSteamID()
		player_name = Steam.getFriendPersonaName(steam_id)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * camera_sensitivity))
			head.rotate_x(deg_to_rad(-event.relative.y * camera_sensitivity))
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _input(_event: InputEvent) -> void:
	if !is_multiplayer_authority(): return

	if Input.is_action_just_pressed("voice"):
		record_voice(true)
	elif Input.is_action_just_released("voice"):
		record_voice(false)

func get_speed() -> float:
	return move_speed

func handle_horizontal_movement(delta: float) -> void:
	direction = lerp(direction, (transform.basis * Vector3(horizontal_input_dir.x, vertical_input_dir, horizontal_input_dir.y)).normalized(), delta * acceleration)
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		velocity.y = direction.y * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, delta * horizontal_decay)
		velocity.z = move_toward(velocity.z, 0, delta * horizontal_decay)
		velocity.y = move_toward(velocity.y, 0, delta * horizontal_decay)
	
	
func handle_vertical_movement(delta: float) -> void:
	
	velocity.y = move_toward(velocity.y, 0, delta * vertical_decay)
	#velocity += get_gravity() * delta

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return

	horizontal_input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	vertical_input_dir = 0
	if Input.is_action_pressed("up"):
		vertical_input_dir = 1
	if Input.is_action_pressed("down"):
		vertical_input_dir = -1
	
	# Should probably do the animation for drone
	input_smoothed = lerp(input_smoothed, horizontal_input_dir, delta * 10.0)
	animation_tree.set("parameters/walking_direction_blend_space/blend_position", input_smoothed)
	
	
	handle_horizontal_movement(delta)
	#handle_vertical_movement(delta)
	#if is_on_floor():
		#
			#
		#handle_movement(delta)
	#else:
		#handle_gravity(delta)

	move_and_slide()

func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		check_for_voice()

func process_voice_data(voice_data: Dictionary, voice_source: String) -> void:
	get_sample_rate()
	var decompressed_voice: Dictionary
	if voice_source == "local":
		decompressed_voice = Steam.decompressVoice(voice_data['buffer'], current_sample_rate)
	elif voice_source == "network":
		decompressed_voice = Steam.decompressVoice(voice_data['voice_data'], current_sample_rate)

	if decompressed_voice['result'] == Steam.VOICE_RESULT_OK and decompressed_voice['size'] > 0:
		if voice_source == "local":
			local_voice_buffer = decompressed_voice['uncompressed']
			local_voice_buffer.resize(decompressed_voice['size'])
			for i: int in range(0, mini(local_playback.get_frames_available() * 2, local_voice_buffer.size()), 2):
				var raw_value: int = local_voice_buffer[0] | (local_voice_buffer[1] << 8)
				raw_value = (raw_value + 32768) & 0xffff
				var amplitude: float = float(raw_value - 32768) / 32768.0
				local_playback.push_frame(Vector2(amplitude, amplitude))

				local_voice_buffer.remove_at(0)
				local_voice_buffer.remove_at(0)
		elif voice_source == "network":
			network_voice_buffer = decompressed_voice['uncompressed']
			network_voice_buffer.resize(decompressed_voice['size'])
			for i: int in range(0, mini(network_playback.get_frames_available() * 2, network_voice_buffer.size()), 2):
				var raw_value: int = network_voice_buffer[0] | (network_voice_buffer[1] << 8)
				raw_value = (raw_value + 32768) & 0xffff
				var amplitude: float = float(raw_value - 32768) / 32768.0
				network_playback.push_frame(Vector2(amplitude, amplitude))

				network_voice_buffer.remove_at(0)
				network_voice_buffer.remove_at(0)

func record_voice(is_recording: bool) -> void:
	Steam.setInGameVoiceSpeaking(SteamManager.steam_id, is_recording)

	if is_recording:
		Steam.startVoiceRecording()
	else:
		Steam.stopVoiceRecording()

func check_for_voice() -> void: # If error happens, we were in local multiplayer and not steam
	var available_voice: Dictionary = Steam.getAvailableVoice()
	if available_voice['result'] == Steam.VOICE_RESULT_OK and available_voice['buffer'] > 0:
		var voice_data: Dictionary = Steam.getVoice()
		if voice_data['result'] == Steam.VOICE_RESULT_OK and voice_data["written"]:
			print("Voice message has data: %s / %s" % [voice_data['result'], voice_data['written']])
			SteamManager.send_voice_data(voice_data['buffer'])

			if has_loopback:
				process_voice_data(voice_data, "local")

func get_sample_rate(is_toggle: bool = true) -> void:
	if is_toggle:
		current_sample_rate = Steam.getVoiceOptimalSampleRate()
	else:
		current_sample_rate = 48000

	prox_network.stream.mix_rate = current_sample_rate
	prox_local.stream.mix_rate = current_sample_rate
