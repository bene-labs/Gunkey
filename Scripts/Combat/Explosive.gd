extends Node2D

export var damage_to_friendly = 10.0
export var damage_to_unfriendly = 10.0
export var explosion_range = 300.0

export (Curve) var damage_over_distance = Curve.new()
export (Curve) var knockback_over_distance = Curve.new()

export var explosion_base_width = 60

var queued_to_destroy = null

export var is_ready = false

func _ready():
	if is_ready:
		return
	$Explosion.scale *= (explosion_range * 2) / explosion_base_width
	$ParticleTimer.wait_time = $Explosion.lifetime
	is_ready = true

func apply_damage_by_distance(target, distance):
	if not target.has_method("take_damage"):
		return
	if target.friendly:
		target.take_damage(damage_to_friendly * damage_over_distance.interpolate(distance / explosion_range))
	else:
		target.take_damage(damage_to_unfriendly * damage_over_distance.interpolate(distance / explosion_range))

func apply_knockback_by_distance(target, distance):
	var force = knockback_over_distance.interpolate(distance / explosion_range)
	var prev_rotation = $AnimatedSprite.rotation
	$AnimatedSprite.look_at(target.global_position)
	$Knockback.apply_knockback(target.get_node("Movement"), $AnimatedSprite.global_rotation, force)
	$AnimatedSprite.rotation = prev_rotation
	
func explode(to_destroy = null):
	if to_destroy is NodePath or to_destroy is String:
		to_destroy = get_node(to_destroy)
	
	if to_destroy == queued_to_destroy:
		return
	
	queued_to_destroy = to_destroy

	for target in get_tree().get_nodes_in_group("Destructible"):
		if target == get_parent():
			continue
		var distance = global_position.distance_to(target.global_position)
		
		if distance <= explosion_range:
			apply_damage_by_distance(target, distance)
			
	for target in get_tree().get_nodes_in_group("Pushable"):
		if target == get_parent():
			continue
		var distance = global_position.distance_to(target.global_position)
		
		if distance <= explosion_range:
			apply_knockback_by_distance(target, distance)
	$AudioStreamPlayer2D.play()
	$Explosion.emitting = true
	$ParticleTimer.start()

func _on_ParticleTimer_timeout():
	if queued_to_destroy != null:
		queued_to_destroy.queue_free()

func pause():
	$Explosion.speed_scale = 0
	$ParticleTimer.paused = true
	
func unpause():
	$Explosion.speed_scale = 1
	$ParticleTimer.paused = false
