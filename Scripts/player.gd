extends CharacterBody2D

# =========================
# CONSTANTES
# =========================
const SPEED = 155
const JUMP_VELOCITY = -300

# =========================
# REFERENCIAS
# =========================
@onready var animated_sprite = $AnimatedSprite2D
@onready var dust = preload("res://Scenes/dust.tscn")
@onready var deal_damage_zone = $DamageZone
@onready var respawn_point = get_parent().get_node("RespawnPoint")
@onready var light = $PointLightPlayer

# SONIDOS
@onready var footsteps = $sonido_caminar
@onready var sonido_saltar = $sonido_saltar
@onready var sonido_caida = $sonido_caida
@onready var sonido_muerte = $sonido_muerte
@onready var sonido_daño = $sonido_daño
@onready var sonido_espada = $sonido_espada

# =========================
# VARIABLES
# =========================
var isgrounded = true
var attack = null

# =========================
#  VIDA
# =========================
var health = 20
var health_max = 100
var health_min = 0

var is_dead = false
var is_dying = false
var invulnerable = false
var respawn_health_penalty = 10

func _ready():
	light.visible = false

# =========================
# LOOP PRINCIPAL
# =========================
func _physics_process(delta):

	# 💀 MUERTO → solo física
	if is_dead:
		footsteps.stop()
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			velocity = Vector2.ZERO
		move_and_slide()
		return

	# dust + sonido al aterrizar
	if isgrounded == false and is_on_floor() == true:
		sonido_caida.play()
		var instance = dust.instantiate()
		instance.global_position = $Marker2D.global_position
		get_parent().add_child(instance)

	isgrounded = is_on_floor()

	# gravedad de salto
	if not is_on_floor():
		velocity += get_gravity() * delta

	# accion salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sonido_saltar.play()

	# 🎮 movimiento
	var direction = Input.get_axis("move_left", "move_right")

	#  SONIDO PASOS
	if direction != 0 and is_on_floor():
		if !footsteps.playing:
			footsteps.play()
	else:
		footsteps.stop()

	# Movimiento horizontal
	if direction != 0:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
		deal_damage_zone.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# ataque + sonido
	if Input.is_action_just_pressed("left_mouse") and !attack:
		attack = "5_attack"
		sonido_espada.play()
		handle_attack_animation(attack)

	# 🎬 animaciones
	if !attack:
		if not is_on_floor():
			if velocity.y < 0:
				if animated_sprite.animation != "3 - jump":
					animated_sprite.play("3 - jump")
			else:
				if animated_sprite.animation != "4 - fall":
					animated_sprite.play("4 - fall")
		else:
			if direction != 0:
				if animated_sprite.animation != "2 - move":
					animated_sprite.play("2 - move")
			else:
				if animated_sprite.animation != "1 - idle":
					animated_sprite.play("1 - idle")

	# CONTROL DE LUZ
	if Input.is_action_just_pressed("light_button"):
		light.visible = !light.visible

	move_and_slide()

# =========================
#  DAÑO
# =========================
func take_damage(amount: int):
	if invulnerable or is_dead or is_dying:
		return

	health -= amount
	health = clamp(health, health_min, health_max)

	# MUERTE
	if health <= health_min:
		velocity = Vector2.ZERO
		die_sequence()
		return

	# HIT
	attack = "hit"
	invulnerable = true

	sonido_daño.play()
	animated_sprite.play("6 - hit")
	velocity = Vector2.ZERO

	await get_tree().create_timer(0.3).timeout
	attack = null
	start_invulnerability()

# =========================
# MUERTE
# =========================
func die_sequence(wait_for_floor: bool = true, play_animation: bool = true):
	if is_dying:
		return

	is_dying = true
	is_dead = true
	attack = null

	# parar los sonido de los pasos cuando no camine
	footsteps.stop()

	# esperar a llegar al suelo para morir
	if wait_for_floor:
		while not is_on_floor():
			await get_tree().physics_frame

	velocity = Vector2.ZERO

	# animación de muerte + sonido
	if play_animation:
		sonido_muerte.play()
		animated_sprite.play("7 - death")
		await animated_sprite.animation_finished

	# borrar checkpoint al reiniciar nivel
	Checkpoint.last_position = null

	Global.last_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file("res://Scenes/game_over.tscn")

# =========================
#  RESPAWN
# =========================
func die(by_fall: bool):
	if is_dead:
		return

	if by_fall:
		health -= respawn_health_penalty

	health = max(health, health_min)

	# GAME OVER
	if health <= health_min:
		die_sequence(false, false)
		return

	is_dead = true

	if Checkpoint.last_position != null:
		global_position = Checkpoint.last_position
	else:
		global_position = respawn_point.global_position

	velocity = Vector2.ZERO
	is_dead = false

	start_invulnerability()

# =========================
# 🛡️ INVULNERABILIDAD
# =========================
func start_invulnerability():
	await get_tree().create_timer(1.0).timeout
	invulnerable = false

# =========================
# ATAQUE
# =========================
func handle_attack_animation(attack):
	if attack:
		animated_sprite.play("5 - attack")
		toggle_damage_collisions(attack)
		await animated_sprite.animation_finished
		self.attack = null

func toggle_damage_collisions(attack):
	var damage_zone_collision = deal_damage_zone.get_node("CollisionShape2D")
	var wait_time: float

	if attack == "5_attack":
		wait_time = 0.5

	damage_zone_collision.disabled = false
	await get_tree().create_timer(wait_time).timeout
	damage_zone_collision.disabled = true

func get_damage():
	if attack == "5_attack":
		return 25
	return 0

# =========================
#KNOCKBACK
# =========================
# Quitar nockback a la hora de morir
func apply_knockback(source_position: Vector2):
	if is_dead or is_dying:
		return
# Knockback normal
	var knockback_direction = -1 if source_position.x > global_position.x else 1
	velocity.x = knockback_direction * 500
	velocity.y = -250
