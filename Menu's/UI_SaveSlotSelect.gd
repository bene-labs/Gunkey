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
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), SaveState.settings.get_mute_master())
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), SaveState.settings.get_mute_sfx())
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), SaveState.settings.get_mute_music())
	
	
	var test = SaveState.settings
	emit_signal("toggle_screen_shake", $VideoOptions/VideoOptionsButtons/ScreenShakeCheckBox.pressed)

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
	else:
		if Input.is_mouse_button_pressed(1):
			$ControlsOptions/ControlsOptionsControllerKeybinds.hide()
			$ControlsOptions/ControlsOptionsKeybinds.show()
			controller_mode = false
			$Title.grab_focus()
		elif Input.is_action_just_pressed("ui_accept"):
			if $AudioOptions/AudioOptionsButtons/MasterSlider.has_focus():
				$AudioOptions/AudioOptionsButtons/MasterCheckBox.call_deferred("grab_focus")
			elif $AudioOptions/AudioOptionsButtons/SFXSlider.has_focus():
				$AudioOptions/AudioOptionsButtons/SFXCheckBox.call_deferred("grab_focus")
			elif $AudioOptions/AudioOptionsButtons/MusicSlider.has_focus():
				$AudioOptions/AudioOptionsButtons/MusicCheckBox.call_deferred("grab_focus")
				
					

func _exit_tree():
	SaveState.settings.save_data()

func _on_Save1_button_up():
	GlobalSounds.play_click_sound()
	show_save1()


func _on_Save2_button_up():
	GlobalSounds.play_click_sound()
	show_save2()

func _on_Save3_button_up():
	GlobalSounds.play_click_sound()
	show_save3()


func _on_ReturnButton_button_up():
	GlobalSounds.play_click_sound()
	if stand_alone:
		get_tree().change_scene(return_to_scene_path)
	else:
		emit_signal("Return")


func show_save1():
	$Categories/CategoryLabels/Save1Button.disabled = true
	$Categories/CategoryLabels/Save2Button.disabled = false
	$Categories/CategoryLabels/Save3Button.disabled = false
	
	$Save1Options.show()
	$Save2Options.hide()
	$Save3Options.hide()
	
func show_save2():
	$Categories/CategoryLabels/Save1Button.disabled = false
	$Categories/CategoryLabels/Save2Button.disabled = true
	$Categories/CategoryLabels/Save3Button.disabled = false
	
	$Save1Options.hide()
	$Save2Options.show()
	$Save3Options.hide()
	
func show_save3():
	$Categories/CategoryLabels/Save1Button.disabled = false
	$Categories/CategoryLabels/Save2Button.disabled = false
	$Categories/CategoryLabels/Save3Button.disabled = true
	
	$Save1Options.hide()
	$Save2Options.hide()
	$Save3Options.show()

func _on_Save1_focus_entered():
	show_save1()


func _on_Save2_focus_entered():
	show_save2()


func _on_Save3_focus_entered():
	show_save3()


func _on_TextureButton_button_up():
	SaveState.progress.reset_data()
	Ngio.request("CloudSave.clearSlot", {"id": 1})
	
