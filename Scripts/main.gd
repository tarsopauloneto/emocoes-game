extends Node2D

@onready var platform_container = $PlatformContainer as Node2D
@onready var platform_initial_position_y = $PlatformContainer/Platform.position.y
@onready var camera_2d = $Camera2D as Camera2D
@onready var player = $Player as CharacterBody2D
@onready var camera_start_position = $Camera2D.position.y
@onready var score_label = $Camera2D/Score as Label
@onready var coins_label = $Camera2D/Coins as Label
@onready var alegria_music = $alegria_music as AudioStreamPlayer
@onready var blink_timer = Timer.new()  # Cria um Timer para o piscar

@export var platform_scene: Array[PackedScene]
@export var coin_scene: PackedScene
@export var alegria_scene: PackedScene  # Exporta a cena de Alegria
@export var outras_cenas: Array[PackedScene]  # Exporta as outras cenas herdadas

var last_platform_is_cloud: bool = false
var last_platform_is_spring: bool = false
var last_platform_is_enemy: bool = false

var score: int = 0
var coins: int = 0

var alegria_instance: Node2D = null  # Para armazenar a instância da cena Alegria
var personagens_instanciados: int = 0  # Para contar o número de cenas herdadas instanciadas
var is_game_paused: bool = false  # Controle para o estado pausado do jogo

var personagem_offset_y: float = 300  # Distância inicial no eixo Y acima da posição do player
var personagem_offset_x: float = 28  # Posição X da Alegria (onde as cenas devem aparecer)
var alegria_position_x: float = 28  # Posição X da Alegria
var alegria_position_y: float = 160  # Posição Y da Alegria
var alegria_width: float = 150  # Largura estimada de Alegria (ajustar conforme necessário)
var alegria_height: float = 120  # Altura estimada de Alegria (ajustar conforme necessário)

func level_generator(amount):
	for i in range(amount):
		var random_value = randf_range(0.0, 1.0)
		var platform_position_x = randf_range(20, 160)
		platform_initial_position_y -= randf_range(30, 50)

		# Verifica se a plataforma está na área ocupada pela Alegria no eixo Y
		while is_platform_overlapping_with_alegria(platform_position_x, platform_initial_position_y):
			platform_position_x += 50
			if platform_position_x > 200:
				platform_position_x = 20
				platform_initial_position_y += randf_range(30, 50)

		# Geração da plataforma após a verificação
		var new_platform: StaticBody2D
		if score < 1000:
			if random_value < 0.9:
				new_platform = platform_scene[0].instantiate() as StaticBody2D
			else:
				if last_platform_is_spring == false:
					new_platform = platform_scene[1].instantiate() as StaticBody2D
					last_platform_is_spring = true
				else:
					new_platform = platform_scene[0].instantiate() as StaticBody2D
					last_platform_is_spring = false
		elif score < 3000:
			if random_value < 0.5:
				new_platform = platform_scene[0].instantiate() as StaticBody2D
			elif random_value < 0.6:
				if last_platform_is_spring == false:
					new_platform = platform_scene[1].instantiate() as StaticBody2D
					last_platform_is_spring = true
				else:
					new_platform = platform_scene[0].instantiate() as StaticBody2D
					last_platform_is_spring = false
			else:
				if last_platform_is_cloud == false:
					new_platform = platform_scene[2].instantiate() as StaticBody2D
					new_platform.connect("delete_object", Callable(self, "delete_object"))
					last_platform_is_cloud = true
				else:
					new_platform = platform_scene[0].instantiate() as StaticBody2D
					last_platform_is_cloud = false
		else:
			if random_value < 0.5:
				new_platform = platform_scene[0].instantiate() as StaticBody2D
			elif random_value < 0.6:
				if last_platform_is_spring == false:
					new_platform = platform_scene[1].instantiate() as StaticBody2D
					last_platform_is_spring = true
				else:
					new_platform = platform_scene[0].instantiate() as StaticBody2D
					last_platform_is_spring = false
			elif random_value < 0.85:
				if last_platform_is_cloud == false:
					new_platform = platform_scene[2].instantiate() as StaticBody2D
					new_platform.connect("delete_object", Callable(self, "delete_object"))
					last_platform_is_cloud = true
				else:
					new_platform = platform_scene[0].instantiate() as StaticBody2D
					last_platform_is_cloud = false
			else:
				if last_platform_is_enemy == false:
					new_platform = platform_scene[3].instantiate() as StaticBody2D
					new_platform.connect("delete_object", Callable(self, "delete_object"))
					last_platform_is_enemy = true
				else:
					new_platform = platform_scene[0].instantiate() as StaticBody2D
					last_platform_is_enemy = false

		# Define a posição da nova plataforma
		new_platform.position = Vector2(platform_position_x, platform_initial_position_y)
		platform_container.call_deferred("add_child", new_platform)

		# Adiciona moeda aleatoriamente em plataformas normais
		if random_value < 0.3 and new_platform.is_in_group("platform"):
			var coin = coin_scene.instantiate() as Area2D
			coin.position = new_platform.position - Vector2(0, 15)  # Posiciona a moeda acima da plataforma
			coin.connect("collected", Callable(self, "increment_coins"))
			platform_container.call_deferred("add_child", coin)

