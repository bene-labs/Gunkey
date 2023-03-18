extends Area2D

export var _range = 100
export (bool) var overwrite_knockback_force = false
export (Curve) var knockback_over_distance = Curve.new()
var pushed_bodies = []

func _ready():
	var range_difference = _range - $CollisionShape2D.shape.extents.y
	
	$WindParticles.scale.y *= _range / 84
	var new_rect = RectangleShape2D.new()
	new_rect.extents = $CollisionShape2D.shape.extents
	new_rect.extents.y *= _range / ($CollisionShape2D.shape.extents.y * 2)
	$CollisionShape2D.shape = new_rect
	$CollisionShape2D.position.y = -$CollisionShape2D.shape.extents.y
	
	if overwrite_knockback_force:
		knockback_over_distance.bake()

func _process(delta):
	for body in pushed_bodies:
		if not overwrite_knockback_force:
			$Knockback.apply_knockback(body, global_rotation + TAU * 0.25)
		else:
			var distance = global_position.distance_to(body.global_position)
			$Knockback.apply_knockback(body.get_node("Movement"), global_rotation + TAU * 0.25, knockback_over_distance.interpolate(distance / _range))


func _on_Wind_body_entered(body):
	if body.is_in_group("Pushable"):
		if body.has_method("set_is_inside_wind"):
			body.set_is_inside_wind(true)
		pushed_bodies.append(body)


func _on_Wind_body_exited(body):
	if body.has_method("set_is_inside_wind"):
		body.set_is_inside_wind(false)
	pushed_bodies.erase(body)

func pause_animation():
	$WindParticles.speed_scale = 0
	$FanDust.speed_scale = 0
		
func unpause_animation():
	$WindParticles.speed_scale = 1
	$FanDust.speed_scale = 1

func pause():
	set_process(false)
	pause_animation()
	
func unpause():
	set_process(true)
	unpause_animation()
