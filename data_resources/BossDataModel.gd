extends Resource
class_name BossDataModel

@export var boss_current_health: int = 100
@export var boss_min_health: int = 0
@export var boss_max_health: int = 100

@export var boss_name: String = "BAD DATA FOR BOSS"
# Class needs to support it, see DummyBossDataModel
var has_tutorial_data: bool = false

signal OnHealthChanged

func boss_restart() -> void:
	boss_current_health = boss_max_health

func get_current_health() -> int:
	return boss_current_health

func is_boss_dead() -> bool:
	return boss_current_health <= boss_min_health
	
func boss_decrease_health(value):
	boss_current_health -= value
	if boss_current_health <= boss_min_health:
		boss_current_health = boss_min_health
	OnHealthChanged.emit()
	
func boss_increase_health(value):
	boss_current_health += value	
	if boss_current_health >= boss_max_health:
		boss_current_health = boss_max_health
	OnHealthChanged.emit()
