class_name Projectile extends Area2D

export var move_speed = 300
export var damage = 1
export var max_range = 500
export var size = 1.0

export var emit_shells = false
export (bool) var friendly = true

# IMPORTANT: Only takes effect when spawning via AutoShooter
export (bool) var ignore_relative_position = true

export (PackedScene) var burst_vfx = preload("res://VFX/vfx_BulletBurst.tscn")

var creator = null
var traveled_distance = 0

var size_set = false

func _ready():
	if emit_shells:
		$BulletShell.emitting = true
	$MuzzleFlash.emitting = true

func set_size(value):
	if size_set:
		push_error("Bullet Size can only be set once!")
		return
	size = value
	$Sprite.scale *= size
	$CollisionPolygon2D.scale *= size
	$Sprite/BulletTrail.scale *= size
	size_set = true

# todo: implement properly
#func _init():
#	if ignore_relative_position:
#		position = Vector2.ZERO

func simple_setup(owner):
	creator = owner
	set_size(size)

func setup(owner, speed = null, new_damage = null, new_range = null, new_size = null):
	creator = owner
	if speed != null: move_speed = speed
	if new_damage != null: damage = new_damage
	if new_range != null: max_range = new_range
	set_size(new_size if new_size != null else size)

func _process(delta):
	var velocity = Vector2(move_speed * delta, 0).rotated($Sprite.global_rotation)
	position += velocity
	traveled_distance += velocity.length()
	if traveled_distance >= max_range:
		die()

func die():
	var burst = burst_vfx.instance()
	burst.self_modulate = $Sprite.self_modulate
	burst.global_position = global_position
	get_tree().root.get_child(3).add_child(burst)
	queue_free()

func _on_Projectile_body_entered(body):
#	print(body.name)
	if body.has_method("take_damage") and body != creator and (body.get("friendly") == null or body.friendly != friendly):
		body.take_damage(damage)
	if body != creator and (body.get("friendly") == null or body.friendly != friendly):
		die()

func pause_animation():
	$Sprite/BulletTrail.speed_scale = 0
	$BulletSparks.speed_scale = 0

func unpause_animation():
	$Sprite/BulletTrail.speed_scale = 4.34
	$BulletSparks.speed_scale = 1
	
func pause():
	set_process(false)
	pause_animation()
	
func unpause():
	set_process(true)
	unpause_animation()
