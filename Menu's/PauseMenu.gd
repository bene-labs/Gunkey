extends CanvasLayer


signal ResumeGame
signal OpenOptions
export var MainMenuScenePath = "res://Menu's/UI_MainMenu_New.tscn"

export (NodePath) var player_path = "../../Player"

export var min_awake_duration = 15
export var max_awake_duration = 40
export var min_sleep_duration = 15
export var max_sleep_duration = 50
export var is_sleeping = false

var buttons = []
var button_index = 0
var controller_mode = false

func _ready():
	randomize()
	if is_sleeping:
		$SleepTimer.start(rand_range(min_sleep_duration, max_sleep_duration))
		$GunkeyFace.play("sleep")
		$Sleep.emitting = true
	else:
		$AwakeTimer.start(rand_range(min_awake_duration, max_awake_duration))
		$GunkeyFace.play("default")
		$Sleep.restart()
		$Sleep.emitting = false
	
	connect("OpenOptions", get_tree().current_scene, "_on_PauseMenu_OpenOptions")
	buttons = [	$ButtonsContainer/Buttons/Resume/ResumeButton,
				$ButtonsContainer/Buttons/LastCheckpoint/LastCheckpointButton,
				$ButtonsContainer/Buttons/Restart/RestartButton,
				$ButtonsContainer/Buttons/Options/OptionsButton,
				$ButtonsContainer/Buttons/MainMenu/MainMenuButton
				]
	for button in buttons:
		button.focus_mode = Control.FOCUS_ALL
	
func _input(event):
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
#	if not controller_mode:
#		if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up"):
#			$ButtonsContainer/Buttons/MainMenu/MainMenuButton.grab_focus()
#			controller_mode = true
#	elif Input.is_action_just_pressed("ui_down_special"):
#		button_index += 1
#		if button_index >= len(buttons):
#			button_index = 0
#		buttons[button_index].grab_focus()
#	elif Input.is_action_just_pressed("ui_up_special"):
#		button_index -= 1
#		if button_index < 0:
#			button_index = len(buttons) - 1
#		buttons[button_index].grab_focus()

func _on_Resume_Game_Button_button_up():
	GlobalSounds.play_click_sound()
	get_tree().current_scene.unpause()

func _on_Reset_Button_button_up():
	GlobalSounds.play_click_sound()
	SceneLoader.reload_current_scene()


func _on_Options_Button_button_up():
	GlobalSounds.play_click_sound()
	emit_signal("OpenOptions")


func _on_Main_Menu_Button_button_up():
	GlobalSounds.play_click_sound()
	SceneLoader.transition_to(MainMenuScenePath)

func _on_LastCheckpointButton_button_up():
	get_tree().current_scene.unpause()
	GlobalSounds.play_click_sound()
	get_node(player_path).restart()


func _on_PauseMenu_visibility_changed():
	if visible:
		buttons[0].grab_focus()


func _on_AwakeTimer_timeout():
	$Sleep.emitting = true
	$GunkeyFace.play("sleep")
	is_sleeping = true
	$SleepTimer.start(rand_range(min_sleep_duration, max_sleep_duration))

func _on_SleepTimer_timeout():
	$Sleep.restart()
	$Sleep.emitting = false
	$GunkeyFace.play("default")
	is_sleeping = false
	$AwakeTimer.start(rand_range(min_awake_duration, max_awake_duration))
