class_name Settings extends Node

var data = {
	"ScreenShake": true, "Fullscreen": false, "Resolution": "1280x720", 
	"MasterVolume": 100, "SFXVolume": 100, "MusicVolume": 100, 
	"MuteMaster": false, "MuteSFX": false, "MuteMusic": false,
	"WindowPositionX": 0, "WindowPositionY": 0, "ActiveSave": 1
	}
	
func get_active_save():
	if not "ActiveSave" in data:
		data["ActiveSave"] = 1
	return data["ActiveSave"]
	
func set_active_save(nb):
	data["ActiveSave"] = nb
	
func is_fullscreen():
	return data["Fullscreen"]
	
func is_screen_shake():
	return data["ScreenShake"]

func set_fullscreen(value):
	data["Fullscreen"] = value
	
func set_screen_shake(value):
	data["ScreenShake"] = value
	
func get_resolution():
	return data["Resolution"]

func set_resolution(value):
	data["Resolution"] = value
	
func set_master_volume(value):
	data["MasterVolume"] = value

func get_master_volume():
	return data["MasterVolume"]
	
func set_sfx_volume(value):
	data["SFXVolume"] = value
	
func get_sfx_volume():
	return data["SFXVolume"]

func set_music_volume(value):
	data["MusicVolume"] = value
	
func get_music_volume():
	return data["MusicVolume"]
		
func set_mute_master(value):
	data["MuteMaster"] = value

func get_mute_master():
	return data["MuteMaster"]
	
func set_mute_sfx(value):
	data["MuteSFX"] = value
	
func get_mute_sfx():
	return data["MuteSFX"]

func set_mute_music(value):
	data["MuteMusic"] = value
	
func get_mute_music():
	return data["MuteMusic"]
	
func set_window_position(position):
	data["WindowPositionX"] = position.x
	data["WindowPositionY"] = position.y
	
func get_window_position():
	return Vector2(data["WindowPositionX"], data["WindowPositionY"])

func save_data():
	var file = File.new()
	file.open("user://settings.dat", File.WRITE)
	file.store_string(JSON.print(data))
	file.close()

func load_data():
	var file = File.new()
	if not file.file_exists("user://settings.dat"):
		return
	file.open("user://settings.dat", File.READ)
	var content = file.get_as_text()
	var json_result = JSON.parse(content)
	if json_result.error == OK and json_result.result is Dictionary and \
	json_result.result.has("ScreenShake") and json_result.result.has("Fullscreen"):
		data = json_result.result
		if not "ActiveSave" in data or data["ActiveSave"] == null or \
		not (data["ActiveSave"] >= 1 and data["ActiveSave"] <= 3):
			print("Set active Save to 1.")
			data["ActiveSave"] = 1
	else:
		push_error("Cannot load Settings. Settings file was corrupted!")
		push_error("JSON Error on line " + str(json_result.error_line) + ": " + json_result.error_string)
		save_data()
	
	file.close()
