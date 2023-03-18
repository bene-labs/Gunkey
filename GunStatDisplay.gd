extends Node2D

export (NodePath) var gun_path

export (bool) var display_shot_count = true

func _ready():
	pass

func _process(delta):
	var gun : Gun = get_node(gun_path)
	$WarningSign.hide()
	$AmmoText.text = str(gun.ammo_count / (gun.bullets_per_shot if display_shot_count else 1)) \
	 + "/" + str(gun.max_ammo  / (gun.bullets_per_shot if display_shot_count else 1))
	$ReloadBar.max_value = gun.max_ammo
	$ReloadBar.value = gun.ammo_count
	if gun.is_reloading or gun.is_reload_queued:
		$AmmoText.text = "Reloading"
		$WarningSign.show()
		if gun.is_reload_queued:
			$ReloadBar.value = $ReloadBar.max_value - 1
		else:
			$ReloadBar.max_value = gun.reload_time * 100
			$ReloadBar.value = gun.reload_time * 100 - gun.get_node("ReloadTimer").time_left * 100

func pause():
	set_process(false)
	
func unpause():
	set_process(true)
