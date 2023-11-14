extends Node

var settings : Settings = Settings.new()
var progress : Progress = Progress.new()

export var reset_all_data = false
export var reset_settings = false
export var reset_progress = false

export var silver_total_time = 280
export var gold_total_time = 180
export var special_total_time = 140

export var adjectives = "big,small,crazy" 
export var nouns = "Banana,Monkey,Boom" 

var is_transition_queded = false

func set_is_transition_queded(value):
	is_transition_queded = value

func _ready():
	if reset_all_data:
		settings.save_data()
		progress.save_data()
	else:
		settings.load_data() if not reset_settings else settings.save_data()
		progress.load_data() if not reset_progress else progress.save_data()
	
	OS.window_position = settings.get_window_position()
	OS.window_fullscreen = settings.is_fullscreen()
	Resolution.update_resolution(settings.get_resolution())
	GlobalSounds.apply_audio_settings()
	
	if OS.has_feature("NG"): 
		load_cloud_data()
	elif not progress.try_get_name():
		randomize()
		var adj_list = adjectives.split(",")
		var noun_list = nouns.split(",")
		var random_name = adj_list[randi() % len(adj_list)] + noun_list[randi() % len(noun_list)]
		progress.set_name(random_name)
	
func load_cloud_data(nb = settings.get_active_save()):
	settings.set_active_save(nb)
	progress.data["Slot"] = nb
	Ngio.cloud_load(funcref(self, "_on_cloud_loaded"), settings.get_active_save())

func _on_cloud_loaded(data):
	if data == null:
		progress.reset_data()
		progress.cloud_save_data()
	else:
		var slot = progress.data["Slot"]
		progress.data = data
		progress.data["Slot"] = slot
		
func _exit_tree():
	settings.set_window_position(OS.window_position)
	settings.save_data()
	progress.save_data()
