extends Label

func _ready():
	Global.contador_actualizado.connect(_on_contador_actualizado)
	text = "Bajas: " + str(Global.enemigos_derrotados)

func _on_contador_actualizado(bajas_totales):
	text = "Bajas: " + str(bajas_totales)
