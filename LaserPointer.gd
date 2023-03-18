extends Polygon2D

export var visual_extension = 20

func _ready():
	if not "target" in get_parent():
		push_error("LaserPoint must have a parent with an target!")
#		queue_free()
#	$RayCast2D.add_exception(self)
#	$RayCast2D.add_exception(get_parent().target)

func _process(delta):
	update()

func update():
	var target = get_parent().target
	
	if "global_position" in target:
		var goal = Vector2.ZERO
#		$RayCast2D.rotation = 0
		$RayCast2D.cast_to = to_local(target.global_position)
		$RayCast2D.force_raycast_update()
		if $RayCast2D.is_colliding():
			goal = $RayCast2D.get_collision_point()
#		else:
#			goal = target.global_position
		
		var length = global_position.distance_to(goal) + visual_extension
		look_at(goal)
		polygon[2].x = length
		polygon[3].x = length
