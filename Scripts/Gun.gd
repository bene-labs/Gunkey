extends AnimatedSprite

class_name Gun

enum Role{
	UNEQUIPPED,
	PRIMARY,
	SECONDARY
}



export (Role) var role = Role.UNEQUIPPED

export (PackedScene) var projectile_scene = preload("res://Projectile.tscn")

export (NodePath) var user_path
export (NodePath) var stat_display

export var bullets_per_shot = 1
# how fast the bullets should move in the air
export var bullet_speed = 300
# how much damage do the bullets deal?
export var bullet_damage = 3

# how far can the bullets travel?
export var max_range = 600

# how far the bullets should be spread, only takes effect with > 1 bullet
export var bullet_spread_degrees = 365.0 * 0.25
# how many degrees at most should the bullets randomly go below their target?
export var min_offset = -20
# how many degrees at most should the bullets randomly go above their target?
export var max_offset = 20
# how many bullets are fired per second
export var shot_delay = 0.25
# does this gun have to reload?
export (bool) var is_ammo_infinite = false
# how many bullets can be fired before reloading, set infinite_ammo to true to ignore this
export var max_ammo = 10
# bullets remaing until next reload
var ammo_count = 10 setget set_ammo_count
# the delay in seconds before the gun can shot again after running out of ammo
export var reload_time = 2.0
# is restoring your ammo in the air allowed?
export (bool) var allow_reload_in_air = false
export (bool) var allow_reload_in_wind = true
# should the reload time be decreased in the air, even if it can only be restored on the floor?
export (bool) var enable_passive_air_reload = true

export var screen_shake_strength = 20
export var screen_shake_speed = 0.1
export var screen_shake_duration = 0.5

var is_shot_on_cooldown = false
var is_reloading = false
var is_reload_queued = false
var was_reload_started_on_ground = false

var shot_cooldown_timer = Timer.new()
var reload_timer = Timer.new()

signal shot_fired

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	if shot_delay > 0:
		shot_cooldown_timer = Timer.new()
		shot_cooldown_timer.one_shot = true
		shot_cooldown_timer.wait_time = shot_delay
		shot_cooldown_timer.connect("timeout", self, "_on_shot_cooldown_timer_timeout")
		shot_cooldown_timer.name = "ShotCooldownTimer"
		add_child(shot_cooldown_timer)
	
	if reload_time > 0:
		reload_timer = Timer.new()
		reload_timer.one_shot = true
		reload_timer.wait_time = reload_time
		reload_timer.connect("timeout", self, "_on_reload_timer_timeout")
		reload_timer.name = "ReloadTimer"
		add_child(reload_timer)
	
	ammo_count = max_ammo
	
	
func _process(delta):
	if Input.is_action_just_pressed("reload") and not is_reload_queued:
		was_reload_started_on_ground = (get_node(user_path).has_method("get_is_grounded") and get_node(user_path).get_is_grounde())
		reload()
	if role == Role.PRIMARY and Input.is_action_pressed("shoot_primary") or \
	role == Role.SECONDARY and Input.is_action_pressed("shoot_secondary"):
		if ammo_count < bullets_per_shot:
			if is_reload_queued:
				pass
			else:
				reload()
		elif not is_shot_on_cooldown:
			shoot()
		
	if is_reload_queued and \
	(((get_node(user_path).has_method("get_is_grounded") and get_node(user_path).get_is_grounded()) or allow_reload_in_air) or \
	((get_node(user_path).has_method("get_is_inside_wind") and get_node(user_path).get_is_inside_wind() == true)) or was_reload_started_on_ground):
		ammo_count = max_ammo
		was_reload_started_on_ground = false
		is_reload_queued = false
			
func set_ammo_count(count):
	ammo_count = count
	if ammo_count <= 0:
		ammo_count = 0

func reload():
	if get_node(user_path).has_method("get_is_grounded"):
		if not allow_reload_in_air and not get_node(user_path).get_is_grounded():
			if not enable_passive_air_reload:
				return
#	if get_node(user_path).has_method("get_is_inside_wind"):
#		if not allow_reload_in_wind and get_node(user_path).get_is_inside_wind() == false:
#			if not enable_passive_air_reload:
#				return
	ammo_count = 0
	if reload_time == 0:
		is_reload_queued = true
	elif $ReloadTimer.is_stopped():
		$ReloadSound.play()
		is_reloading = true
		$ReloadTimer.start()
	
func shoot():
	var angle = -bullet_spread_degrees / 2
	if ammo_count < bullets_per_shot:
		reload()
		return
	for i in range(bullets_per_shot):
		angle += bullet_spread_degrees / bullets_per_shot
		var projectile = projectile_scene.instance()
		projectile.global_position = $SpawnPosition.global_position
		projectile.get_node("Sprite").rotation_degrees = global_rotation_degrees
		projectile.get_node("Sprite").rotation_degrees += angle + rand_range(min_offset, max_offset)
		projectile.setup(self, bullet_speed, bullet_damage, max_range)
		get_tree().current_scene.call_deferred("add_child", projectile)
		ammo_count -= 1
		
#		get_node(user_path).apply_knockback(-Vector2(knockback_force, 0).rotated(global_rotation), \
#		gravity_counter_force_modifier, movement_counter_force, horizontal_knockback_multiplier, vertical_knockback_multiplier)
	if ammo_count < bullets_per_shot:
		reload()
	else:
		is_shot_on_cooldown = true
		shot_cooldown_timer.start()
	emit_signal("shot_fired", get_node(user_path).get_node("Movement"), global_rotation)
	$AudioStreamPlayer2D.play(0.16)
	get_node(get_node(user_path).camera_path).apply_shake(screen_shake_strength, screen_shake_speed, screen_shake_duration)

func _on_shot_cooldown_timer_timeout():
	is_shot_on_cooldown = false
	
func _on_reload_timer_timeout():
	is_reload_queued = true
	is_reloading = false

func pause():
	reload_timer.paused = true
	shot_cooldown_timer.paused = true
	set_process(false)
	
func unpause():
	reload_timer.paused = false
	shot_cooldown_timer.paused = false
	set_process(true)
