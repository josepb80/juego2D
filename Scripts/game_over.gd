extends CanvasLayer

# 🔁 REINICIAR JUEGO
func _on_retry_pressed():
	get_tree().paused = false
	
	if Global.last_scene_path != "":
		get_tree().change_scene_to_file(Global.last_scene_path)


# 🏠 IR AL MENÚ PRINCIPAL
func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _ready():
	var sprite = $AnimatedSprite2D
	sprite.play("default")
	
	var frames_totales = sprite.sprite_frames.get_frame_count("default")
	var fps = sprite.sprite_frames.get_animation_speed("default")
	var duracion = frames_totales / fps
	
	# Creamos un temporizador que espere exactamente ese tiempo
	await get_tree().create_timer(duracion).timeout
	
	# Frenazo de mano: detenemos y clavamos el último frame
	sprite.stop()
	sprite.frame = frames_totales - 1
