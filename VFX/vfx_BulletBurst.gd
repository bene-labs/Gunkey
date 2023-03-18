extends Particles2D

func _on_LifeTimer_timeout():
	queue_free()

func pause():
	$LifeTimer.paused = true
	speed_scale = 0
	
func unpause():
	$LifeTimer.paused = false
	speed_scale = 1
