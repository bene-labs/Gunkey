extends StaticBody2D

export (NodePath) var target_path = ""
export var move_speed = 300
export var touch_damage = 2

export var current_health = 100
export var max_health = 100
export var invicibility_time = 0.2

export var use_invicibility_frames = true
export var friendly = false

export var sprite_rotation = 0

export (bool) var look_at_target = true 
var target = null
var aim_rotation = 0

export (PackedScene) var damage_nb_vfx = preload("res://VFX/vfx_DamageNumbers.tscn")

export var is_invincible = false
var is_idle = false

var is_armed = false
var is_agressive = false

export var path = "res://EnemyScenes/ImmovableEnemy.tscn"
onready var construction_data = {"Path": path, "Position": global_position, "Type": "Turret", "SpriteRotation": sprite_rotation}

signal died

func get_construction_data():
	return construction_data

func _ready():
	$AnimatedSprite.rotation_degrees = sprite_rotation
	
	if get_node_or_null("VisualAutoShooter") != null:
		is_armed = true
		is_agressive = true
	
	if target_path != "":
		target = get_node(target_path)
	else:
		target = get_tree().root.get_child(3).get_node("Player")
	
	connect("died", get_tree().root.get_child(3).get_node("Player").get_node("Camera2D").get_node("CanvasLayer").get_node("KillCount"), "on_kill")
	$HealthBar.max_value = max_health
	$HealthBar.value = current_health
	
	AnimationHelper.reconfige_even_timed_animation_lenght($AnimationPlayer.get_animation("take_damage"), invicibility_time, [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9])

func get_aim_rotation(goal):
	var result = 0
	var prev_rotation = $AnimatedSprite.rotation
	$AnimatedSprite.look_at(target.global_position)
	result = $AnimatedSprite.rotation
	if not look_at_target:
		$AnimatedSprite.rotation = prev_rotation
	return result

func _process(delta):
	if target != null:
		aim_rotation = get_aim_rotation(target)
	if is_armed and $VisualAutoShooter.is_active != is_agressive:
		is_agressive = $VisualAutoShooter.is_active
		$AnimationPlayer.play("Agressive") if is_agressive else $AnimationPlayer.play("Idle")

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
		
	$AnimationPlayer.play("Death")
	emit_signal("died")
	
func pause_animation():
	$AnimatedSprite.playing = false
	$AnimationPlayer.playback_active = false

func unpause_animation():
	$AnimatedSprite.playing = true
	$AnimationPlayer.playback_active = true

func pause():
	pause_animation()
	set_process(false)
	
func unpause():
	unpause_animation()
	set_process(true)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "take_damage" or anim_name == "RESET":
		$AnimationPlayer.play("Agressive") if is_agressive else $AnimationPlayer.play("Idle")
	elif anim_name == "Death":
		$AnimatedSprite.hide()
		$HealthBar.hide()
		if is_armed:
			$VisualAutoShooter.stop()
			$VisualAutoShooter.hide()
		$Explosive.explode(self)
