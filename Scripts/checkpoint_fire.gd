extends Area2D

func _ready():
	$AnimatedSprite2D.play("orange_fire")
	$PointLightOrange.visible = true
	$PointLightBlue.visible = false
	$Particulas_naranja.visible = true
	$Particulas_azul.visible = false
	
func _on_body_entered(body: Node2D):
	if $PointLightBlue.visible == true:
		return
	
	Checkpoint.last_position = global_position + Vector2(0, 0)
	$AnimatedSprite2D.play("blue_fire")
	$PointLightOrange.visible = false
	$PointLightBlue.visible = true
	$Particulas_naranja.visible = false
	$Particulas_azul.visible = true
		
	$"Sonido avivandose".play()
