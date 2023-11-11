extends CanvasLayer

export (String) var MainMenuScenePath = "res://Menu's/UI_MainMenu_New.tscn" 
export (String) var NextScenePath = "res://Menu's/UI_MainMenu_New.tscn" 

export (NodePath) var time_label_path = "Camera2D/CanvasLayer/Control/TimeLabel"
export (NodePath) var key_display_path = "Camera2D/CanvasLayer/Control/CollectedKeysDisplay"

var controller_mode = false

export var silver_time = 70
export var gold_time = 45
export var special_time = 35

var result_time = 90
var result_time_formatted = "00:00:00.00"
var result_medal = 1
var lvl_nb = 1
var got_all_keys = false


func binary_search(arr, l, r, x):
	if r >= l:
		var mid = l + int((r - l) / 2)
 
		if compare_list_data(arr[mid], x) :
			return mid
		elif  compare_times(x, arr[mid]):
			return binary_search(arr, l, mid-1, x)
		else:
			return binary_search(arr, mid + 1, r, x)
	else:
		return -1

func _ready():
	hide()
	
func disable():
	pass

func enable():
	pass

func _input(event):
	if not visible:
		return
	if not controller_mode:
		if Input.is_action_just_pressed("ui_down") or  Input.is_action_just_pressed("ui_up") or  \
			Input.is_action_just_pressed("ui_left") or  Input.is_action_just_pressed("ui_right"):
				$Title.grab_focus()
				controller_mode = true
	else:
		if Input.is_mouse_button_pressed(1):
			controller_mode = false
			$Title.grab_focus()

func _on_Next_Level_Button_button_up():
	GlobalSounds.play_click_sound()
	$ScreenTransition.transition_to(NextScenePath)

func _on_Main_Menu_Button_button_up():
	GlobalSounds.play_click_sound()
	if OS.has_feature("web"):
		$ScreenTransition.transition_to(MainMenuScenePath)
	else:
		get_tree().change_scene(MainMenuScenePath)

func format_time(time_in_sec):
	var seconds = int(time_in_sec)%60
	var minutes = (int(time_in_sec)/60)%60
	var mili_seconds = time_in_sec - int(time_in_sec)
	mili_seconds *= 100
	mili_seconds = int(mili_seconds)
	return "%02d:%02d.%02d" % [minutes, seconds, mili_seconds]

func unformat_time(formated_time : String):
	var hours = int(formated_time.split(":")[0])
	var minutes = int(formated_time.split(":")[1])
	var seconds = float(formated_time.split(":")[2])
	
	seconds += hours * 3_600 + minutes * 60
	
	return seconds

