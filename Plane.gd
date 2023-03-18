extends ParallaxLayer

export(float) var plane_speed = -15

func _process(delta): 
	self.motion_offset.x += plane_speed * delta
	pass

func pause():
	set_process(false)
	
func unpause():
	set_process(true)
