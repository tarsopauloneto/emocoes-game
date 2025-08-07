extends "res://Scripts/platform.gd"

class_name Enemy

var direction: Vector2 = Vector2.RIGHT
var velocity: Vector2 = Vector2.ZERO
@export var speed: float = 90.0

@onready var screen_size: Vector2 = get_viewport().get_visible_rect().size
@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D

func _physics_process(delta: float) -> void:
	movement(delta)

func movement(delta: float) -> void:
	velocity = direction * speed
	position += velocity * delta

	# Verifica as bordas da tela para inverter a direção
	if position.x >= screen_size.x:
		direction *= -1
		animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
	elif position.x <= 0:
		direction *= -1
		animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h

func response() -> void:
	emit_signal("delete_object", self)

func _on_hit_box_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not body.is_player_dead() and not body.is_player_immortal():
		body.die()
	# Se o player estiver morto ou imortal
	else:
		collision_mask = 0