func activate(time, keys, collection_count, level):
	show()
	get_node(time_label_path).text =  "Your Time: " + format_time(time)
	get_node(key_display_path).render_instant(SaveState.progress.get_level_stats(level.level_number)["Keys"])
	get_node(key_display_path).animate_new_keys(keys)
	
	got_all_keys = (collection_count == 3)
	if got_all_keys:
		SaveState.progress.try_update_level_time(level.level_number, time)
		if SaveState.progress.try_update_all_keys_level_time(level.level_number, time):
			$Timers/BestTimeLabel.text = "Best Time: " + format_time(time)
			$Timers/TimeLabel/PersonalBestLabel.show()
			if SaveState.progress.get_total_all_keys_best_time() != "not set":
				if OS.has_feature("NG"):
					Ngio.post_score(5, 1, int(float(SaveState.progress.get_total_best_time()) * 1000.0))
				else:
					$TotalTimeRequest.request("https://firestore.googleapis.com/v1/projects/gunkey-6a1db/databases/(default)/documents/all_keys_total/leaderboard") 
		else:
			$Timers/BestTimeLabel.text = "Best Time: " + format_time(float(SaveState.progress.get_level_stats(level.level_number)["AllKeyTime"]))
	else:
		if SaveState.progress.try_update_level_time(level.level_number, time):
			$Timers/BestTimeLabel.text = "Best Time: " + format_time(time)
			$Timers/TimeLabel/PersonalBestLabel.show()
			if SaveState.progress.get_total_best_time() != "not set":
				if OS.has_feature("NG"):
					Ngio.post_score(5, 0, int(float(SaveState.progress.get_total_best_time()) * 1000.0))
				else:
					$TotalTimeRequest.request("https://firestore.googleapis.com/v1/projects/gunkey-6a1db/databases/(default)/documents/total/leaderboard") 
		else:
			$Timers/BestTimeLabel.text = "Best Time: " + format_time(float(SaveState.progress.get_level_stats(level.level_number)["Time"]))
	
	var is_medal_improvement = false
	var new_medal_score = 0
	var prev_medal = SaveState.progress.get_level_stats(level.level_number)["Medal"]
	var prev_min_medal = SaveState.progress.get_min_medal_score()
	
	if time <= special_time:
		new_medal_score = 4
		is_medal_improvement = SaveState.progress.try_update_medal(level.level_number, 4)
	elif time <= gold_time:
		new_medal_score = 3
		is_medal_improvement = SaveState.progress.try_update_medal(level.level_number, 3)
	elif time <= silver_time:
		new_medal_score = 2
		is_medal_improvement = SaveState.progress.try_update_medal(level.level_number, 2)
	else:
		new_medal_score = 1
		is_medal_improvement = SaveState.progress.try_update_medal(level.level_number, 1)
	
	if SaveState.progress.get_min_medal_score() > prev_min_medal:
		for i in range(prev_min_medal + 1, SaveState.progress.get_min_medal_score() + 1, 1):
			if i <= 1:
				continue
			Ngio.unlock_medal(5, i)
	
	$BestMedal.show_sprite(int(SaveState.progress.get_level_stats(level.level_number)["Medal"]))
	$Medal.show_sprite(new_medal_score)
	if is_medal_improvement:
		if OS.has_feature("NG"):
			unlock_NG_medals(prev_medal, new_medal_score, time, level)
		$BestMedal.transition_to(new_medal_score)

	if got_all_keys:
		$KeyMedal.show_sprite(5)

	result_time = time
	result_medal = new_medal_score
	lvl_nb = level.level_number
	upload_result_to_leaderboard(got_all_keys)

func unlock_NG_medals(prev_medal, new_medal_score, time, level):
	if prev_medal == 0:
		prev_medal = 1
	for i in range(prev_medal, new_medal_score + 1):
			print("Medal ", i, " unlocked thanks to time ", time)
			Ngio.unlock_medal(level.level_number, i)
			
func compare_times(row1, row2):
	if OS.has_feature("NG"):
		return unformat_time(row1["formatted_value"]) < unformat_time(row2["formatted_value"])
	return row1["Time"] < row2["Time"]

func upload_result_to_leaderboard(all_keys):
	if all_keys:
		if OS.has_feature("NG"):
			Ngio.post_score(lvl_nb, 1, int(result_time * 1000), funcref(self, "_on_NG_score_posted"))
		else:
			$TimeRequest.request("https://firestore.googleapis.com/v1/projects/gunkey-6a1db/databases/(default)/documents/all_keys_level_%d/leaderboard" % lvl_nb)
	else:
		if OS.has_feature("NG"):
			Ngio.post_score(lvl_nb, 0, int(result_time * 1000), funcref(self, "_on_NG_score_posted"))
		else:
			$TimeRequest.request("https://firestore.googleapis.com/v1/projects/gunkey-6a1db/databases/(default)/documents/level_%d/leaderboard" % lvl_nb)

func _on_NG_score_posted(results):
	print("Score Post Results:\n", results)
	if not results["success"]:
		print("Score Post failed!")
		return
	Ngio.request("ScoreBoard.getScores", {"id": results["result"]["data"]["scoreboard"]["id"], "period": "A", "limit": 100}, funcref(self, "_on_get_scores_request_completed"))
	result_time_formatted = results["result"]["data"]["score"]["formatted_value"]
	
func _on_get_scores_request_completed(results):
	print("Get Scores Result: ", results)
	if not "result" in results or not "data" in results["result"] or not "scores" in results["result"]["data"]:
		print("Score Request failed!")
		return
	var data = results["result"]["data"]["scores"]
	
	var rank = binary_search(data, 0, len(data) - 1, {"formatted_value": result_time_formatted}) + 1
	if rank != 0:
		if rank <= 3:
			if got_all_keys:
				$Timers/TimeLabel/GlobalRankLabel.text = "- Global All Keys #%d! -" % rank
			else:
				$Timers/TimeLabel/GlobalRankLabel.text = "- Global #%d! -" % rank
		else:
			if got_all_keys:
				$Timers/TimeLabel/GlobalRankLabel.text = "- Global All Keys Top " + str(int(float(rank) / float(len(data)) * 100.0)) + "% -"
			else:
				$Timers/TimeLabel/GlobalRankLabel.text = "- Global Top " + str(int(float(rank) / float(len(data)) * 100.0)) + "% -"
		$Timers/TimeLabel/GlobalRankLabel.show()
	

