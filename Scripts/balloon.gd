extends Sprite2D

@onready var label: Label = $Label
@export var frases: Array = [
	"bem-vindo a jornada das emocoes !",
	"clique nas setas para movimentar o jogador",
	"colete moedas para encontrar as outras emocoes",
	"boa sorte !"
]
var current_phrase_index: int = 0
var typing_speed: float = 0.05
var is_typing: bool = false

signal typing_finished  # Sinal para informar o fim da digitação

func start_typing():
	if frases.size() > 0:
		current_phrase_index = 0
		show_next_phrase()

func show_next_phrase():
	if current_phrase_index < frases.size():
		var phrase = frases[current_phrase_index]
		current_phrase_index += 1
		type_text(phrase)
	else:
		emit_signal("typing_finished")  # Emite o sinal quando terminar todas as frases

func type_text(phrase: String):
	if not is_typing:
		is_typing = true
		label.text = ""
		var i = 0
		while i < phrase.length():
			await get_tree().create_timer(typing_speed).timeout
			label.text += phrase[i]
			i += 1
		is_typing = false
		await get_tree().create_timer(1.2).timeout
		show_next_phrase()
