
extends CharacterBody2D

# =========================
# ⚙️ MOVIMIENTO
# =========================
@export var speed = 50
var direction = -1
@onready var sonido_seta = $sonidoSeta

# =========================
# ☠️ ESTADO GENERAL
# =========================
var dead = false

# =========================
# ❤️ VIDA
# =========================
var health = 100
var health_max = 100
var health_min = 0

var taking_damage = false  # evita spam de animación hit
var invulnerable = false   # i-frames tras recibir daño

@export var invulnerability_time = 0.5

# =========================
# 🟢 INICIO
# =========================
func _ready():
	# Animación inicial del enemigo
	$AnimatedSprite2D.play("1 - walk")
	
	sonido_seta.finished.connect(_on_sonido_seta_finished)
	sonido_seta.play()

func _on_sonido_seta_finished():
		sonido_seta.play()

# =========================
# 🔄 LOOP PRINCIPAL
# =========================
func _physics_process(delta):

	# =========================
	# ☠️ ENEMIGO MUERTO
	# =========================
	if dead:
		velocity = Vector2.ZERO
		return

	# =========================
	# 🚶 MOVIMIENTO
	# =========================
	velocity.x = speed * direction
	move_and_slide()

	# =========================
	# 💥 ATAQUE AL PLAYER POR CONTACTO
	# =========================
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var body = collision.get_collider()

		# Si colisiona con el player
		if body and body.has_method("take_damage"):
			body.take_damage(20)

			# Knockback si el player lo soporta
			if body.has_method("apply_knockback"):
				body.apply_knockback(global_position)

	# =========================
	# ↔️ CAMBIO DE DIRECCIÓN
	# =========================
	if is_on_wall():
		direction *= -1
		$AnimatedSprite2D.flip_h = direction > 0

	# =========================
	# 🎬 ANIMACIÓN CAMINAR
	# =========================
	if !taking_damage and !dead:
		if $AnimatedSprite2D.animation != "1 - walk":
			$AnimatedSprite2D.play("1 - walk")


# =========================
# 🗡️ DETECCIÓN DE GOLPE DEL PLAYER
# =========================
func _on_seta_hitbox_area_entered(area):
	if dead:
		return

	# Solo detecta ataques del player
	if area.is_in_group("player_attack"):
		var player = area.get_parent()

		# Obtiene daño del jugador si existe
		if player.has_method("get_damage"):
			var damage = player.get_damage()
			take_damage(damage)


# =========================
# 💥 RECIBIR DAÑO
# =========================
func take_damage(damage):
	if invulnerable or dead:
		return

	health -= damage
	taking_damage = true
	invulnerable = true

	print("Vida enemigo:", health)

	# Animación de hit
	$AnimatedSprite2D.play("3 - hit")

	# Si muere
	if health <= 0:
		die()
	else:
		# cooldown de invulnerabilidad
		await get_tree().create_timer(invulnerability_time).timeout
		invulnerable = false
		taking_damage = false


# =========================
# ☠️ MUERTE
# =========================
func die():
	dead = true
	velocity = Vector2.ZERO
	sonido_seta.stop()
	
	print("Enemigo muerto")

	# 📢 AVISO AL GLOBAL: Emitimos la señal antes de destruir al enemigo
	Global.enemigo_muerto.emit()

	# Desactiva colisiones para evitar bugs
	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = true

	if has_node("Area2D"):
		$Area2D.set_deferred("monitoring", false)

	# Animación de muerte
	$AnimatedSprite2D.play("2 - dead")

	await $AnimatedSprite2D.animation_finished

	queue_free()
