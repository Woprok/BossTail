extends Resource
class_name AmmoStatus

@export var max: int = 1
@export var min: int = 0
# current, the value that's updated
@export var current: int = 0
# this enables for player to start with an ammo
@export var initial: int = 0
# technically this is not needed, but I wanted to make fancy UI
@export var is_special: bool = false

func _init(new_initial: int, new_max: int, new_is_special: bool = false) -> void:
	initial = new_initial
	current = new_initial
	min = 0
	max = new_max
	is_special = new_is_special
	
func has_any_ammo_left() -> bool:
	return current > min  

func add() -> void:
	current = clamp(current + 1, min, max)
	
func use() -> void:
	current = clamp(current - 1, min, max)
	
func reset() -> void:
	current = initial
	
func can_pick() -> bool:
	return current < max 
