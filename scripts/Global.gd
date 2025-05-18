extends Node
# class_name Global
# This is by default static.
# Do not place gameplay functionality here.

var phase = 0

func LogInfo(log_content) -> void:
	print_rich("[color=white][INFO] ", log_content)
	
func LogError(log_content) -> void:
	print_rich("[color=red][ERROR] ", log_content)
