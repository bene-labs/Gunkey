extends Node2D

# is this shot guarranted to appear?
# export (bool) var is_fixed = true 
# how often should this bullet appear
# if Autoshooters is set to fixed sequence = how likley is this out of 100 not to be skipped
export (int) var chance = 100

# directions that the bullets should be fired at
# if the autoshooters aims at a target, the rotation will be added to the aim 
export var bullet_rotations = [0]
export var bullets = [preload("res://Projectile.tscn")]
# should each shot bullet use the corresponding bullet scene or should all use the first entry 
# in the bullets array only?
export (bool) var use_different_bullets = false
export (bool) var overwritte_bullet_properties = true
export var bullet_properties = [{"speed": 300, "damage": 3, "range": 800, "size": 1.0}]

func _ready():
	pass

func shoot(spawn_positon, target = null, friendly = false) -> bool:
	for i in range(len(bullet_rotations)):
		var bullet : Projectile
		if use_different_bullets:
			bullet = bullets[i].instance()
		else:
			bullet = bullets[0].instance()
		bullet.global_position = spawn_positon
		bullet.friendly = friendly
		if target != null:
			bullet.get_node("Sprite").look_at(target.global_position)
			#bullet.get_node("Sprite").global_rotation_degrees -= 45
		bullet.get_node("Sprite").rotation_degrees += bullet_rotations[i]
		var bullet_property = bullet_properties[i] if use_different_bullets else bullet_properties[0] 
		if overwritte_bullet_properties:
			bullet.setup(self, bullet_property["speed"], bullet_property["damage"], bullet_property["range"], bullet_property["size"])
		 get_tree().current_scene.call_deferred("add_child", bullet)
	return true
