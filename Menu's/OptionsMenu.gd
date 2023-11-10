extends CanvasLayer

signal Return
signal toggle_screen_shake

export var stand_alone = true
export var return_to_scene_path = "res://Menu\'s/UI_MainMenu_New.tscn"
var controller_mode = false


func _ready():
	if stand_alone:
		$TransparentOverlay.hide()
		$Background.show()
	else:
		$TransparentOverlay.show()
		$Background.hide()
		connect("Return", get_tree().root.get_child(3), "_on_OptionsMenu_Return")
	$VideoOptions/VideoOptionsButtons/ScreenShakeCheckBox.pressed = SaveState.settings.is_screen_shake()
	$VideoOptions/VideoOptionsButtons/FullscreenCheckBox.pressed = SaveState.settings.is_fullscreen()
	
	$AudioOptions/AudioOptionsButtons/MasterCheckBox.pressed = !SaveState.settings.get_mute_master()
	$AudioOptions/AudioOptionsButtons/MasterSlider.value = SaveState.settings.get_master_volume()
	$AudioOptions/AudioOptionsButtons/SFXCheckBox.pressed = !SaveState.settings.get_mute_sfx()
	$AudioOptions/AudioOptionsButtons/SFXSlider.value = SaveState.settings.get_sfx_volume()
	$AudioOptions/AudioOptionsButtons/MusicCheckBox.pressed = !SaveState.settings.get_mute_music()
	$AudioOptions/AudioOptionsButtons/MusicSlider.value = SaveState.settings.get_music_volume()
	
	var test = SaveState.settings
	emit_signal("toggle_screen_shake", $VideoOptions/VideoOptionsButtons/ScreenShakeCheckBox.pressed)
	show_video_options()

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		_on_ReturnButton_button_up()
	if not controller_mode:
		if Input.is_action_just_pressed("ui_down") or  Input.is_action_just_pressed("ui_up") or  \
			Input.is_action_just_pressed("ui_left") or  Input.is_action_just_pressed("ui_right"):
				$Title.grab_focus()
				$ControlsOptions/ControlsOptionsControllerKeybinds.show()
				$ControlsOptions/ControlsOptionsKeybinds.hide()
				controller_mode = true
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		if event is InputEventMouse:
			$ControlsOptions/ControlsOptionsControllerKeybinds.hide()
			$ControlsOptions/ControlsOptionsKeybinds.show()
			controller_mode = false
			$Title.grab_focus()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif Input.is_action_just_pressed("ui_accept"):
			if $AudioOptions/AudioOptionsButtons/MasterSlider.has_focus():
				$AudioOptions/AudioOptionsButtons/MasterCheckBox.call_deferred("grab_focus")
			elif $AudioOptions/AudioOptionsButtons/SFXSlider.has_focus():
				$AudioOptions/AudioOptionsButtons/SFXCheckBox.call_deferred("grab_focus")
			elif $AudioOptions/AudioOptionsButtons/MusicSlider.has_focus():
				$AudioOptions/AudioOptionsButtons/MusicCheckBox.call_deferred("grab_focus")
				
					

func _on_Fullscreen_Button_button_up():
	GlobalSounds.play_click_sound()
	OS.window_fullscreen = $VideoOptions/VideoOptionsButtons/FullscreenCheckBox.pressed
	SaveState.settings.set_fullscreen($VideoOptions/VideoOptionsButtons/FullscreenCheckBox.pressed)


func _on_ScreenShakeButton_button_up():
	GlobalSounds.play_click_sound()
	SaveState.settings.set_screen_shake($VideoOptions/VideoOptionsButtons/ScreenShakeCheckBox.pressed)
	emit_signal("toggle_screen_shake", $VideoOptions/VideoOptionsButtons/ScreenShakeCheckBox.pressed)

func _exit_tree():
	SaveState.settings.save_data()

func _on_VideoButton_button_up():
	GlobalSounds.play_click_sound()
	show_video_options()


func _on_AudioButton_button_up():
	GlobalSounds.play_click_sound()



func _on_ControlsButton_button_up():
	GlobalSounds.play_click_sound()
	show_controls()


func _on_MasterSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value))
	$AudioOptions/AudioOptionsButtons/MasterVolumeLabel.text = str(int(value * 100)) + "%"
	SaveState.settings.set_master_volume(value)


func _on_MasterCheckBox_toggled(button_pressed):
	GlobalSounds.play_click_sound()
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), !button_pressed)
	SaveState.settings.set_mute_master(!button_pressed)

func _on_SFXSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(value))
	$AudioOptions/AudioOptionsButtons/SFXVolumeLabel.text = str(int(value * 100)) + "%"
	SaveState.settings.set_sfx_volume(value)

func _on_SFXCheckBox_toggled(button_pressed):
	GlobalSounds.play_click_sound()
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), !button_pressed)
	SaveState.settings.set_mute_sfx(!button_pressed)


func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(value))
	$AudioOptions/AudioOptionsButtons/MusicVolumeLabel.text = str(int(value * 100)) + "%"
	SaveState.settings.set_music_volume(value)


func _on_MusicCheckBox_toggled(button_pressed):
	GlobalSounds.play_click_sound()
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), !button_pressed)
	SaveState.settings.set_mute_music(!button_pressed)


func _on_ReturnButton_button_up():
	GlobalSounds.play_click_sound()
	if stand_alone:
		get_tree().change_scene(return_to_scene_path)
	else:
		emit_signal("Return")


func show_video_options():
	$Categories/CategoryLabels/VideoButton.disabled = true
	$Categories/CategoryLabels/AudioButton.disabled = false
	$Categories/CategoryLabels/ControlsButton.disabled = false
	
	$VideoOptions.show()
	$AudioOptions.hide()
	$ControlsOptions.hide()
	
func show_audio_options():
	$Categories/CategoryLabels/VideoButton.disabled = false
	$Categories/CategoryLabels/AudioButton.disabled = true
	$Categories/CategoryLabels/ControlsButton.disabled = false
	
	$VideoOptions.hide()
	$AudioOptions.show()
	$ControlsOptions.hide()
	
func show_controls():
	$Categories/CategoryLabels/VideoButton.disabled = false
	$Categories/CategoryLabels/AudioButton.disabled = false
	$Categories/CategoryLabels/ControlsButton.disabled = true
	
	$VideoOptions.hide()
	$AudioOptions.hide()
	$ControlsOptions.show()

func _on_VideoButton_focus_entered():
	show_video_options()


func _on_AudioButton_focus_entered():
	show_audio_options()


func _on_ControlsButton_focus_entered():
	show_controls()
