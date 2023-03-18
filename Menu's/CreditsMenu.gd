extends CanvasLayer


export (String) var MainMenuScenePath = "res://Menu's/UI_MainMenu_New.tscn" 


func _on_ReturnButton_button_up():
	GlobalSounds.play_click_sound()
	get_tree().change_scene(MainMenuScenePath)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene(MainMenuScenePath)
