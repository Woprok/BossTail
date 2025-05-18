extends GameScreenBase
class_name HUDScreen

@export var player_data: PlayerDataModel = preload("res://data_resources/PlayerDataModelInstance.tres")
@export var boss_data: BossDataModel
	
func _ready() -> void:
	# Boss Data Setup
	GameEvents.boss_changed.connect(_on_boss_data_changed)
	if GameEvents.boss_data:
		_on_boss_data_changed(GameEvents.boss_data)
	# Player Data Setup
	%PlayerHealthBar.SetHealth(player_data.player_min_health, player_data.player_current_health, player_data.player_max_health)
	player_data.OnHealthChanged.connect(UpdatePlayerHealth)

func _on_boss_data_changed(new_data: BossDataModel):
	# Rebind old for new
	if boss_data:
		boss_data.OnHealthChanged.disconnect(UpdateBossHealth)
		_deattach_tutorial()
	boss_data = new_data
	boss_data.OnHealthChanged.connect(UpdateBossHealth)
	# Update
	%BossHealthBar.SetHealth(boss_data.boss_min_health, boss_data.boss_current_health, boss_data.boss_max_health)
	%BossHealthBar.SetName(boss_data.boss_name)
	
	_toggle_tutorial(new_data.has_tutorial)
	
func _toggle_tutorial(new_visibility: bool) -> void:
	%TutorialObjectiveWrapper.visible = new_visibility
	# toggle on true needs to always update tutorial
	if new_visibility:
		_attach_tutorial()
		_update_tutorial(GameEvents.tutorial_phase_data)

func _attach_tutorial() -> void:
	if boss_data.has_tutorial:
		GameEvents.tutorial_phase.connect(_update_tutorial)

func _deattach_tutorial() -> void:
	if boss_data.has_tutorial:
		GameEvents.tutorial_phase.disconnect(_update_tutorial)
	
func _update_tutorial(phase: int) -> void:
	%TutorialHint.SetData(boss_data.tutorial_data, phase)
	%BossHealthBar.SetName(boss_data.tutorial_data.Names.get(phase))
	
func _exit_tree() -> void:
	boss_data.OnHealthChanged.disconnect(UpdateBossHealth)
	player_data.OnHealthChanged.disconnect(UpdatePlayerHealth)
	
func UpdateBossHealth() -> void:
	%BossHealthBar.ChangeHealth(boss_data.boss_current_health)

func UpdatePlayerHealth() -> void:
	%PlayerHealthBar.ChangeHealth(player_data.player_current_health)
	
func _process(_delta: float) -> void:
	change_melee_indicator(player_data.melee_enabled)
	change_ranged_indicator(player_data.ranged_enabled)
	change_dash_indicator(player_data.dash_enabled)
	change_jump_height(player_data.jump_value)

func change_jump_height(value):
	if value == 0:
		%JumpIcon.ResetProgress()
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
