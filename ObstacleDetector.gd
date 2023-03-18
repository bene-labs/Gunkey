extends Node2D

signal obstacle_hit
signal gap_detected

func reset():
	$RegainGroundTimer.stop()

func _on_ObstacleDetection_body_entered(body):
	if not body is Projectile:
		emit_signal("obstacle_hit", body)

func _on_GapDetection_body_exited(body):
	$RegainGroundTimer.start()

func _on_RegainGroundTimer_timeout():
	if len($GapDetection.get_overlapping_bodies()) == 0:
		emit_signal("gap_detected")
