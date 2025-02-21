extends Node2D
@export var health:int = 100

func _ready():
	$ProgressBar.value = health

func decHealth(value):
	health -= value
	var tween = get_tree().create_tween()
	tween.tween_property($ProgressBar, "value", health, 0.2)
	
func addHealth(value):
	health += value	
	var tween = get_tree().create_tween()
	tween.tween_property($ProgressBar, "value", health, 0.2)
