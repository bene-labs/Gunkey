extends Node2D

var songs = []
var song_index = 0

func shuffle():
	var shuffled_songs = []
	for i in range(len(songs)):
		shuffled_songs.append(songs[randi() % len(songs)])
	songs = shuffled_songs

func _ready():
	randomize()
	for child in get_children():
		songs.append(child)
	shuffle()
	GlobalSounds.stop_menu_music()
	songs[0].play()


func _on_Song_finished():
	song_index += 1
	if song_index >= len(songs):
		shuffle()
		song_index = 0
	songs[song_index].play()

func get_current_song():
	return songs[song_index]
