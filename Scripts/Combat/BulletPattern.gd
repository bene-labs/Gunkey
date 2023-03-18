class_name BulletPattern extends Node2D

export (int) var chance = 100

# The next shot of the AutoShooter will be delayed by this amount in additon of the regular shot_delay
export var additional_auto_shooter_cooldown = 0.0

var bullets = []

func get_bullets():
	return bullets

func _ready():
	for child in get_children():
		if child is Projectile:
			bullets.append(child)
			remove_child(child)

func get_cooldown() -> float:
	return additional_auto_shooter_cooldown

func shoot(spawn_positon, aim_rotation, offset = 0, friendly = false) -> bool:
	if len(bullets) == 0:
		return false
	for bullet_template in bullets:
		var bullet = bullet_template.duplicate()
		var new_position = spawn_positon
		bullet.setup(owner)
	
		if not bullet.ignore_relative_position:
			new_position += bullet.position
		bullet.global_position = new_position
		bullet.friendly = friendly
		bullet.rotation += aim_rotation
		if offset != 0:
			bullet.position += Vector2(offset, 0).rotated(bullet.rotation)
		get_tree().root.get_child(3).call_deferred("add_child", bullet)
	return true

func get_aim_rotations() -> Array:
	var result = []
	for bullet_template in bullets:
		result.append(bullet_template.rotation)
	return result
