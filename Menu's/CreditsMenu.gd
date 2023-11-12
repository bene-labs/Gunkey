extends CanvasLayer


export (String) var MainMenuScenePath = "res://Menu's/UI_MainMenu_New.tscn" 
var controller_mode = false

func _on_ReturnButton_button_up():
	GlobalSounds.play_click_sound()
	if OS.has_feature("web"):
		$ScreenTransition.transition_to(MainMenuScenePath)
	else:
		SceneLoader.transition_to(MainMenuScenePath)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		SceneLoader.transition_to(MainMenuScenePath)
	
	if not controller_mode:
		if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up") or  \
			Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
				$Title.grab_focus()
				controller_mode = true
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		if event is InputEventMouse:
			controller_mode = false
			$Title.grab_focus()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
