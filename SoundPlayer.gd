extends Node

onready var audioStreamPlayer = $SFX/AudioStreamPlayer

func play_sound():
	audioStreamPlayer.play 
	pass
	
	
func _physics_process(delta):
	if Input.is_action_just_pressed("jump"):
		audioStreamPlayer.play()
