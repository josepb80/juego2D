extends Area2D  # Área de colisión usada como portal o trigger de cambio de nivel

# Prefijo de las escenas de niveles (mapas)
const FILE_BEGIN = "res://Scenes/map"
const FINAL_SCENE = "res://Scenes/final.tscn"

# =========================
# INICIO
# =========================
func _ready():
	# Reproduce la animación del portal (por ejemplo fuego o efecto visual)
	$AnimatedSprite2D.play("fire")


# =========================
# 🚪 ENTRADA DEL JUGADOR
# =========================
func _on_body_entered(body: CharacterBody2D) -> void:
	# Solo funciona si quien entra pertenece al grupo "Player"
	if body.is_in_group("Player"):

		# Obtiene la ruta de la escena actual
		var current_scene_file = get_tree().current_scene.scene_file_path

		# Convierte el nombre del nivel a número y suma 1 (siguiente nivel)
		var next_level_number = current_scene_file.to_int() + 1

		# Construye la ruta del siguiente nivel
		var next_level_path = FILE_BEGIN + str(next_level_number) + ".scn"

		# Cambia a la siguiente escena
		if FileAccess.file_exists(next_level_path):
			get_tree().change_scene_to_file(next_level_path)
		else:
			get_tree().change_scene_to_file(FINAL_SCENE)
