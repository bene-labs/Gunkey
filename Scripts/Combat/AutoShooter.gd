class_name AutoShooter extends Node2D

export (bool) var aim_at_target = false

var aim_rotation = 0

# if 0 sequence count is used, if < 0 size is unlimeted
var ammo_count
export var max_ammo = -1

var patterns = []
var shoot_index = 0 setget set_shoot_index, get_shoot_index

# delay between each assigned pattern
export var minimum_shot_delay = 2.0
# delay after ammo is exhausted
export var reload_time = 2.0

var shoot_timer : Timer
var reload_timer : Timer

var total_chance = 0

var is_active = true

func set_shoot_index(value):
	if value < len(patterns):
		shoot_index = value
	else:
		shoot_index = 0
	
func get_shoot_index():
	return shoot_index

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	for bullet_pattern in get_children():
		if bullet_pattern is BulletPattern:
			patterns.append(bullet_pattern)
	if len(patterns) <= 0:
		queue_free()
		return
	
	if minimum_shot_delay > 0:
		shoot_timer = Timer.new()
		shoot_timer.autostart = true 
		shoot_timer.wait_time = minimum_shot_delay
		shoot_timer.connect("timeout", self, "_on_shoot_timer_timeout")
		shoot_timer.name = "ShootTimer"
		add_child(shoot_timer)
	
	if reload_time > 0:
		reload_timer = Timer.new()
		reload_timer.one_shot = true
		reload_timer.wait_time = reload_time
		reload_timer.connect("timeout", self, "_on_reload_timer_timeout")
		reload_timer.name = "ReloadTimer"
		add_child(reload_timer)
	
	ammo_count = max_ammo
	
	total_chance = get_total_chance()

func get_total_chance() -> int:
	total_chance = 0
	for pattern in patterns:
		total_chance += pattern.chance
	return total_chance

func get_current_bullet_pattern():
	return patterns[shoot_index]

func get_aim_rotation():
	if not "aim_rotation" in get_parent():
		return 0
	return get_parent().aim_rotation

func shoot():
	if aim_at_target:
		aim_rotation = get_aim_rotation()
	while len(patterns) > 1 and patterns[shoot_index].chance <= randi() % 100:
		shoot_index += 1
		if shoot_index >= len(patterns):
			shoot_index = 0
	patterns[shoot_index].shoot(global_position, aim_rotation)
	ammo_count -= 1
	if max_ammo >= 0 and ammo_count <= 0:
		is_active = false
		shoot_timer.stop()
		reload_timer.start()
	else:
		shoot_timer.wait_time = minimum_shot_delay + patterns[shoot_index].get_cooldown()
		shoot_timer.start(shoot_timer.wait_time)
	set_shoot_index(shoot_index + 1)

func _on_shoot_timer_timeout():
	shoot()
	
func _on_reload_timer_timeout():
	ammo_count = max_ammo
	shoot_timer.start()
	is_active = true

func stop():
	shoot_timer.stop()
	reload_timer.stop()
	set_process(false)
	
func reset():
	set_shoot_index(0)
	ammo_count = 0
	shoot_timer.stop()
	reload_timer.start()
	
func pause():
	set_process(false)
	shoot_timer.paused = true
	reload_timer.paused = true
	
func unpause():
	set_process(true)
	shoot_timer.paused = false
	reload_timer.paused = false
