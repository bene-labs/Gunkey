class_name Player extends KinematicBody2D

var direction = Movement.Direction.NONE

export var current_health = 20
export var max_health = 20
export var invicibility_time = 1.0

var touching_enemies = [] setget set_touching_enemies

export (NodePath) var camera_path = ""
export (bool) var show_kill_count = false
export (bool) var flip_guns = false

var is_controller_mode = false
export var controller_aim_deadzone = 0.3

onready var active_gun = $Body/Arm/Shotgun

export (bool) var friendly = true

export (NodePath) var checkpoint_manager = ""

var collection_count = 0

var is_idle = true
var is_grounded = false
var velocity setget set_velocity, get_velocity

export var is_invincible = false
var is_inside_wind = false setget set_is_inside_wind, get_is_inside_wind
var hurt_zone_damage = 0

export var decrease_music_volume_on_pause = false
export var music_volume_pause_multiplier = 0.5

signal died
signal enter_floor
signal exit_floor

func get_is_grounded():
	return is_grounded

func set_is_inside_wind(value):
	is_inside_wind = value
	
func get_is_inside_wind():
	return is_inside_wind

func reset_animation():
	$Body/AnimationPlayer.play("Player_Idle")

func is_inside_range(target_position):
	return active_gun.get_node("SpawnPosition").global_position.distance_to(target_position) <= active_gun.max_range

func reset():
	current_health = max_health
	$Camera2D/CanvasLayer/LabeledHealthBar.set_value(current_health)
	reset_animation()
	$Movement.reset()
	direction = Movement.Direction.NONE
	touching_enemies.clear()
	$Body/AnimationPlayer.play("Player_Idle")
	$Body/Arm/Shotgun.ammo_count = $Body/Arm/Shotgun.max_ammo
	$Body/Arm/Pistol.ammo_count = $Body/Arm/Pistol.max_ammo
	$RespawnSound.play(0.12)
	$PlayerParticles/Respawn.emitting = true

func format_time(time_in_sec):
	var seconds = int(time_in_sec)%60
	var minutes = (int(time_in_sec)/60)%60
	var mili_seconds = time_in_sec - int(time_in_sec)
	mili_seconds *= 100
	mili_seconds = int(mili_seconds)
	return "%02d:%02d.%02d" % [minutes, seconds, mili_seconds]

# Called when the node enters the scene tree for the first time.
func _ready():
	reset_animation()
	$Camera2D/CanvasLayer/LabeledHealthBar.set_max_value(max_health)
	$Camera2D/CanvasLayer/LabeledHealthBar.set_value(current_health)
#	AnimationHelper.reconfige_even_timed_animation_lenght($AnimationPlayer.get_animation("take_damage"), invicibility_time, [0.25, 0.5])
	if camera_path != "":
		$Camera2D.current = false
		get_node(camera_path).current = true
		var remote_transform = RemoteTransform2D.new()
		remote_transform.remote_path = "../" + camera_path
		remote_transform.name = "CameraRemoteTransform"
		add_child(remote_transform)
		camera_path = get_node(camera_path).get_path()

func _process(delta):
	if is_controller_mode:
		var joystick_vel = Vector2.ZERO
		joystick_vel.x = Input.get_joy_axis(0, JOY_AXIS_2)
		joystick_vel.y = Input.get_joy_axis(0, JOY_AXIS_3)
		if $Body.scale.x < 0:
			joystick_vel.x *= -1
		if joystick_vel.length() >= controller_aim_deadzone:
			$Body/Arm.rotation = joystick_vel.angle()
	else:
		$Body/Arm.look_at(get_global_mouse_position())
	if flip_guns:
		if (int(abs($Body/Arm.rotation_degrees)) - 85) % 365 < 365 / 2:
			$Body/Arm/Pistol.scale.y = -abs($Body/Arm/Pistol.scale.y)
			$Body/Arm/Shotgun.scale.y = -abs($Body/Arm/Shotgun.scale.y)
		else:
			$Body/Arm/Pistol.scale.y = abs($Body/Arm/Pistol.scale.y)
			$Body/Arm/Shotgun.scale.y = abs($Body/Arm/Shotgun.scale.y)

