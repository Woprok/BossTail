extends Resource
class_name PlayerDataModel

@export var jump_value: int = 0
@export var melee_enabled: bool = true
@export var ranged_enabled: bool = true
@export var dash_enabled: bool = true

@export var player_current_health: int = 100
@export var player_min_health: int = 0
@export var player_max_health: int = 100

@export var ammo_standard: AmmoStatus
@export var ammo_special: AmmoStatus

signal OnHealthChanged
signal OnAmmoChanged(ammo: AmmoStatus)

# This needs wrapper for callback
func player_ammo_picked(is_special: bool = false) -> void:
	if is_special:
		ammo_special.add()
	else:
		ammo_standard.add()
	# Update UI
	_player_ammo_update()
	
# This needs wrapper for callback
func player_ammo_used(is_special: bool = false) -> void:
	if is_special:
		ammo_special.use()
	else:
		ammo_standard.use()
	# Update UI
	_player_ammo_update()

func _player_ammo_update():
	if ammo_special.has_any_ammo_left():
		OnAmmoChanged.emit(ammo_special)
	else:
		OnAmmoChanged.emit(ammo_standard)
	

func player_restart() -> void:
	player_current_health = player_max_health
	ammo_special.reset()
	ammo_standard.reset()
	OnHealthChanged.emit()
	_player_ammo_update()

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
	OnHealthChanged.emit()
	
func player_increase_health(value):
	player_current_health += value	
	if player_current_health >= player_max_health:
		player_current_health = player_max_health
	OnHealthChanged.emit()
