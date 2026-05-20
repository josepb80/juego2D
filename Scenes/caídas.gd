extends Label

func _ready():
	# Nos conectamos a la nueva señal del Global
	Global.caidas_actualizado.connect(_on_caidas_actualizado)
	text = "Caídas: " + str(Global.caidas_totales)

func _on_caidas_actualizado(caidas):
	text = "Caídas: " + str(caidas)
