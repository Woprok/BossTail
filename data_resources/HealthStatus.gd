extends Resource
class_name HealthStatus

@export var max: float = 100.0
@export var min: float = 0.0
# current, the value that's updated
@export var current: float = 0.0
# by default health starts at this value
@export var initial: float = 0.0
# defines if this HealthStatus allows healing
# note this has no impact on increase and decrease calls
@export var can_heal: bool = true
	
func has_any_health_left() -> bool:
	return current > min  

func increase(value) -> void:
	current = clampf(current + value, min, max)
	
func decrease(value) -> void:
	current = clampf(current - value, min, max)
	
func reset() -> void:
	current = initial
