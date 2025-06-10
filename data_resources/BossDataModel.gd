extends Resource
class_name BossDataModel

@export var health_standard: HealthStatus
@export var health_special: HealthStatus

@export var boss_name: String = "BOSS"
# Whatever this supports tutorial or not
@export var has_tutorial: bool = false
@export var tutorial_data: TutorialDataModel = null

signal OnHealthChanged

func boss_restart() -> void:
	health_standard.reset()
	health_special.reset()

func get_current_health() -> int:
	return health_standard.current

func is_boss_dead() -> bool:
	return not health_standard.has_any_health_left()
	
func boss_take_damage(value): #boss_decrease_health
	if health_special.has_any_health_left():
		health_special.decrease(value)
	else:
		health_standard.decrease(value)
	OnHealthChanged.emit()
	
func boss_heal(value): #boss_increase_health
	if health_special.has_any_health_left() and health_special.can_heal:
		health_special.increase(value)
	else:
		health_standard.increase(value)
	OnHealthChanged.emit()

func start_health_special():
	health_special.increase(100)
	OnHealthChanged.emit()
	
