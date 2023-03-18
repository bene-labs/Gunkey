extends Node2D

export var health = 1

var friendly = false

func explode():
	$CollisionShape2D.queue_free()
	$Explosive.explode(self)
	
func take_damage(damage = 1):
	if health <= 0:
		return
	health -= damage
	
	if health <= 0:
		explode()
		$Sprite.hide()
