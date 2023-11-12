class_name GroundedEnemy extends KinematicBody2D


enum MovementType{
	STOP,
	STROLL,
	FOLLOW_OR_STOP,
	FOLLOW_OR_STROLL
}

export (NodePath) var target_path = ""
#export var acceleration = 50.0
#export var break_force = 50.0
#export var max_speed = 300.0

export var randomize_speed = false
export var min_speed_rand = 69.0
export var max_speed_rand = 420.0
export var touch_damage = 2

export var current_health = 100
export var max_health = 100

export var use_invicibility_frames = true
export var friendly = false

export (Movement.Direction) var direction = Movement.Direction.LEFT
export (bool) var turn_before_obstacle = true
export (bool) var turn_before_gap = true
#export (MovementType) var movement_type = MovementType.STROLL
#export var gravity_force = 9.81

var target = null
var aim_rotation = 0
#var velocity = Vector2.ZERO

var is_invincible = false
var is_attack = false

var is_grounded = false
var is_dead = false

export var path = "res://GroundedEnemy.tscn"
onready var construction_data = {"Path": path, "Position": global_position, "Type": "Walker", "Direction": direction}

export (PackedScene) var damage_nb_vfx = preload("res://VFX/vfx_DamageNumbers.tscn")

export (bool) var move_on_ground_only = true 

export (bool) var enable_knockback = false

signal died

func get_construction_data():
	return construction_data

func reset_animation():
	$AnimatedSprite.frame = 0
	$AnimatedSprite.playing = true
	
func _ready():
	reset_animation()
	
	if not enable_knockback:
		remove_from_group("Pushable")
	
	if randomize_speed:
		$Movement.max_move_speed = rand_range(min_speed_rand, max_speed_rand)
	
	if target_path != "":
		target = get_node(target_path)
	else:
		target = get_tree().current_scene.get_node("Player")
	
	connect("died", get_tree().current_scene.get_node("Player").get_node("Camera2D").get_node("CanvasLayer").get_node("KillCount"), "on_kill")
	$HealthBar.max_value = max_health
	$HealthBar.value = current_health
	
	if direction == Movement.Direction.LEFT:
		scale.x *= -1
	rotation_degrees = 0
#	print(name, ": ", base_stats["Position"])
#	print(name, ": ", base_stats["Direction"])

func get_move_velocity_towards(goal):
	push_error("Following player not yet implemented!")
	return Vector2.ZERO

func _process(delta):
	pass
	
func _physics_process(delta):
	if not is_attack:
		$Movement.process(direction)
#	if not move_on_ground_only or is_grounded:
#		if abs(velocity.x) < max_speed:
#			velocity.x += acceleration * (1 if direction == Movement.Direction.RIGHT else -1)
#			if abs(velocity.x) > max_speed:
#				velocity.x = max_speed * (1 if direction == Movement.Direction.RIGHT else -1)
#
#	velocity.y += gravity_force
#	velocity = move_and_slide(velocity)

func _on_HurtBox_body_entered(body):
	if "touching_enemies" in body and body.get("friendly") == true:
		is_attack = true
		body.touching_enemies = body.touching_enemies + [self]
		$AnimationPlayer.play("Attack")

func _on_HurtBox_body_exited(body):
	if "touching_enemies" in body and body.get("friendly") == true:
		is_attack = false
		body.touching_enemies.erase(self)
		$AnimatedSprite.play("Walk")
		$AnimatedSprite.offset = Vector2.ZERO

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
	is_dead = true
	$AnimationPlayer.play("Death")
	emit_signal("died")

func flip_direction():
	direction = Movement.Direction.LEFT if direction == Movement.Direction.RIGHT else Movement.Direction.RIGHT
	scale.x *= -1
#	velocity.x += (break_force if break_force < velocity.x else velocity.x) * -1 if direction == Direction.LEFT else 1
#	$HealthBar.rect_scale.x *= -1
#	print(name, ": turned ", "left" if direction == Movement.Direction.LEFT else "right")

func _on_ObstacleDetector_obstacle_hit(body):
	if move_on_ground_only and not is_grounded:
		return
	
	if turn_before_obstacle and body != self:
		if body is Player:
			body.take_damage()
		flip_direction()

func _on_ObstacleDetector_gap_detected():
	if move_on_ground_only and not is_grounded:
		return
	
	if  turn_before_gap:
		flip_direction()

func pause_animation():
	$AnimatedSprite.playing = false
	$AnimationPlayer.playback_active = false

func unpause_animation():
	$AnimatedSprite.playing = true
	$AnimationPlayer.playback_active = true

func pause():
	pause_animation()
	set_process(false)
	set_physics_process(false)
	
func unpause():
	unpause_animation()
	if not is_dead:
		set_process(true)
		set_physics_process(true)


func _on_FeetArea_body_entered(body):
	is_grounded = true

func _on_FeetArea_body_exited(body):
	is_grounded = false
	

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Death":
		$AnimatedSprite.hide()
		$HealthBar.hide()
		$HealthBar.hide()
		$Explosive.explode(self)
