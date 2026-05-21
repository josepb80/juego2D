extends Control

@onready var musica_menu = $musica_menu

func _ready() -> void:
		musica_menu.play()

# =========================
# 🎮 BOTÓN JUGAR
# =========================
func _on_play_pressed() -> void:
	# Cambia a la escena principal del juego (mapa 1)
	get_tree().change_scene_to_file("res://Scenes/map1.scn")


# =========================
# 📖 BOTÓN TUTORIAL
# =========================
func _on_controls_pressed() -> void:
	# Abre la escena del tutorial o pantalla de controles
	get_tree().change_scene_to_file("res://Scenes/tutorial.scn")


# =========================
# 🚪 BOTÓN SALIR
# =========================
func _on_exit_pressed() -> void:
	# Cierra completamente el juego
	get_tree().quit()
