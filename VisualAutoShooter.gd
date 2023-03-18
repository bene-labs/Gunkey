class_name VisualAutoShooter extends AutoShooter

export (PackedScene) var barrel_scene = preload("res://Scripts/Combat/TurretBarrel.tscn")
onready var barrel_template = barrel_scene.instance()
export var barrel_appear_speed = 0.5
export var barrel_dissappear_speed = 0.5
export var barrel_shoot_pulsate_speed = 0.5
export var barrel_appear_delay = 0.5
export var barrel_dissappear_delay = 0.5

export (bool) var use_barrel_spawn_position = true
export (bool) var animate_reload = true

#export (bool) var animate_inital_shot = true

var barrels = []
var barrels_to_remove = []
var aim_direction = 0 setget set_aim_rotation
var is_barrel_respawn_queued = false

func set_shoot_index(value):
	if len(patterns) > 1 and value != shoot_index and ammo_count != 0:
		despawn_barrels(patterns[shoot_index])
	.set_shoot_index(value)

func despawn_barrels(pattern, queue_respawn = true):
	is_barrel_respawn_queued = queue_respawn
	for barrel in barrels:
		barrels_to_remove.append(barrel)
	$BarrelDissappearTimer.start()
	barrels.clear()

func spawn_barrels(pattern: BulletPattern, animate = true):
	for bullet in pattern.get_bullets():
		var new_barrel = barrel_template.duplicate()
		
#		var new_shoot_animation = AnimationHelper.generate_even_timed_animation_with_new_lenght( \
#		new_barrel.get_node("AnimationPlayer").get_animation("Shoot"), barrel_shoot_pulsate_speed, [0.25, 0.5])
#		new_barrel.get_node("AnimationPlayer").remove_animation("Shoot")
#		new_barrel.get_node("AnimationPlayer").add_animation("Shoot", new_shoot_animation)
		
		add_child(new_barrel)
		barrels.append(new_barrel)
		new_barrel.rotation = bullet.rotation
		if aim_at_target:
			new_barrel.rotation += get_aim_rotation()
		if animate:
			new_barrel.get_node("AnimationPlayer").play("Appear")

func _ready():
#	._ready()
	AnimationHelper.reconfige_animation_lenght(barrel_template.get_node("AnimationPlayer").get_animation("Appear"), barrel_appear_speed)
	AnimationHelper.reconfige_animation_lenght(barrel_template.get_node("AnimationPlayer").get_animation("Dissappear"), barrel_dissappear_speed)
	AnimationHelper.reconfige_even_timed_animation_lenght( \
	barrel_template.get_node("AnimationPlayer").get_animation("Shoot"), barrel_shoot_pulsate_speed, [0.25, 0.5])
	
	$BarrelAppearTimer.wait_time = barrel_appear_delay
	$BarrelDissappearTimer.wait_time = barrel_dissappear_delay
	spawn_barrels(get_current_bullet_pattern()) #, animate_inital_shot)
	
func set_aim_rotation(value):
	if not aim_at_target:
		push_warning("Cannot set aim rotation: aiming is disabled.")
		return
	
	for barrel in barrels:
		barrel.rotation -= aim_rotation
		barrel.rotation += value
	aim_rotation = value
	
func _process(delta):
	if aim_at_target:
		set_aim_rotation(get_aim_rotation())

func shoot():
#	.shoot()
	if aim_at_target:
		aim_rotation = get_parent().aim_rotation
	while len(patterns) > 1 and patterns[shoot_index].chance <= randi() % 100:
		shoot_index += 1
		if shoot_index >= len(patterns):
			shoot_index = 0
	if use_barrel_spawn_position:
		patterns[shoot_index].shoot(global_position, aim_rotation, barrels[0].get_node("SpawnPosition").position.x)
	else:
		patterns[shoot_index].shoot(global_position, aim_rotation)
	for barrel in barrels:
		barrel.get_node("AnimationPlayer").play("Shoot")
	ammo_count -= 1
	if max_ammo >= 0 and ammo_count <= 0:
		if animate_reload:
			despawn_barrels(get_current_bullet_pattern(), false)
		shoot_timer.stop()
		is_active = false
		reload_timer.start()
	else:
		shoot_timer.wait_time = minimum_shot_delay + patterns[shoot_index].get_cooldown()
		shoot_timer.start(shoot_timer.wait_time)
	$AudioStreamPlayer2D.play()
	set_shoot_index(shoot_index + 1)

func _on_reload_timer_timeout():
	if animate_reload:
		spawn_barrels(get_current_bullet_pattern())
	._on_reload_timer_timeout()

func _on_BarrelAppearTimer_timeout():
	spawn_barrels(get_current_bullet_pattern())

func _on_BarrelDissappearTimer_timeout():
	for barrel in barrels_to_remove:
		barrel.get_node("AnimationPlayer").play("Dissappear")
	barrels_to_remove.clear()
	if is_barrel_respawn_queued:
		is_barrel_respawn_queued = false
		$BarrelAppearTimer.start()

func pause():
	.pause()
	$BarrelDissappearTimer.paused = true
	$BarrelAppearTimer.paused = true
	
func unpause():
	.unpause()
	$BarrelDissappearTimer.paused = false
	$BarrelAppearTimer.paused = false

func stop():
	.stop()
	$BarrelDissappearTimer.stop()
	$BarrelAppearTimer.stop()
	
func reset():
	.reset()
	for barrel in barrels:
		barrel.queue_free()
	barrels.clear()
	for barrel in barrels_to_remove:
		barrel.queue_free()
	barrels_to_remove.clear()
