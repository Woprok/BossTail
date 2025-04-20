extends ProgressBar
class_name HealthBar

func change_health(current, max):
	min_value = 0
	max_value = max
	value = current
	#var tween = get_tree().create_tween()
	#tween.tween_property($".", "value", current, 0.2)
