class_name Resolution extends MenuButton

var popup

# Called when the node enters the scene tree for the first time.
func _ready():
	popup = get_popup()
	popup.clear()
	popup.add_item("   1280x720")
	popup.add_item("   1366x768")
	popup.add_item("   1440x900")
	popup.add_item("   1536x864")
	popup.add_item("   1600x900")
	popup.add_item("   1920x1080")
	popup.connect("id_pressed", self, "_on_id_pressed")
	
	text = SaveState.settings.get_resolution()
	
func _on_id_pressed(id):
	GlobalSounds.play_click_sound()
	text = popup.get_item_text(id)
	SaveState.settings.set_resolution(text)
	update_resolution(text)
	
static func update_resolution(string):
	var new_res = Vector2.ZERO
	new_res.x = int(string.split('x')[0])
	new_res.y = int(string.split('x')[1])
	OS.window_size = new_res


func _on_ResolutionDropDown_about_to_show():
	GlobalSounds.play_click_sound()
