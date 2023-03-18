extends CanvasLayer


export (String) var Level1ScenePath = "res://lvl_One.tscn" 
export (String) var Level2ScenePath = "res://lvl_Two.tscn"
export (String) var Level3ScenePath = "res://lvl_Three.tscn" 
export (String) var Level4ScenePath = "res://lvl_one_hard_version.tscn" 
export (String) var MainMenuScenePath = "res://Menu's/UI_MainMenu_New.tscn" 
 
var controller_mode = false

func format_time(time_in_sec):
	if not time_in_sec:
		return "not set"
	
	var seconds = int(time_in_sec)%60
	var minutes = (int(time_in_sec)/60)%60
	var mili_seconds = time_in_sec - int(time_in_sec)
	mili_seconds *= 100
	mili_seconds = int(mili_seconds)
	return "%02d:%02d.%02d" % [minutes, seconds, mili_seconds]

func _ready():
	if SaveState.progress.is_level_unlocked(2):
		$"LevelContainer/Level/Levl2&4/Level2/Level2Button".disabled = false
	if SaveState.progress.is_level_unlocked(3):
		$"LevelContainer/Level/Levl1&3/Level3/Level3Button".disabled = false
	if SaveState.progress.is_level_unlocked(4):
		$"LevelContainer/Level/Levl2&4/Level4/Level4Button".disabled = false
		
	$"LevelContainer/Level/Levl1&3/Level1/Level1BestTime".text = "Best Time: " + format_time(float(SaveState.progress.get_level_stats(1)["Time"]))
	$"LevelContainer/Level/Levl2&4/Level2/Level2BestTime".text = "Best Time: " + format_time(float(SaveState.progress.get_level_stats(2)["Time"]))
	$"LevelContainer/Level/Levl1&3/Level3/Level3BestTime".text = "Best Time: " + format_time(float(SaveState.progress.get_level_stats(3)["Time"]))
	$"LevelContainer/Level/Levl2&4/Level4/Level4BestTime".text = "Best Time: " + format_time(float(SaveState.progress.get_level_stats(4)["Time"]))
	$TotalBestTime/TotalBestTimeLabel.text = "Total Best Time: " + format_time(float(SaveState.progress.get_total_best_time()))
	
	$TotalBestTime/TotalBestTimeMedal.show_sprite(SaveState.progress.get_total_medal())

	$"LevelContainer/Level/Levl1&3/Level1/Level1CollectedKeysDisplay".render_instant(SaveState.progress.get_level_stats(1)["Keys"])
	$"LevelContainer/Level/Levl2&4/Level2/Level2CollectedKeysDisplay".render_instant(SaveState.progress.get_level_stats(2)["Keys"])
	$"LevelContainer/Level/Levl1&3/Level3/Level3CollectedKeysDisplay".render_instant(SaveState.progress.get_level_stats(3)["Keys"])
	$"LevelContainer/Level/Levl2&4/Level4/Level4CollectedKeysDisplay".render_instant(SaveState.progress.get_level_stats(4)["Keys"])
	
	$TotalKeysCollected/ProgressOverlay.max_value = SaveState.progress.get_total_keys()
	$TotalKeysCollected/ProgressOverlay.value = SaveState.progress.get_total_collected_keys()
	if $TotalKeysCollected/ProgressOverlay.value == $TotalKeysCollected/ProgressOverlay.max_value:
		SaveState.progress.set_has_all_keys(true)
		$TotalKeysCollected/ProgressOverlay.hide()
		$TotalKeysCollected/ProgressOverlayFull.show()
	$TotalKeysCollected/KeyCounter.text = str($TotalKeysCollected/ProgressOverlay.value) + "/" + str($TotalKeysCollected/ProgressOverlay.max_value)
	
	load_medals()
	if not GlobalSounds.is_menu_music_playing():
		GlobalSounds.play_menu_music()
	
func load_medals():
	$"LevelContainer/Level/Levl1&3/Level1/Level1Medal".show_sprite(int(SaveState.progress.get_level_stats(1)["Medal"]))
	$"LevelContainer/Level/Levl2&4/Level2/Level2Medal".show_sprite(int(SaveState.progress.get_level_stats(2)["Medal"]))
	$"LevelContainer/Level/Levl1&3/Level3/Level3Medal".show_sprite(int(SaveState.progress.get_level_stats(3)["Medal"]))
	$"LevelContainer/Level/Levl2&4/Level4/Level4Medal".show_sprite(int(SaveState.progress.get_level_stats(4)["Medal"]))

func _input(event):
	if not controller_mode:
		if Input.is_action_just_pressed("ui_down") or  Input.is_action_just_pressed("ui_up") or  \
			Input.is_action_just_pressed("ui_left") or  Input.is_action_just_pressed("ui_right"):
				$Title.grab_focus()
				controller_mode = true
	else:
		if Input.is_mouse_button_pressed(1):
			controller_mode = false
			$Title.grab_focus()
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene(MainMenuScenePath)

func _on_Level_1_Button_button_up():
	GlobalSounds.play_click_sound()
	$"LevelContainer/Level/Levl1&3/Level1/Level1Button".mouse_default_cursor_shape = Control.CURSOR_BUSY
	Input.set_default_cursor_shape(Input.CURSOR_BUSY)
	$ScreenTransition.transition_to(Level1ScenePath)
	
func _on_Level_2_Button_button_up():
	GlobalSounds.play_click_sound()
	$"LevelContainer/Level/Levl2&4/Level2/Level2Button".mouse_default_cursor_shape = Control.CURSOR_BUSY
	Input.set_default_cursor_shape(Input.CURSOR_BUSY)
	$ScreenTransition.transition_to(Level2ScenePath)

func _on_Level_3_Button_button_up():
	GlobalSounds.play_click_sound()
	$"LevelContainer/Level/Levl1&3/Level3/Level3Button".mouse_default_cursor_shape = Control.CURSOR_BUSY
	Input.set_default_cursor_shape(Input.CURSOR_BUSY)
	$ScreenTransition.transition_to(Level3ScenePath)

func _on_BonusLevel1Button_button_up():
	GlobalSounds.play_click_sound()
	$"LevelContainer/Level/Levl2&4/Level4/Level4Button".mouse_default_cursor_shape = Control.CURSOR_BUSY
	Input.set_default_cursor_shape(Input.CURSOR_BUSY)
	$ScreenTransition.transition_to(Level4ScenePath)


func _on_Return_Button_button_up():
	GlobalSounds.play_click_sound()
	get_tree().change_scene(MainMenuScenePath)
