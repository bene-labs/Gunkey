extends ParallaxLayer

export(float) var cloud_speed = -15

func _process(delta): 
	self.motion_offset.x += cloud_speed * delta
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Processing")
