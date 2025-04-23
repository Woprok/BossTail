extends Node

var phase = 0

static func LogInfo(log) -> void:
	print_rich("[color=white][INFO] ", log)
	
static func LogError(log) -> void:
	print_rich("[color=red][ERROR] ", log)
