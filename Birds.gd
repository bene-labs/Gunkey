extends ParallaxLayer

export(float) var bird_speed = -15

func _process(delta): 
	self.motion_offset.x += bird_speed * delta
	self.motion_offset.y += bird_speed * delta
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Processing")


