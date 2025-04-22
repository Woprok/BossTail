extends Node

var phase = 1

static func LogInfo(log) -> void:
	print_rich("[color=white][INFO] ", log)
	
static func LogError(log) -> void:
	print_rich("[color=red][ERROR] ", log)
