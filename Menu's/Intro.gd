extends CanvasLayer

func _input(event):
	if event.is_pressed():
		$AnimationPlayer.stop()
		$ScreenTransition.transition_to("res://Menu's/UI_MainMenu_New.tscn")
