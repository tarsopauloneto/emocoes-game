extends Node

var highscore: int = 0

@onready var coin_sound = preload("res://Assets/Sfx/coin.wav") as AudioStream
@onready var falling_sound = preload("res://Assets/Sfx/falling.wav") as AudioStream
@onready var collected_coins_sound = preload("res://Assets/Sfx/collected_coins.wav") as AudioStream

func play_coin_sound():
	var audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = coin_sound
	audio.volume_db = -5
	audio.play()
	audio.connect("finished", Callable(audio, "queue_free"))

func play_collected_coins_sound():
	var audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = collected_coins_sound
	audio.play()
	audio.connect("finished", Callable(audio, "queue_free"))

func play_falling_sound():
	var audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = falling_sound
	audio.volume_db = +3
	audio.play()
	audio.connect("finished", Callable(audio, "queue_free"))
