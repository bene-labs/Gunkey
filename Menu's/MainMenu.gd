extends CanvasLayer


export (String) var LevelselectScenePath = "res://Menu's/Levelselect.tscn" 
export (String) var CreditsScenePath = "res://Menu's/CreditsMenu.tscn" 
export (String) var OptionsScenePath = "res://Menu's/UI_OptionsMenu_New.tscn" 
export (String) var LeaderBoardsScenePath = "res://Menu's/UI_LeaderBoardSplit.tscn" 

export var main_button_name = "Play"
var is_rotaion_locked = false
var barrel_maximize_queued = false
var barrel_minimize_queued = false

export var is_barrel_out = false


var buttons = ["Options", "Play", "LevelSelect", "Credits", "ExtraSlot", "QuitGame"]

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if not GlobalSounds.is_menu_music_playing():
		GlobalSounds.play_menu_music()

	# Replace Quit Game Button
	if OS.has_feature("web"):
		$UpperCard/UpperButtonQuitGame.text = "                     Saves"
		$MiddleCard/MiddleButtonQuitGame.text = "                     Saves"
		$LowerCard/LowerButtonQuitGame.text = "                     Saves"
		$RevolverBarrel/IconsLeft/UpperIconLeft/QuitGameIcon.texture_normal = load("res://Sprites/UI/ScreenUI/Icons/ic_checkpoint.png")
		$RevolverBarrel/IconsLeft/UpperIconLeft/QuitGameIcon.texture_hover = load("res://Sprites/UI/ScreenUI/Icons/hover/ic_checkpoint2_h.png")

func set_main_button_name(value):
	main_button_name = value

func buttons_up():
	var front_button = buttons[0]
	for i in range(len(buttons) - 1):
		buttons[i] = buttons[i + 1]
	buttons[-1] = front_button
	if is_barrel_out:
		disable_front_buttons()
	else:
		enable_front_buttons()

func buttons_down():
	var back_button = buttons[-1]
	for i in range(len(buttons) - 1, 0, -1):
		buttons[i] = buttons[i - 1]
	buttons[0] = back_button
	if is_barrel_out:
		disable_front_buttons()
	else:
		enable_front_buttons()

func disable_front_buttons():
	get_node("UpperCard/UpperButton" + buttons[0]).disabled = true
	get_node("MiddleCard/MiddleButton" + buttons[1]).disabled = true
	get_node("LowerCard/LowerButton" + buttons[2]).disabled = true
		
func enable_front_buttons():
	get_node("UpperCard/UpperButton" + buttons[0]).disabled = false
	get_node("MiddleCard/MiddleButton" + buttons[1]).disabled = false
	get_node("LowerCard/LowerButton" + buttons[2]).disabled = false
	
func _on_Levelselect_Button_button_up():
	GlobalSounds.play_click_sound()
	get_tree().change_scene(LevelselectScenePath)

func _on_New_Game_Button_button_up():
	GlobalSounds.play_click_sound()
	disable_front_buttons()
	$UpperCard/UpperButtonPlay.mouse_default_cursor_shape = Control.CURSOR_BUSY
	$MiddleCard/MiddleButtonPlay.mouse_default_cursor_shape = Control.CURSOR_BUSY
	$LowerCard/LowerButtonPlay.mouse_default_cursor_shape = Control.CURSOR_BUSY
	Input.set_default_cursor_shape(Input.CURSOR_BUSY)
	
	match int(SaveState.progress.data["CurrentLevel"]):
		1:
			$ScreenTransition.transition_to("res://lvl_One_new_tiles.tscn")
		2:
			$ScreenTransition.transition_to("res://lvl_Two_reworked.tscn")
		3:
			$ScreenTransition.transition_to("res://lvl_Three.tscn")
		4:
			$ScreenTransition.transition_to("res://lvl_one_hard_version.tscn")
		_:
			$ScreenTransition.transition_to("res://lvl_One_new_tiles.tscn")
	


func _on_Options_Button_button_down():
	GlobalSounds.play_click_sound()
	get_tree().change_scene(OptionsScenePath)


func _on_Credits_Button_button_up():
	GlobalSounds.play_click_sound()
	get_tree().change_scene(CreditsScenePath)

func _on_Extra_Button_button_up():
	GlobalSounds.play_click_sound()
	get_tree().change_scene(LeaderBoardsScenePath)

func _on_Quit_Game_Button_button_up():
	GlobalSounds.play_click_sound()
	if OS.has_feature("web"):
		get_tree().change_scene("res://Menu's/UI_SaveSlotSelect.tscn")
	else:
		get_tree().quit()

func _input(event):
	if Input.is_action_just_pressed("ui_down") or  Input.is_action_just_pressed("ui_up"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	elif event is InputEventMouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if is_rotaion_locked:
		return
	if Input.is_action_just_pressed("ui_up"):
		$RotateSound.play()
		$AnimationPlayer.play(main_button_name + "Up")
		is_rotaion_locked = true
	elif Input.is_action_just_pressed("ui_down"):
		$RotateSound.play()
		$AnimationPlayer.play(main_button_name + "Down")
		is_rotaion_locked = true
	elif Input.is_action_just_pressed("ui_accept"):
		match main_button_name:
			"LevelSelect":
				_on_Levelselect_Button_button_up()
			"Credits":
				_on_Credits_Button_button_up()
			"Options":
				_on_Options_Button_button_down()
			"Play":
				_on_New_Game_Button_button_up()
			"ExtraSlot":
				_on_Extra_Button_button_up()
			"QuitGame":
				_on_Quit_Game_Button_button_up()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name != "RESET":
		is_rotaion_locked = false
		if barrel_maximize_queued:
			$BarrelAnimationPlayer.play("BarrelOut")
			barrel_maximize_queued = false
			is_rotaion_locked = true

func _on_BarrelCollsionContainer_area_exited(area):
	if $BarrelAnimationPlayer.is_playing() and $BarrelAnimationPlayer.current_animation == "BarrelOut":
		barrel_minimize_queued = true
	else:
		is_rotaion_locked = true
		$BarrelAnimationPlayer.play("BarrelIn")

func _on_BarrelCollsionContainer_area_entered(area):
	if $AnimationPlayer.is_playing() or ($BarrelAnimationPlayer.is_playing() and $BarrelAnimationPlayer.current_animation == "BarrelIn"):
		barrel_maximize_queued = true
	else:
		is_rotaion_locked = true
		$BarrelAnimationPlayer.play("BarrelOut")

func _on_BarrelAnimationPlayer_animation_finished(anim_name):
	if anim_name == "BarrelOut":
		is_rotaion_locked = false
		if barrel_minimize_queued:
			$BarrelAnimationPlayer.play("BarrelIn")
			barrel_minimize_queued = false
	elif anim_name == "BarrelIn":
		is_rotaion_locked = false
		if barrel_maximize_queued:
			$BarrelAnimationPlayer.play("BarrelOut")
			barrel_maximize_queued = false


func _on_LowerArrow_button_up():
	$RotateSound.play()
	$AnimationPlayer.play(main_button_name + "Down")
	is_rotaion_locked = true

func _on_UpperArrow_button_up():
	$RotateSound.play()
	$AnimationPlayer.play(main_button_name + "Up")
	is_rotaion_locked = true
