class_name Knockback extends Node2D

export var knockback_force = 20.0
export var horizontal_multiplier = 1.0
export var vertical_multiplier = 1.0

# 1 equals the same horizontal knockback on the floor as in the air
# < 1 means less knockback than in the air and > 1 means more knockback than in the air
export var movement_counter_force = 1.0
export var gravity_counter_force = 0.85

export var ground_multiplier = 1.0
export var steady_ground_multiplier = 1.0
export var air_multiplier = 1.0

export (Curve) var horizontal_knockback_multiplier_by_XVelocity = Curve.new()
export (Curve) var vertical_knockback_multiplier_by_YVelocity = Curve.new()

export var is_reverse = true
export var debug = false

func apply_knockback(target: Movement, direction = 0, force = knockback_force):
	if not target is Movement:
		push_error("Cannot apply knockback to '" + target.name + "': invalid type!")
	
	force = Vector2(force, 0).rotated(direction)
	if is_reverse:
		force *= -1
	var counter_force =  Vector2.ZERO
	if ((force.x > 0 and target.direction == Movement.Direction.LEFT) or (force.x < 0 and target.direction == Movement.Direction.RIGHT)):
		if abs(force.x) > target.knockback_resitance:
			target._on_counter_move_knockback(movement_counter_force)

	counter_force.y = -target.velocity.y * gravity_counter_force if target.velocity.y > 0 else 0
	force += counter_force
	force.x *= horizontal_multiplier
	force.y *= vertical_multiplier
	if target.is_grounded:
		force.x *= ground_multiplier
		force.y *= ground_multiplier
		if target.direction == target.Direction.NONE:
			force.x *= steady_ground_multiplier
			force.y *= steady_ground_multiplier
	else:
		force.x *= air_multiplier
		force.y *= air_multiplier
		
	var vel = target.velocity
	if (force.x > 0 and target.velocity.x > 0) or (force.x < 0 and target.velocity.x < 0):
		if debug:
			print("X-Knockback Speed Multiplier: ", horizontal_knockback_multiplier_by_XVelocity.interpolate( abs(target.velocity.x) /target.horizontal_speed_limit))
		force.x *= horizontal_knockback_multiplier_by_XVelocity.interpolate( abs(target.velocity.x) /target.horizontal_speed_limit)
	if (force.y > 0 and target.velocity.y > 0) or (force.x < 0 and target.velocity.y < 0):
		if debug:
			print("Y-Knockback Speed Multiplier: ", vertical_knockback_multiplier_by_YVelocity.interpolate(abs(target.velocity.y) / target.vertical_speed_limit))
		force.y *= vertical_knockback_multiplier_by_YVelocity.interpolate(abs(target.velocity.y) / target.vertical_speed_limit)
	target.velocity += force
