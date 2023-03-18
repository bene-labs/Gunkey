extends AudioStreamPlayer2D

export var min_pitch = 1.0
export var max_pitch = 1.5

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

func play(from_position = 0.0):
	pitch_scale = rand_range(min_pitch, max_pitch)
	.play(from_position)
