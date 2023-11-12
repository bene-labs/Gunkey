extends CanvasLayer

func _input(event):
	if event.is_pressed():
		$AnimationPlayer.stop()
		transition_to_main_menu()

func transition_to_main_menu():
	SceneLoader.transition_to("res://Menu's/UI_MainMenu_New.tscn")
	
