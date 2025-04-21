extends Node
class_name HUDScreen

@export var player_data: PlayerDataModel = preload("res://data_resources/PlayerDataModelInstance.tres")
@export var boss_data: BossDataModel
	
func _ready() -> void:
	self.mouse_filter = Control.MOUSE_FILTER_PASS
	# Boss Data Setup
	GameEvents.boss_changed.connect(_on_boss_data_changed)
	if GameEvents.boss_data:
		_on_boss_data_changed(GameEvents.boss_data)
	# Player Data Setup
	%PlayerHealthBar.SetHealth(player_data.player_min_health, player_data.player_current_health, player_data.player_max_health)
	
func _on_boss_data_changed(new_data: BossDataModel):
	# Rebind old for new
	if boss_data:
		boss_data.OnHealthChanged.disconnect(UpdateBossHealth)
	boss_data = new_data
	boss_data.OnHealthChanged.connect(UpdateBossHealth)
	# Update
	%BossHealthBar.SetHealth(boss_data.boss_min_health, boss_data.boss_current_health, boss_data.boss_max_health)
	%BossHealthBar.SetName(boss_data.boss_name)
	
func _exit_tree() -> void:
	boss_data.OnHealthChanged.disconnect(UpdateBossHealth)
	
func UpdateBossHealth() -> void:
	%BossHealthBar.ChangeHealth(boss_data.boss_current_health)
	
func _process(delta: float) -> void:
	%PlayerHealthBar.ChangeHealth(player_data.player_current_health)
	change_melee_indicator(player_data.melee_enabled)
	change_ranged_indicator(player_data.ranged_enabled)
	change_dash_indicator(player_data.dash_enabled)
	change_jump_height(player_data.jump_value)

func change_jump_height(value):
	if value == 0:
		%JumpIcon.ResetProgress(0.0)
		#%JumpIcon.texture = load("res://assets/temp/jump.png")
	else:
		%JumpIcon.AddProgress(value)
		#%JumpIcon.texture = load("res://assets/temp/jump_d.png")	
		
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
