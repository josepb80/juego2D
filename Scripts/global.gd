extends Node

signal enemigo_muerto

signal contador_actualizado(bajas)
signal caidas_actualizado(caidas)

var enemigos_derrotados: int = 0
var jugador_referencia = null
var caidas_totales: int = 0
var playerBody: CharacterBody2D 
var playerDamageZone: Area2D
var playerDamageAmount: int = 15

var last_scene_path: String = ""

func _enter_tree() -> void:
	if Checkpoint.last_position:
		$Player.global_position = Checkpoint.last_position
