extends Particles2D

export var number_textures = []

func setup(nb):
	texture = number_textures[nb]

func _on_Timer_timeout():
	queue_free()

func pause():
	$Timer.paused = true
	speed_scale = 0

func unpause():
	$Timer.paused = false
	speed_scale = 1