func _input(event):
	if not is_controller_mode:
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			is_controller_mode = true
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		if event is InputEventMouse or event is InputEventKey:
			is_controller_mode = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("move_right") and not (event.is_action_pressed("move_left") or direction == Movement.Direction.LEFT):
		direction = Movement.Direction.RIGHT
	elif Input.is_action_just_pressed("move_left") and not (event.is_action_pressed("move_right") or direction == Movement.Direction.RIGHT):
		direction = Movement.Direction.LEFT
	elif Input.is_action_just_released("move_left"):
		if  Input.is_action_pressed("move_right"):
			direction = Movement.Direction.RIGHT
		else:
			direction = Movement.Direction.NONE
	elif Input.is_action_just_released("move_right"):
		if Input.is_action_pressed("move_left"):
			direction = Movement.Direction.LEFT
		else:
			direction = Movement.Direction.NONE
	
	is_idle = true if direction == Movement.Direction.NONE else false

func set_velocity(value):
	$Movement.velocity = value
	
func get_velocity():
	return $Movement.velocity

func _physics_process(delta):
	#print("1" if ($CoyoteTimer.is_stopped() or $CoyoteTimer.paused) else "0", is_grounded, is_on_floor())
	if ($CoyoteTimer.is_stopped() or $CoyoteTimer.paused) and is_grounded != is_on_floor():
		if is_on_floor():
			emit_signal("enter_floor")
		else:
			emit_signal("exit_floor")
	$Movement.process(direction, Input.is_action_just_pressed("jump"))

func heal(ammount):
	current_health += ammount
	if current_health > max_health:
		current_health = max_health
	$Camera2D/CanvasLayer/LabeledHealthBar.set_value(current_health)

func take_damage(damage = 1):
	if damage <= 0 or is_invincible or current_health <= 0:
		return
	current_health -= damage
	$Camera2D/CanvasLayer/LabeledHealthBar.set_value(current_health)
	$AnimationPlayer.play("take_damage")
	if current_health <= 0:
		die()

func restart(hard = false):
	if not hard and checkpoint_manager != "" and is_instance_valid(get_node(checkpoint_manager).selected_checkpoint):
		get_node(checkpoint_manager).respawn(self)
	else:
		SceneLoader.reload_current_scene()

func die():
	for child in get_children():
		if child.has_method("stop"):
			child.stop()
	set_process(false)
	set_process_input(false)
	set_physics_process(false)
	if is_grounded:
		$Body/AnimationPlayer.play("Player_DeathGround")
	else:
		$Body/AnimationPlayer.play("Player_DeathAir")
	
	print("DEAD!")
	emit_signal("died")

func _on_VictoryZone_win():
	$Camera2D/CanvasLayer/LevelTimer.on_level_cleared()

func set_key_total(total):
	$Camera2D/CanvasLayer/CollectionDisplay.total = total
	
func set_collected_keys(num):
	$Camera2D/CanvasLayer/CollectionDisplay.collected = num
	
func set_kills(num):
	$Camera2D/CanvasLayer/KillCount.kills = num
	
func get_collected_keys():
	return $Camera2D/CanvasLayer/CollectionDisplay.collected
	
func get_kills():
	return $Camera2D/CanvasLayer/KillCount.kills

func increase_collection_counter(is_ghost = false):
	if not is_ghost:
		$Camera2D/CanvasLayer/CollectionDisplay.collected += 1
	collection_count += 1
	
	
func get_level_stats() -> Dictionary:
	var stats = {}
	stats["time"] = $Camera2D/CanvasLayer/LevelTimer.passed_time
	stats["kills"] = $Camera2D/CanvasLayer/KillCount.kills
	var collected_keys = []
	for key in get_tree().get_nodes_in_group("Collectibles")[0].collectibles:
		if is_instance_valid(key):
			collected_keys.append(false)
		else:
			collected_keys.append(true)
	stats["keys"] = collected_keys
	stats["collected"] = collection_count
	
	return stats

func _on_checkpoint_activated():
	$Camera2D/CanvasLayer/Notification.create(format_time(get_passed_time()))

func get_passed_time():
	return $Camera2D/CanvasLayer/LevelTimer.passed_time
	
func _on_Player_enter_floor():
	if is_idle:
		$Body/AnimationPlayer.play("Player_Landing")
	else:
		$Body/AnimationPlayer.play("Player_Run")
		$PlayerParticles/DustTrail.emitting = true
	is_grounded = true
	$CoyoteTimer.stop()

