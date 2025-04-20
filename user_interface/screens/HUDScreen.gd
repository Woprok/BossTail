extends Node
class_name HUDScreen

func _ready() -> void:
	self.mouse_filter = Control.MOUSE_FILTER_PASS

@export var player_data: PlayerDataModel = preload("res://data_resources/PlayerDataModelInstance.tres")
@export var boss_data: BossDataModel = preload("res://data_resources/BossDataModelInstance.tres")

func _process(delta: float) -> void:
	%BossHealthBar.change_health(boss_data.boss_current_health, boss_data.boss_max_health)
	%PlayerHealthBar.change_health(player_data.player_current_health, player_data.player_max_health)
	change_melee_indicator(player_data.melee_enabled)
	change_ranged_indicator(player_data.ranged_enabled)
	change_dash_indicator(player_data.dash_enabled)
	change_jump_height(player_data.jump_value)

func change_jump_height(value):
	if value == 0:
		%jump_indicator.value = 0
		%JumpIcon.texture = load("res://assets/temp/jump.png")
	else:
		%jump_indicator.value += value
		%JumpIcon.texture = load("res://assets/temp/jump_d.png")	
		
func change_melee_indicator(value):
	if value:
		%MeleeIcon.texture = load("res://assets/temp/slash.png")	
	else:
		%MeleeIcon.texture = load("res://assets/temp/slash_d.png")	

func change_ranged_indicator(value):
	if value:
		%RangedIcon.texture = load("res://assets/temp/throw.png")	
	else:
		%RangedIcon.texture = load("res://assets/temp/throw_d.png")		

func change_dash_indicator(value):
	if value:
		%DashIcon.texture = load("res://assets/temp/dash.png")	
	else:
		%DashIcon.texture = load("res://assets/temp/dash_d.png")	
