extends CanvasLayer

export var max_rows = 5
var page = 0
var page_count = 1

export var key_icon = preload("res://Sprites/UI/ScreenUI/medal_key.png")
export var medal_textures = [] 
export var fill_with_template = false

var table_data = []
var is_page_loaded = false

var active_button_id = 1
var controller_mode = false

var medal_requirements = [[80, 50, 30], [80, 50, 30], [90, 60, 30], [80, 50, 30]]

func _ready():
	if OS.has_feature("NG"):
		$HTTPRequest.queue_free()
	$Title.grab_focus()
	$UsernameLineEdit.text = SaveState.progress.get_name()
	_on_Level1Button_button_up()

func _input(event):
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
		elif Input.is_action_just_pressed("ui_accept"):
			if $HSlider.has_focus():
				focus_button(active_button_id)

func _on_UsernameLineEdit_text_entered(new_text):
	print("Text entered: ", new_text)
	if new_text != "":
		SaveState.progress.set_name(new_text)
		SaveState.progress.save_data()

func _on_UsernameLineEdit_text_change_rejected(rejected_substring):
	print("Text rejected: ", rejected_substring)


func _on_ReturnButton_button_up():
	GlobalSounds.play_click_sound()
	get_tree().change_scene("res://Menu's/UI_MainMenu_New.tscn")

func unformat_time(formated_time : String):
	var hours = int(formated_time.split(":")[0])
	var minutes = int(formated_time.split(":")[1])
	var seconds = float(formated_time.split(":")[2])
	
	seconds += hours * 3_600 + minutes * 60
	
	return seconds

func format_time(time_in_sec):
	var seconds = int(time_in_sec)%60
	var minutes = (int(time_in_sec)/60)%60
	var hours = (int(time_in_sec)/60)/60
	var mili_seconds = time_in_sec - int(time_in_sec)
	mili_seconds *= 100
	mili_seconds = int(mili_seconds)
	#returns a string with the format "HH:MM:SS"
	return "%02d:%02d:%02d.%02d" % [hours, minutes, seconds, mili_seconds]

func get_medal(level_nb, time):
	if time <= medal_requirements[level_nb - 1][2]:
		return 4
	if time <= medal_requirements[level_nb - 1][1]:
		return 3
	if time <= medal_requirements[level_nb - 1][0]:
		return 2
	return 1

func display_list(table):
	$Table/Body/UsernameList.clear()
	$Table/Body/TimeList.clear()
	$Table/Body/MedalList.clear()
	$Table/Body/RankingList.clear()
	var i = 1 + page * max_rows
	for row in table:
		if OS.has_feature("NG"):
			$Table/Body/UsernameList.add_item((row["user"]["name"] if "user" in row and "name" in row["user"] else ""), null, false)
			$Table/Body/TimeList.add_item((row["formatted_value"] if "formatted_value" in row else ""), null, false)
			if "formatted_value" in row:
				$Table/Body/MedalList.add_icon_item(medal_textures[get_medal(active_button_id, unformat_time(row["formatted_value"]))], false)
			else:
				$Table/Body/MedalList.add_icon_item(null, false)
		else:
			$Table/Body/UsernameList.add_item(row["Name"], key_icon if "Icon" in row and row["Icon"] == 1 else null, false)
			$Table/Body/TimeList.add_item(format_time(row["Time"]), null, false)
			$Table/Body/MedalList.add_icon_item(medal_textures[row["Medal"]], false)
		$Table/Body/RankingList.add_item("#" + str(i), null, false)
		i += 1

