extends Control

@onready var highscore_label = $Highscore as Label
@onready var game_over_sound = $game_over_sound as AudioStreamPlayer

func _ready():
	game_over_sound.play()
	highscore_label.text = "HIGHSCORE:\n" + str(Global.highscore)

func _on_start_pressed():
	if get_tree().change_scene_to_file("res://Scenes/main.tscn") != OK:
		print("Algo deu errado!")

func _on_quit_pressed():
	get_tree().quit()
	print("Jogo encerrado.")
