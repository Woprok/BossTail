extends Node

var phase = 1
var phase2 = preload("res://scenes/SecondPhase.tscn")

func changeScene():
	if phase == 1:
		phase = 2
		get_tree().change_scene_to_packed(phase2)


static func LogInfo(log) -> void:
	print_rich("[color=white][INFO] ", log)
	
static func LogError(log) -> void:
	print_rich("[color=red][ERROR] ", log)
