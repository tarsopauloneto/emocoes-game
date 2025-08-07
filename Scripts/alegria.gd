extends Node2D

@onready var balloon: Sprite2D = $Balloon

signal dialogue_finished  # Sinal para informar que as frases terminaram

func _ready():
	balloon.start_typing()
	# Conectamos o sinal para detectar o fim das frases
	balloon.connect("typing_finished", Callable(self, "_on_dialogue_finished"))

func _on_dialogue_finished():
	emit_signal("dialogue_finished")  # Emite o sinal para informar o término
