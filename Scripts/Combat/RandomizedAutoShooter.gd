extends Node2D

export (bool) var aim_at_target = false

var aim_rotation = 0

# if 0 sequence count is used, if < 0 size is unlimeted
var ammo_count
export var max_ammo = -1

var patterns = []
var shoot_index = 0


# delay between each assigned pattern
export var minimum_shot_delay = 1.0
# delay after ammo is exhausted
export var reload_time = 2.0

var shoot_timer : Timer
var reload_timer : Timer

var total_chance = 0

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

func shoot():
	if aim_at_target:
		aim_rotation = get_parent().aim_rotation
	var rand_index = randi() % total_chance
	var chance_index = 0
	for pattern in patterns:
		chance_index += pattern.chance
		if chance_index >= rand_index:
			pattern.shoot(global_position, aim_rotation)
			break
	ammo_count -= 1
	if max_ammo >= 0 and ammo_count <= 0:
		shoot_timer.stop()
		reload_timer.start()
	else:
		shoot_timer.wait_time = minimum_shot_delay + patterns[shoot_index].get_cooldown()

func _on_shoot_timer_timeout():
	shoot()
	
func _on_reload_timer_timeout():
	ammo_count = max_ammo
	shoot_timer.start()

func stop():
	shoot_timer.stop()
	reload_timer.stop()

func pause():
	shoot_timer.paused = true
	reload_timer.paused = true
	
func unpause():
	shoot_timer.paused = false
	reload_timer.paused = false
