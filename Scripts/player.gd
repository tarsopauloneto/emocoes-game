extends CharacterBody2D

const GRAVITY: float = 10.0
var jump_force: float = 400.0
var speed: float = 150.0

@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D
@onready var area_2d = $Area2D as Area2D
@onready var screen_size = get_viewport().get_visible_rect().size
@onready var jump_sound = $Sfx/jump_sound as AudioStreamPlayer
@onready var spring_sound = $Sfx/spring_sound as AudioStreamPlayer
@onready var falling_sound = $Sfx/falling_sound as AudioStreamPlayer

var is_dead = false
var is_immortal = false
var last_direction = Vector2.ZERO  # Última direção horizontal registrada

# Função principal chamada a cada frame para processar física
func _physics_process(delta: float) -> void:
	position.x = wrapf(position.x, 0, screen_size.x)  # Faz o jogador reaparecer do outro lado ao sair da tela

	if is_dead:
		# Se o jogador estiver morto, continua movendo na última direção horizontal
		velocity.x = last_direction.x
		velocity.y += GRAVITY  # A gravidade afeta a queda
		move_and_slide()  # Move o personagem baseado na velocidade
		return  # Ignora controle manual

	# Aplica gravidade se o jogador não estiver no chão
	if not is_on_floor():
		velocity.y += GRAVITY

	# Controla o movimento horizontal baseado na entrada do jogador
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = lerp(velocity.x, direction * speed, 0.5)
		animated_sprite_2d.flip_h = direction < 0  # Atualiza a orientação do sprite
		last_direction = velocity  # Registra a última direção horizontal
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.5)  # Reduz a velocidade suavemente quando parado

	move_and_slide()  # Move o jogador com base na velocidade calculada

	# Verifica se há corpos sobrepostos na área para interações
	for body in area_2d.get_overlapping_bodies():
		_on_area_2d_body_entered(body)

	# Troca a animação com base na direção vertical
	if velocity.y >= 0:
		animated_sprite_2d.play("riley_land")
	else:
		animated_sprite_2d.play("riley_jump")

# Função chamada ao detectar corpos dentro da área de colisão
func _on_area_2d_body_entered(body: Node) -> void:
	if is_on_floor() and body.has_method("get_jump_force"):
		if is_immortal:
			is_immortal = false

		velocity.y = -jump_force * body.get_jump_force()  # Modifica a força do salto com base na plataforma

		# Verifica o tipo específico antes de tocar o som
		if (body is Platform or body is Enemy) and not (body is SpringPlatform or body is CloudPlatform):
			jump_sound.play()
		elif body is SpringPlatform:
			is_immortal = true
			spring_sound.play()

		# Chamando o método `response` se ele existir
		if body.has_method("response"):
			body.response()

# Função para lidar com a morte do jogador
func die() -> void:
	velocity.y = 0  # Reseta a velocidade vertical para que a gravidade atue
	collision_mask = 0
	is_dead = true  # Marca o estado como morto
	last_direction = velocity  # Mantém a direção horizontal antes da morte
	animated_sprite_2d.play("riley_land")  # Toca a animação de pouso
	Global.play_falling_sound()

func is_player_dead() -> bool:
	return is_dead

func is_player_immortal() -> bool:
	return is_immortal
