class_name Movement extends Node2D

enum Direction{
	NONE,
	LEFT,
	RIGHT
}

var velocity = Vector2.ZERO
var acceleration = 0
var direction = Direction.NONE

export (Curve) var acceleration_curve = Curve.new()
export var acceleration_time = 0.8
export var acceleration_maintain_time = 0.34
export (Curve) var air_resitance_curve = Curve.new()
export var max_move_speed = 400
export var horizontal_speed_limit = 1800
export var vertical_speed_limit = 2000
export var gravity_force = 9.81
export var jump_force = 240
export var ground_resitance = 25.0
export var brake_force = 150
export var knockback_resitance = 75.0
export (bool) var enable_acceleration_maintain_grace_period = true

var is_grounded = false

signal enter_idle
signal enter_right
signal enter_left
signal enter_jump

func _ready():
	if not get_parent() is KinematicBody2D:
		push_error("Invalid Movement usage: parent '" +  str(get_parent().name) + "' must be a KinematicBody2D.")
		queue_free()
		return 
	$AccelerationTimer.wait_time = acceleration_time
	$MantainAccelerationGracePeriodTimer.wait_time = acceleration_maintain_time
	acceleration_curve.bake()
	air_resitance_curve.bake()

func reset():
	velocity = Vector2.ZERO
	acceleration = 0
	direction = Direction.NONE
	is_grounded = false
	$AccelerationTimer.stop()
	$MantainAccelerationGracePeriodTimer.stop()

func process(new_direction, attempt_jump = false, apply_gravity = true):
	var body = get_parent()
	var temp = body.name
	is_grounded = get_parent().is_grounded
	if direction != new_direction and new_direction != Direction.NONE:
		if direction == Direction.NONE and not $AccelerationTimer.paused:
#			print("START")
			$AccelerationTimer.start()
		else:
#			print("cotinue Acc at ", $AccelerationTimer.time_left)
			$AccelerationTimer.paused = false
			$MantainAccelerationGracePeriodTimer.stop()
		if new_direction == Direction.LEFT:
			emit_signal("enter_left")
		else:
			emit_signal("enter_right")
		if direction != Direction.NONE:
			apply_break_force(brake_force)
			
	if new_direction != direction and new_direction == Direction.NONE:
		emit_signal("enter_idle")
		$AccelerationTimer.paused = true
		if enable_acceleration_maintain_grace_period:
#			print("Acc pause!")
			$MantainAccelerationGracePeriodTimer.start()
		else:
#			print("Acc restart!")
			$AccelerationTimer.stop()
		if body.is_on_floor() and velocity.x != 0:
			apply_break_force(brake_force)
	
	direction = new_direction
	if direction == Direction.LEFT:
		acceleration = acceleration_curve.interpolate(($AccelerationTimer.wait_time - $AccelerationTimer.time_left) / $AccelerationTimer.wait_time)
		if velocity.x >= -max_move_speed:
			velocity.x -= acceleration
	elif direction == Direction.RIGHT:
		acceleration = acceleration_curve.interpolate(($AccelerationTimer.wait_time - $AccelerationTimer.time_left) / $AccelerationTimer.wait_time)
		if velocity.x < max_move_speed:
			velocity.x += acceleration
		
	if attempt_jump and body.is_grounded:
		velocity.y -= jump_force
		emit_signal("enter_jump")
	
	velocity.y += gravity_force
	if velocity.x != 0:
		apply_break_force(ground_resitance if body.is_grounded else get_air_resitance())
	
	limit_x_velocity(horizontal_speed_limit)
	var remaining_vel = body.move_and_slide(velocity, Vector2.UP)
	velocity = remaining_vel if remaining_vel.length_squared() < velocity.length_squared() else velocity
	
func _on_counter_move_knockback(movement_counter_force = 1.0):
	velocity.x += acceleration * movement_counter_force * (-1 if velocity.x > 0 else 1)
	reset_acceleration()

func reset_acceleration():
	$AccelerationTimer.start()
	
func limit_x_velocity(max_speed):
	if abs(velocity.x) > horizontal_speed_limit:
		velocity.x = horizontal_speed_limit * (-1 if velocity.x < 0 else 1)

func apply_break_force(force):
	if force == 0:
		return
	var breaking_speed = force if velocity.x < 0 else force * -1
	if abs(breaking_speed) > abs(velocity.x):
			breaking_speed = -velocity.x
	velocity.x += breaking_speed
	
func get_air_resitance():
	return air_resitance_curve.interpolate(abs(velocity.x) / horizontal_speed_limit)

func _on_MantainAccelerationGracePeriodTimer_timeout():
	$AccelerationTimer.paused = false
	$AccelerationTimer.stop()
#	print("Acc restart!")
#	print("Stop!")

func _on_Parent_enter_floor():
	$MantainAccelerationGracePeriodTimer.paused = false

func _on_Parent_exit_floor():
	$MantainAccelerationGracePeriodTimer.paused = true

func pause():
	$AccelerationTimer.paused = true
	$MantainAccelerationGracePeriodTimer.paused = true
	
func unpause():
	$AccelerationTimer.paused = false
	$MantainAccelerationGracePeriodTimer.paused = false

