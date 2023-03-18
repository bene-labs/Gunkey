extends Node

func play_click_sound(position = 0):
	$ClickSound.play(position)

func play_menu_music(position = 0):
	$MenuMusic.play(position)
	
func stop_menu_music(position = 0):
	$MenuMusic.stop()

func is_menu_music_playing():
	return $MenuMusic.playing
