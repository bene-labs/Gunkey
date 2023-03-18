extends Node2D

export var level_number = 1

var is_paused = false
var is_options = false
var is_won = false

func _ready():
	SaveState.progress.data["CurrentLevel"] = level_number
	$CheckpointManager/EnemyFactory.generate_enemy_templates($Enemies.construction_data)
	$Player/ScreenTransition.connect("fade_in_completed", self, "_on_victory_screen_fade_in_completed")
	$Player/ScreenTransition.activate()

func _process(delta):
	if SaveState.is_transition_queded:
		return
	
	if Input.is_action_just_pressed("pause"):
		if is_won:
			get_tree().change_scene("res://Menu's/UI_MainMenu_New.tscn")
		else:
			if is_paused:
				if is_options:
					close_options()
				else:
					unpause()
			else:
				pause()

func pause_rec(node):
	if node.has_method("pause"):
		node.pause()
	for child in node.get_children():
		pause_rec(child)
		
func pause(show_menu = true):
	for child in get_children():
		pause_rec(child)
#	$Player/Camera2D/CanvasLayer.hide()
	if show_menu:
		$Player/Camera2D/PauseMenu.show()
		is_paused = true

func unpause_rec(node):
	if node.has_method("unpause"):
		node.unpause()
	for child in node.get_children():
		unpause_rec(child)

func unpause():
	for child in get_children():
		unpause_rec(child)
	$Player/Camera2D/PauseMenu.hide()
	is_paused = false
	
func close_options():
	$Player/Camera2D/PauseMenu.show()
	$Player/Camera2D/OptionsMenu.hide()
	is_options = false
	
func open_options():
	$Player/Camera2D/PauseMenu.hide()
	$Player/Camera2D/OptionsMenu.show()
	is_options = true

func _on_PauseMenu_OpenOptions():
	open_options()

func _on_OptionsMenu_Return():
	close_options()

func _on_VictoryZone_win():
	is_won = true
	pause(false)
	$Player/ScreenTransition.simulate_transition()


func _on_victory_screen_fade_in_completed():
	var stats = $Player.get_level_stats()
	$VictoryScreen.activate(stats["time"], stats["keys"], stats["collected"], self)
	$Player.queue_free()
	if level_number < 4:
		SaveState.progress.data["CurrentLevel"] = level_number + 1
		SaveState.progress.unlock("Level" + str(level_number + 1))
	if SaveState.progress.get_key_count(level_number) != 3:
		SaveState.progress.update_keys(level_number, stats["keys"])
		if SaveState.progress.get_key_count(level_number) == 3:
			print("All Keys collected in Level ", level_number, " -> Medal unlocked!")
			Ngio.unlock_medal(level_number, 5)
			if SaveState.progress.has_all_keys():
				print("All Keys collected in every Level! -> Medal unlocked!")
				Ngio.unlock_medal(5, 5)
	SaveState.progress.save_data()
	SaveState.progress.cloud_save_data()
