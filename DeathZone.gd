extends Area2D

export var is_insta_kil = true
export var damage_friendly = true
export var damage_enemy = true
export var damage = 5

func _on_DeathZone_body_entered(body):
	if body is Player and is_insta_kil:
		body.die()
	elif body.has_method("take_damage") and \
	(body.get("friendly") == true and damage_friendly) or \
	(body.get("friendly") == false and damage_enemy):
		body.take_damage(damage)
