extends TextureRect
class_name ActionIcon

# The shader is from 0 - 1 so this tries to normalize it. 

var total_progress: float = 0.0
var current_progress: float = 0.0

func AddProgress(progress: float) -> void:
	total_progress += progress
	current_progress = total_progress / 100.0
	material.set_shader_parameter("progress", current_progress) 
	
func ResetProgress(progress: float) -> void:
	total_progress = 0.0
	current_progress = 0.0
	material.set_shader_parameter("progress", current_progress) 