func _on_RetryButton_button_up():
	GlobalSounds.play_click_sound()
	$ScreenTransition.transition_to_restart()


func _on_VictoryScreen_visibility_changed():
	if visible:
		$CollectedKeysDisplay.grab_focus()
		$Music.play()
	else:
		$Music.stop()

func compare_list_data(data1, data2):
	if OS.has_feature("NG"):
		return data1["formatted_value"] == data2["formatted_value"]
	return data1["Name"] == data2["Name"] and data1["Time"] == data2["Time"]

func _on_TimeRequest_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Request failed!")
		print(response_code)
		print(result)
		return
	var json = JSON.parse(body.get_string_from_utf8())
	var data = JSON.parse(json.result["fields"]["entries"]["stringValue"]).result

	data.append({"Name": SaveState.progress.get_name(), "Time": result_time, "Medal": result_medal, "Icon": (1 if SaveState.progress.has_all_keys() else 0)})
	data.sort_custom(self, "compare_times")

	var rank = binary_search(data, 0, len(data) - 1, {"Name": SaveState.progress.get_name(), "Time": result_time, "Medal": result_medal}) + 1
	if rank <= 3:
		if got_all_keys:
			$Timers/TimeLabel/GlobalRankLabel.text = "- Global All Keys #%d! -" % rank
		else:
			$Timers/TimeLabel/GlobalRankLabel.text = "- Global #%d! -" % rank
	else:
		if got_all_keys:
			$Timers/TimeLabel/GlobalRankLabel.text = "- Global All Keys Top " + str(int(float(rank) / float(len(data)) * 100.0)) + "% -"
		else:
			$Timers/TimeLabel/GlobalRankLabel.text = "- Global Top " + str(int(float(rank) / float(len(data)) * 100.0)) + "% -"
	$Timers/TimeLabel/GlobalRankLabel.show()
	var patch_body = json.result
	patch_body["fields"]["entries"]["stringValue"] = JSON.print(data)
	if got_all_keys:
		$TimeRequest/PatchRequest.request("https://firestore.googleapis.com/v1/projects/gunkey-6a1db/databases/(default)/documents/all_keys_level_%d/leaderboard" % lvl_nb, [], \
		true, HTTPClient.METHOD_PATCH, JSON.print(patch_body))
	else:
		$TimeRequest/PatchRequest.request("https://firestore.googleapis.com/v1/projects/gunkey-6a1db/databases/(default)/documents/level_%d/leaderboard" % lvl_nb, [], \
		true, HTTPClient.METHOD_PATCH, JSON.print(patch_body))


func _on_TotalTimeRequest_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Request failed!")
		print(response_code)
		print(result)
		return
	var json = JSON.parse(body.get_string_from_utf8())
	var data = JSON.parse(json.result["fields"]["entries"]["stringValue"]).result

	data.append({"Name": SaveState.progress.get_name(), "Time": float(SaveState.progress.get_total_all_keys_best_time()) if got_all_keys else float(SaveState.progress.get_total_best_time()), "Medal": SaveState.progress.get_total_medal(), "Icon": (1 if SaveState.progress.has_all_keys() else 0)})
	data.sort_custom(self, "compare_times")

	var patch_body = json.result
	patch_body["fields"]["entries"]["stringValue"] = JSON.print(data)
	if got_all_keys:
		$TotalTimeRequest/PatchRequest.request("https://firestore.googleapis.com/v1/projects/gunkey-6a1db/databases/(default)/documents/all_keys_total/leaderboard", [], \
		true, HTTPClient.METHOD_PATCH, JSON.print(patch_body))
	else:
		$TotalTimeRequest/PatchRequest.request("https://firestore.googleapis.com/v1/projects/gunkey-6a1db/databases/(default)/documents/total/leaderboard", [], \
		true, HTTPClient.METHOD_PATCH, JSON.print(patch_body))