func _on_Player_exit_floor():
	$PlayerParticles/DustTrail.emitting = false
	$CoyoteTimer.start()

func _on_CoyoteTimer_timeout():
	is_grounded = false
	$PlayerParticles/DustTrail.emitting = false

func pause_animation():
	$AnimationPlayer.playback_active = false
	$Body/AnimatedSprite.playing = false
	$Body/AnimationPlayer.playback_active = false
	
func unpause_animation():
	$AnimationPlayer.playback_active = true
	$Body/AnimatedSprite.playing = true
	$Body/AnimationPlayer.playback_active = true
	
func _on_Movement_enter_idle():
	is_idle = true
	if is_grounded:
		$Body/AnimationPlayer.play("Player_Idle")
	else:
		$Body/AnimationPlayer.play("Player_Falling")
	$PlayerParticles/DustTrail.emitting = false
	
func _on_Movement_enter_jump():
	is_grounded = false
	$PlayerParticles/DustTrail.emitting = false
	$Body/AnimationPlayer.play("Player_Jump")
	$CoyoteTimer.stop()

func _on_Movement_enter_left():
	if is_grounded:
		$Body/AnimationPlayer.play("Player_Run")
		$PlayerParticles/DustTrail.emitting = true
	else:
		$Body/AnimationPlayer.play("Player_FallingSide")
	$Body.scale.x = -1
	$PlayerParticles/DustTrail.process_material.direction.x = 1

func _on_Movement_enter_right():
	if is_grounded:
		$Body/AnimationPlayer.play("Player_Run")
		$PlayerParticles/DustTrail.emitting = true
	else:
		$Body/AnimationPlayer.play("Player_FallingSide")
	$Body.scale.x = 1
	$PlayerParticles/DustTrail.process_material.direction.x = -1

func _on_AnimationPlayer_animation_finished(name):
	if name == "Player_Jump":
		$Body/AnimationPlayer.play("Player_Falling")
	elif name == "Player_Landing":
		if is_idle:
			$Body/AnimationPlayer.play("Player_Idle")
		else:
			$Body/AnimationPlayer.play("Player_Run")
	elif name == "Player_DeathGround" or name == "Player_DeathAir":
		restart()

func _on_Shotgun_shot_fired(parent, _roation):
	$Body/Arm/Shotgun.visible = true
	$Body/Arm/Pistol.visible = false
	active_gun = $Body/Arm/Shotgun

func _on_Pistol_shot_fired(parent, _rotation):
	$Body/Arm/Shotgun.visible = false
	$Body/Arm/Pistol.visible = true
	$Body/Arm/bulletshell.emitting = true
	active_gun = $Body/Arm/Pistol

func pause():
	set_process(false)
	set_process_input(false)
	set_physics_process(false)
	pause_animation()
	$CoyoteTimer.pause_mode = true
	if decrease_music_volume_on_pause:
		$MusicPlaylist.get_current_song().volume_db = linear2db(db2linear($MusicPlaylist.get_current_song().volume_db) * music_volume_pause_multiplier)

func unpause():
	set_process(true)
	set_process_input(true)
	set_physics_process(true)
	unpause_animation()
	$CoyoteTimer.pause_mode = false
	if decrease_music_volume_on_pause:
		$MusicPlaylist.get_current_song().volume_db = linear2db(db2linear($MusicPlaylist.get_current_song().volume_db) / music_volume_pause_multiplier)

func _on_OptionsMenu_toggle_screen_shake(state):
	get_node(camera_path).enable_screen_shake = state

func set_touching_enemies(value):
	for enemy in value:
		if not touching_enemies.has(enemy):
			take_damage(enemy.touch_damage)
			break
	touching_enemies = value
	$TouchDamageTimer.start()

func _on_TouchDamageTimer_timeout():
	for enemy in touching_enemies:
		take_damage(enemy.touch_damage)


func _on_AnimationPlayer_animation_changed(old_name, new_name):
	$Body/AnimatedSprite.frame = 0
	$Body/AnimatedSprite.playing = false


func _on_AnimatedSprite_animation_finished():
	if current_health <= 0:
		$Body/AnimatedSprite.playing = false
		if $Body/AnimatedSprite.animation == "DeathGround":
			$Body/AnimatedSprite.frame = 22
		elif $Body/AnimatedSprite.animation == "DeathAir":
			$Body/AnimatedSprite.frame = 18
