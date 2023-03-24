extends CanvasLayer

signal Return
signal toggle_screen_shake

export var return_to_scene_path = "res://Menu\'s/UI_MainMenu_New.tscn"
var controller_mode = false

var save_preview = null
var selected_save = 1
export var delete_confirm_count = 3
onready var delete_confirm_indx = delete_confirm_count


func _ready():
	var nb = int(SaveState.settings.get_active_save())
	match nb:
		1:
			show_save1()
		2:
			show_save2()
		3:
			show_save3()

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		_on_ReturnButton_button_up()
	if not controller_mode:
		if Input.is_action_just_pressed("ui_down") or  Input.is_action_just_pressed("ui_up") or  \
			Input.is_action_just_pressed("ui_left") or  Input.is_action_just_pressed("ui_right"):
				$Title.grab_focus()
				controller_mode = true
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		if event is InputEventMouse:
			controller_mode = false
			$Title.grab_focus()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					

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
	get_tree().change_scene(return_to_scene_path)

func show_save1():
	save_preview = null
	selected_save = 1
	delete_confirm_indx = delete_confirm_count
	$Categories/CategoryLabels/Save1Button.disabled = true
	$Categories/CategoryLabels/Save2Button.disabled = false
	$Categories/CategoryLabels/Save3Button.disabled = false
	
	$Save1Options.show()
	$Save2Options.hide()
	$Save3Options.hide()
	
	if SaveState.progress.data["Slot"] == 1:
		$Save1Options/SaveOptionsButtons/UseSaveCheckBox.pressed = true
#		$Save1Options/SaveOptionsButtons/UseSaveCheckBox.disabled = true
		var percantage = SaveState.progress.get_percantage()
		$Save1Options/SaveOptionsButtons/ProgressPercantageLabel.text = str(percantage).pad_decimals(2) + "%"
		$Save1Options/ProgressOverlay.value = percantage
	else:
		$Save1Options/SaveOptionsButtons/UseSaveCheckBox.pressed = false
		Ngio.cloud_load(funcref(self, "_on_save_preview_loaded"), 1)
	
func show_save2():
	save_preview = null
	selected_save = 2
	delete_confirm_indx = delete_confirm_count
	$Categories/CategoryLabels/Save1Button.disabled = false
	$Categories/CategoryLabels/Save2Button.disabled = true
	$Categories/CategoryLabels/Save3Button.disabled = false
	
	$Save1Options.hide()
	$Save2Options.show()
	$Save3Options.hide()
	
	if SaveState.progress.data["Slot"] == 2:
		$Save2Options/SaveOptionsButtons/UseSaveCheckBox.pressed = true
#		$Save2Options/SaveOptionsButtons/UseSaveCheckBox.disabled = true
		var percantage = SaveState.progress.get_percantage()
		$Save2Options/SaveOptionsButtons/ProgressPercantageLabel.text = str(percantage).pad_decimals(2) + "%"
		$Save2Options/ProgressOverlay.value = percantage
	else:
		$Save2Options/SaveOptionsButtons/UseSaveCheckBox.pressed = false
		Ngio.cloud_load(funcref(self, "_on_save_preview_loaded"), 2)
	
func show_save3():
	save_preview = null
	selected_save = 3
	delete_confirm_indx = delete_confirm_count
	$Categories/CategoryLabels/Save1Button.disabled = false
	$Categories/CategoryLabels/Save2Button.disabled = false
	$Categories/CategoryLabels/Save3Button.disabled = true
	
	$Save1Options.hide()
	$Save2Options.hide()
	$Save3Options.show()
	
	if SaveState.progress.data["Slot"] == 3:
		$Save3Options/SaveOptionsButtons/UseSaveCheckBox.pressed = true
#		$Save1Options/SaveOptionsButtons/UseSaveCheckBox.disabled = true
		var percantage = SaveState.progress.get_percantage()
		$Save3Options/SaveOptionsButtons/ProgressPercantageLabel.text = str(percantage).pad_decimals(2) + "%"
		$Save3Options/ProgressOverlay.value = percantage
	else:
		$Save3Options/SaveOptionsButtons/UseSaveCheckBox.pressed = false
		Ngio.cloud_load(funcref(self, "_on_save_preview_loaded"), 3)

func _on_save_preview_loaded(data):
	save_preview = data
	var percantage = SaveState.progress.get_percantage(data)
	get_node("Save" + str(selected_save) + "Options/SaveOptionsButtons/ProgressPercantageLabel").text = str(percantage).pad_decimals(2) + "%"
	get_node("Save" + str(selected_save) + "Options/ProgressOverlay").value = percantage

func _on_Save1Button_focus_entered():
	show_save1()

func _on_Save2Button_focus_entered():
	show_save2()


func _on_Save3Button_focus_entered():
	show_save3()


func _on_TextureButton_button_up():
	SaveState.progress.reset_data()
	Ngio.request("CloudSave.clearSlot", {"id": 1})
	
func _on_UseSaveCheckBox_button_up(nb):
	if not get_node("Save" + str(nb) + "Options/SaveOptionsButtons/UseSaveCheckBox").pressed:
		get_node("Save" + str(nb) + "Options/SaveOptionsButtons/UseSaveCheckBox").pressed = true
		return
	if SaveState.progress.data["Slot"] == nb:
		SaveState.settings.set_active_save(nb)
	else:
		SaveState.load_cloud_data(nb)
	
func _on_DeleteButton_button_up(nb):
	if delete_confirm_indx > 0:
		get_node("Save" + str(nb) + "Options/SaveOptionsButtons/DeleteButton").text = "Confirm Delete x" + str(delete_confirm_indx)
		delete_confirm_indx -= 1
	elif delete_confirm_indx == 0:
		get_node("Save" + str(nb) + "Options/SaveOptionsButtons/DeleteButton").text = "Delete Forever"
		delete_confirm_indx -= 1
	else:
		delete_confirm_indx = delete_confirm_count
		get_node("Save" + str(nb) + "Options/SaveOptionsButtons/DeleteButton").disabled = true
		if nb == SaveState.progress.data["Slot"]:
			SaveState.progress.reset_data()
			SaveState.progress.cloud_save_data()
		else:
			Ngio.request("CloudSave.clearSlot", {"id": nb})
		get_node("Save" + str(selected_save) + "Options/SaveOptionsButtons/ProgressPercantageLabel").text = "0.00%"
		get_node("Save" + str(selected_save) + "Options/SaveOptionsButtons/DeleteButton").text = "Deleted Save."
		get_node("Save" + str(selected_save) + "Options/ProgressOverlay").value = 0.0
	
#		Ngio.request("CloudSave.clearSlot", {"id": nb}, funcref(self, "_on_save_deleted"))

func _on_save_deleted(_result):
	get_node("Save" + str(selected_save) + "Options/SaveOptionsButtons/DeleteButton").disabled = false
	get_node("Save" + str(selected_save) + "Options/SaveOptionsButtons/ProgressPercantageLabel").text = "0.00%"
	get_node("Save" + str(selected_save) + "Options/SaveOptionsButtons/DeleteButton").text = "Delete Save"
	get_node("Save" + str(selected_save) + "Options/ProgressOverlay").value = 0.0
	
