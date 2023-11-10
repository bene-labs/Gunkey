extends Node

func play_click_sound(position = 0):
	$ClickSound.play(position)

func play_menu_music(position = 0):
	$MenuMusic.play(position)
	
func stop_menu_music():
	$MenuMusic.stop()

func is_menu_music_playing():
	return $MenuMusic.playing

func apply_audio_settings():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), SaveState.settings.get_mute_master())
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), SaveState.settings.get_mute_sfx())
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), SaveState.settings.get_mute_music())
