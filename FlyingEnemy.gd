extends KinematicBody2D

export (NodePath) var target_path = ""
export var move_speed = 300
export var randomize_speed = false
export var min_speed = 69.0
export var max_speed = 420.0
export var touch_damage = 2

export var current_health = 100
export var max_health = 100

export (PackedScene) var damage_nb_vfx = preload("res://VFX/vfx_DamageNumbers.tscn")

# unlimited if < 0
export var follow_range = -1
export (bool) var maintain_chase = true
export var use_invicibility_frames = true
export var friendly = false

export (bool) var look_at_target = true 
var target = null
var aim_rotation = 0
var velocity = Vector2.ZERO

var is_invincible = false
var is_idle = true
signal died
export var path = "res://FlyingEnemy.tscn"
onready var construction_data = {"Path": path, "Position": global_position, "Type": "Flying"}

func get_construction_data():
	return construction_data

func reset_animation():
	$AnimatedSprite.frame = 0
	$AnimatedSprite.playing = true
	$AnimatedSprite.play("Default")
	
func _ready():
	reset_animation()
	if randomize_speed:
		move_speed = rand_range(min_speed, max_speed)
	
	if target_path != "":
		target = get_node(target_path)
	else:
		target = get_tree().current_scene.get_node("Player")
	connect("died", get_tree().current_scene.get_node("Player").get_node("Camera2D").get_node("CanvasLayer").get_node("KillCount"), "on_kill")
	$HealthBar.max_value = max_health
	$HealthBar.value = current_health
	$AnimatedSprite.rotation_degrees = 0
#	print(name, ": ", base_stats["Position"])

func get_move_velocity_towards(goal):
	var prev_rotation = $AnimatedSprite.rotation
	$AnimatedSprite.look_at(target.global_position)
	aim_rotation = $AnimatedSprite.rotation
	var result = Vector2(move_speed, 0).rotated(aim_rotation)
	if not look_at_target:
		$AnimatedSprite.rotation = prev_rotation
	else:
		var rotation_d = int($AnimatedSprite.rotation_degrees) % 360
		if (rotation_d >= 45 and rotation_d <= 220) or (rotation_d <= -140 and rotation_d >= -310):
			$AnimatedSprite.flip_v = true
		else:
			$AnimatedSprite.flip_v = false
	return result

func _process(delta):
	if target:
		if follow_range < 0 or follow_range >= global_position.distance_to(target.global_position):
			if is_idle:
				is_idle = false
				$AnimatedSprite.play("StartHunt")
			velocity = get_move_velocity_towards(target)
		else:
			if not maintain_chase and not is_idle:
				is_idle = true
				$AnimatedSprite.play("Idle")
				velocity = Vector2.ZERO
	move_and_slide(velocity)

func _on_HurtBox_body_entered(body):
	if "touching_enemies" in body and body.get("friendly") == true:
		body.touching_enemies = body.touching_enemies + [self]

func _on_HurtBox_body_exited(body):
	if "touching_enemies" in body and body.get("friendly") == true:
		body.touching_enemies.erase(self)

func take_damage(damage = 1):
	if is_invincible or current_health <= 0:
		return
	current_health -= damage
	$HealthBar.value = current_health
	if damage >= 0 and damage <= 9:
		var new_damage_nb_vfx = damage_nb_vfx.instance()
		new_damage_nb_vfx.setup(damage)
		add_child(new_damage_nb_vfx)
	if use_invicibility_frames:
		 $AnimationPlayer.play("take_damage")
	if current_health <= 0:
		die()

func die():
	for child in get_children():
		if child.has_method("stop"):
			child.stop()
	
	$AnimationPlayer.play("die")
	emit_signal("died")

func pause_animation():
	$AnimatedSprite.playing = false
	
func unpause_animation():
	$AnimatedSprite.playing = true

func pause():
	pause_animation()
	set_process(false)
	
func unpause():
	unpause_animation()
	set_process(true)

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "StartHunt":
		$AnimatedSprite.play("Hunt")
