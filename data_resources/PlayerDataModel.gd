extends Resource
class_name PlayerDataModel

@export var jump_value: int = 0
@export var melee_enabled: bool = true
@export var ranged_enabled: bool = true
@export var dash_enabled: bool = true

@export var player_current_health: int = 100
@export var player_min_health: int = 0
@export var player_max_health: int = 100

func player_restart() -> void:
	player_current_health = player_max_health

func change_jump_height(value):
	jump_value = value
		
func change_melee_indicator(value):
	melee_enabled = value

func change_ranged_indicator(value):
	ranged_enabled = value	

func change_dash_indicator(value):
	dash_enabled = value
	
func is_player_dead() -> bool:
	return player_current_health <= player_min_health
	
func player_decrease_health(value):
	player_current_health -= value
	if player_current_health <= player_min_health:
		player_current_health = player_min_health
	
func player_increase_health(value):
	player_current_health += value	
	if player_current_health >= player_max_health:
		player_current_health = player_max_health
