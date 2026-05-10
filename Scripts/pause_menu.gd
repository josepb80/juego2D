extends Control

func _ready():
	visible = false

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	await $AnimationPlayer.animation_finished
	visible = false # <--- Al ponerse en false, Godot desactiva los clics

func pause():
	visible = true # <--- Al ponerse en true, los botones vuelven a la vida
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func testEsc():
	if Input.is_action_just_pressed("esc"):
		if get_tree().paused:
			resume()
		else:
			pause()

func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	# Despausar antes de cambiar de escena o la nueva escena nacerá pausada
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _process(_delta):
	testEsc()