func load_leaderboard(id):
	active_button_id = id
	for button in $Categories/CategoryLabels.get_children():
		button.disabled = false
	if $AllKeysCheckBox.pressed:
		if OS.has_feature("NG"):
			Ngio.request("ScoreBoard.getScores", {"id": Ngio.leaderboards_ids[1][id - 1], "period": "A", "limit": 100}, funcref(self, "_on_get_scores_request_completed"))
		elif id > 4:
			$HTTPRequest.request("https://firestore.googleapis.com/v1/projects/gunkey-6a1db/databases/(default)/documents/all_keys_total/leaderboard")
		else:
			$HTTPRequest.request("https://firestore.googleapis.com/v1/projects/gunkey-6a1db/databases/(default)/documents/all_keys_level_%d/leaderboard" % id)
	else:
		if OS.has_feature("NG"):
			Ngio.request("ScoreBoard.getScores", {"id": Ngio.leaderboards_ids[0][id - 1], "period": "A", "limit": 100}, funcref(self, "_on_get_scores_request_completed"))
		elif id > 4:
			$HTTPRequest.request("https://firestore.googleapis.com/v1/projects/gunkey-6a1db/databases/(default)/documents/total/leaderboard")
		else:
			$HTTPRequest.request("https://firestore.googleapis.com/v1/projects/gunkey-6a1db/databases/(default)/documents/level_%d/leaderboard" % id)
	if id <= 4:
		get_node("Categories/CategoryLabels/Level%dButton" % id).disabled = true
	else:
		$Categories/CategoryLabels/TotalButton.disabled = true
	is_page_loaded = false

func focus_button(id):
	if id <= 4:
		get_node("Categories/CategoryLabels/Level%dButton" % id).grab_focus()
	else:
		$Categories/CategoryLabels/TotalButton.grab_focus()
		
func _on_Level1Button_button_up():
	GlobalSounds.play_click_sound()
	load_leaderboard(1)

func _on_Leve2Button_button_up():
	GlobalSounds.play_click_sound()
	load_leaderboard(2)

func _on_Level3Button_button_up():
	GlobalSounds.play_click_sound()
	load_leaderboard(3)

func _on_Level4Button_button_up():
	GlobalSounds.play_click_sound()
	load_leaderboard(4)

func _on_TotalButton_button_up():
	GlobalSounds.play_click_sound()
	load_leaderboard(5)

func _on_get_scores_request_completed(results):
	if not "result" in results or not "data" in results["result"] or not "scores" in results["result"]["data"]:
		print("Score Request failed!")
		return
	var data = results["result"]["data"]["scores"]
	
	
	table_data.clear()
	
	if len(data) <= max_rows:
		display_list(data)
		page_count = 1
	else:
		var i = 0
		var k = 0
		while i < len(data):
			table_data.append([])
			for j in range(max_rows):
				if i >= len(data):
					break
				table_data[k].append(data[i])
				i += 1
			k += 1
		page_count = len(table_data)
		display_list(table_data[0])
	page = 0
	$HSlider.value = 0
	$HSlider.max_value = page_count - 1
	$HSlider/Label.text = "Page %d / %d" % [page + 1, page_count]
	is_page_loaded = true
	

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Request failed!")
		print(response_code)
		print(result)
		return
	
	var json = JSON.parse(body.get_string_from_utf8())
	var data = JSON.parse(json.result["fields"]["entries"]["stringValue"]).result
	
	table_data.clear()
	
	if len(data) <= max_rows:
		display_list(data)
		page_count = 1
	else:
		var i = 0
		var k = 0
		while i < len(data):
			table_data.append([])
			for j in range(max_rows):
				if i >= len(data):
					break
				table_data[k].append(data[i])
				i += 1
			k += 1
		page_count = len(table_data)
		display_list(table_data[0])
	page = 0
	$HSlider.value = 0
	$HSlider.max_value = page_count - 1
	$HSlider/Label.text = "Page %d / %d" % [page + 1, page_count]
	is_page_loaded = true


func _on_HSlider_value_changed(value):
	page = value
	$HSlider/Label.text = "Page %d / %d" % [page + 1, page_count]
	if is_page_loaded:
		display_list(table_data[page])


func _on_Level1Button_focus_entered():
	if active_button_id != 1:
		load_leaderboard(1)


func _on_Level2Button_focus_entered():
	if active_button_id != 2:
		load_leaderboard(2)


func _on_Level3Button_focus_entered():
	if active_button_id != 3:
		load_leaderboard(3)
		

func _on_Level4Button_focus_entered():
	if active_button_id != 4:
		load_leaderboard(4)
		

func _on_TotalButton_focus_entered():
	if active_button_id != 5:
		load_leaderboard(5)


func _on_AllKeysCheckBox_button_up():
	load_leaderboard(active_button_id)


func _exit_tree():
	_on_UsernameLineEdit_text_entered($UsernameLineEdit.text)
