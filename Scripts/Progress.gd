class_name Progress extends Node

var silver_total_time = 280
var gold_total_time = 180
var special_total_time = 140

var data = {
	"Levels": [
		{"Keys": [false, false, false], "Time": false, "Medal": 0, "AllKeyTime": false},
		{"Keys": [false, false, false], "Time": false, "Medal": 0, "AllKeyTime": false},
		{"Keys": [false, false, false], "Time": false, "Medal": 0, "AllKeyTime": false}, 
		{"Keys": [false, false, false], "Time": false, "Medal": 0, "AllKeyTime": false}
	],
	"Unlocks": {"Level2": false, "Level3": false, "Level4": false},
	"CurrentLevel": 1,
	"Name": false
	}

var default_data = {
	"Levels": [
		{"Keys": [false, false, false], "Time": false, "Medal": 0, "AllKeyTime": false},
		{"Keys": [false, false, false], "Time": false, "Medal": 0, "AllKeyTime": false},
		{"Keys": [false, false, false], "Time": false, "Medal": 0, "AllKeyTime": false}, 
		{"Keys": [false, false, false], "Time": false, "Medal": 0, "AllKeyTime": false}
	],
	"Unlocks": {"Level2": false, "Level3": false, "Level4": false},
	"CurrentLevel": 1,
	"Name": false
	}

func get_min_medal_score():
	var result = 0
	
	for i in range(1, 5, 1):
		for level in data["Levels"]:
			if level["Medal"] < i:
				return result
		result += 1
	return result

func get_key_count(level_nb):
	var result = 0
	for key in data["Levels"][level_nb - 1]["Keys"]:
		if key:
			result += 1
	return result
	
func has_all_keys():
	for level in data["Levels"]:
		for key in level["Keys"]:
			if key == false:
				return false
	return true
	

func set_medal_requirements(silver, gold, special):
	silver_total_time = silver
	gold_total_time = gold
	special_total_time = special

func get_name():
	return data["Name"]
	
func set_name(value):
	data["Name"] = value

func unlock(name : String):
	if data["Unlocks"].has(name):
		data["Unlocks"][name] = true
		save_data()
	else:
		push_error("Cannot unlock '" + name + "': Unlock not found.")

func try_update_level_time(level_nb, new_time):
	if not data["Levels"][level_nb - 1]["Time"] or new_time < data["Levels"][level_nb - 1]["Time"]:
		data["Levels"][level_nb - 1]["Time"] = new_time
		return true
	return false
	
func try_update_all_keys_level_time(level_nb, new_time):
	if not data["Levels"][level_nb - 1]["AllKeyTime"] or new_time < data["Levels"][level_nb - 1]["AllKeyTime"]:
		data["Levels"][level_nb - 1]["AllKeyTime"] = new_time
		return true
	return false
		
func is_level_unlocked(level_nb):
	return data["Unlocks"]["Level" + str(level_nb)]

func get_level_stats(level_nb):
	if level_nb <= 0 or level_nb > len(data["Levels"]):
		return null
	return data["Levels"][level_nb - 1]
	
func update_keys(level_nb, collected_keys):
	for i in range(len(collected_keys)):
		if i >= len(data["Levels"][level_nb - 1]["Keys"]):
			break
		if collected_keys[i] == true:
			data["Levels"][level_nb - 1]["Keys"][i] = true

func get_total_keys():
	var result = 0
	for level in data["Levels"]:
		result += len(level["Keys"])
	return result
	
func get_total_collected_keys():
	var result = 0
	for level in data["Levels"]:
		for key in level["Keys"]:
			if key == true:
				result += 1
	return result

func try_update_medal(lvl_nb, medal_value):
	var test = data["Levels"][lvl_nb - 1]["Medal"]
	if medal_value > data["Levels"][lvl_nb - 1]["Medal"]:
		data["Levels"][lvl_nb - 1]["Medal"] = medal_value
		save_data()
		return true
	return false

func get_total_best_time():
	var result = "not set"
	var counter = 0
	for level in data["Levels"]:
		if level["Time"]:
			counter += level["Time"]
		else:
			return result
	result = str(counter).pad_decimals(2)
	return result
	
func get_total_all_keys_best_time():
	var result = "not set"
	var counter = 0
	for level in data["Levels"]:
		if level["AllKeyTime"]:
			counter += level["AllKeyTime"]
		else:
			return result
	result = str(counter).pad_decimals(2)
	return result
	
func get_total_medal():
	var total_time = get_total_best_time()
	if total_time == "not set":
		return 0
	elif int(total_time) <= special_total_time:
		return 4
	elif int(total_time) <= gold_total_time:
		return 3
	elif int(total_time) <= silver_total_time:
		return 2
	else:
		return 1
	
func save_data():
	var file = File.new()
	file.open("user://save_game.dat", File.WRITE)
	file.store_string(JSON.print(data))
	file.close()
	
func cloud_save_data():
	Ngio.cloud_save(data)
	
func load_data():
	var file = File.new()
	if not file.file_exists("user://save_game.dat"):
		return
	file.open("user://save_game.dat", File.READ)
	var content = file.get_as_text()
	var json_result = JSON.parse(content)
	if json_result.error == OK and json_result.result is Dictionary and \
	json_result.result.has("Levels") and json_result.result.has("Unlocks"):
		data = json_result.result
	else:
		push_error("Cannot load Progress. Save Game file was corrupted!")
		push_error("JSON Error on line " + str(json_result.error_line) + ": " + json_result.error_string)
		save_data()
	file.close()

func reset_data():
	data = default_data
	save_data()
