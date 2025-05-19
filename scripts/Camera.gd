extends Node3D

var random_strength = 30.0
var shakeFade = 5.0
var shake_strength = 0.0
var origin_position

func _ready():
	origin_position = position

func apply_shake():
	shake_strength = random_strength
	
func _process(_delta):
	if shake_strength>0:
		shake_strength -=shakeFade/3
		position += randomOffset()
	else:
		position = origin_position
	
func randomOffset():
	return Vector3(randf_range(-0.75,0.75),0,0)