# Função para verificar se a plataforma está sobrepondo a cena Alegria
func is_platform_overlapping_with_alegria(platform_position_x, platform_position_y) -> bool:
	if platform_position_y < alegria_position_y + alegria_height and platform_position_y > alegria_position_y - alegria_height:
		if platform_position_x > alegria_position_x - alegria_width / 2 and platform_position_x < alegria_position_x + alegria_width / 2:
			return true
	return false

func _ready():
	alegria_music.play()

	randomize()
	level_generator(20)

	coins_label.visible = false  # Oculta o contador de moedas inicialmente
	add_child(blink_timer)  # Adiciona o Timer à cena
	blink_timer.one_shot = false
	blink_timer.connect("timeout", Callable(self, "_on_blink_timer_timeout"))

	# Instancia a cena Alegria logo no início do jogo
	if alegria_instance == null:
		instantiate_alegria()

func _physics_process(delta):
	# Se o jogo está pausado, não atualiza nada relacionado à física
	if is_game_paused:
		return

	if player.position.y < camera_2d.position.y:
		camera_2d.position.y = player.position.y
	score_update()

func delete_object(obstacle):
	if obstacle.is_in_group("player"):
		if score > Global.highscore:
			Global.highscore = score
		if get_tree().change_scene_to_file("res://Scenes/title_screen.tscn") != OK:
			print("Algo deu errado!")
	elif obstacle.is_in_group("platform") or obstacle.is_in_group("enemy"):
		level_generator(1)
	obstacle.queue_free()

func _on_platform_cleaner_body_entered(body) -> void:
	delete_object(body)

func score_update() -> void:
	score = camera_start_position - camera_2d.position.y
	score_label.text = str(int(score))

func coins_update() -> void:
	coins_label.text = str(int(coins))

func increment_coins() -> void:
	coins += 1
	coins_label.text = str(int(coins))

	# Torna o contador visível na coleta da primeira moeda
	if coins == 1:
		coins_label.visible = true

	# Faz o contador piscar se o número de moedas for múltiplo
	if coins % 20 == 0:
		start_label_blink()
		Global.play_collected_coins_sound()

		# Instancia a próxima cena herdada após a coleta de moedas, se houver
		if personagens_instanciados < outras_cenas.size():
			instantiate_personagem(outras_cenas[personagens_instanciados])

func start_label_blink() -> void:
	blink_timer.start(0.2)  # Define o intervalo entre piscadas
	await get_tree().create_timer(2.0).timeout  # Espera por 2 segundos
	blink_timer.stop()  # Para o Timer
	coins_label.visible = true  # Garante que fica visível após parar de piscar

func _on_blink_timer_timeout() -> void:
	# Alterna a visibilidade do contador
	coins_label.visible = not coins_label.visible

# Função para instanciar a cena Alegria e posicioná-la
func instantiate_alegria():
	alegria_instance = alegria_scene.instantiate() as Node2D
	alegria_instance.position = Vector2(28, 160)  # Posiciona Alegria
	add_child(alegria_instance)

	# Conecta o sinal para detectar quando as frases terminarem
	alegria_instance.connect("dialogue_finished", Callable(self, "_on_alegria_dialogue_finished"))

	# Pausa o jogo enquanto as frases estão sendo exibidas
	pause_game()

# Função para instanciar a próxima cena herdada
func instantiate_personagem(personagem_scene: PackedScene):
	# Instancia o personagem fora da tela (no eixo X na mesma posição da Alegria, mas no eixo Y ajustado)
	var personagem_instance = personagem_scene.instantiate() as Node2D
	var pos_x = personagem_offset_x  # Coloca a cena na mesma posição X da Alegria
	var pos_y = player.position.y - personagem_offset_y  # A posição Y será acima do player

	# Define a posição inicial do personagem fora da tela (fora do campo de visão)
	personagem_instance.position = Vector2(pos_x, pos_y)
	add_child(personagem_instance)

	# Incrementa o contador de cenas instanciadas
	personagens_instanciados += 1

func _on_alegria_dialogue_finished():
	# Reativa o jogo após as frases terminarem
	unpause_game()
	#if alegria_instance:
		#alegria_instance.queue_free()  # Remove a Alegria após o diálogo

func pause_game():
	is_game_paused = true
	set_physics_process(false)
	player.set_physics_process(false)  # Pausa o processamento do Player
	platform_container.set_physics_process(false)  # Pausa o processamento das plataformas

func unpause_game():
	is_game_paused = false
	set_physics_process(true)
	player.set_physics_process(true)  # Reativa o processamento do Player
	platform_container.set_physics_process(true)  # Reativa o processamento das plataformas
