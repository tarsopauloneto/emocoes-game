extends Area2D

class_name Coin

@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D
@onready var coin_sound = $coin_sound as AudioStreamPlayer

signal collected

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not body.is_player_dead():
		emit_signal("collected")  # Emite o sinal ao ser coletada
		Global.play_coin_sound()  # Reproduz o som
		queue_free()
