extends Node
# Manages ingame global signals and appropriate callbacks if necessary
# class_name GameEvents #Defined as autoloaded Global

# Basically, this exists to following issue:
# If Boss is loaded it needs to announce it's data
# If HUD is loaded it needs to get current Boss data
# Problem, unless we want to explicitely say, which should happen first
# we meed to be prepared for both cases of either being first
# Thus the current solution is for boss to announce and HUD to read and listen  

func _ready() -> void:
	boss_changed.connect(func(data: BossDataModel): boss_data = data)
	tutorial_phase.connect(_on_tutorial_phase)
	boss_started.connect(_on_boss_started)
	boss_restarted.connect(_on_boss_restarted)
	boss_menu_end.connect(_on_boss_menu_end)
	boss_defeat.connect(_on_boss_finished)

var boss_data: BossDataModel
signal boss_changed(data: BossDataModel)

var tutorial_phase_data: int
signal tutorial_phase(phase: int)

var time_per_phase_total: float = 0
var time_per_phase: float = 0
var time_for_level: String = "-1"

signal boss_menu_end(level: String)
signal boss_started(level: String)
signal boss_restarted(level: String)
signal boss_defeat(success: bool)

func _on_tutorial_phase(phase: int) -> void:
	if phase == 0:
		tutorial_phase_data = 0
		time_per_phase_total = 0 #miliseconds
		time_per_phase = 0 #miliseconds
		Global.LogMetrics("TUTORIAL")
		return
	_log_time()
	tutorial_phase_data = phase
	
func _process(delta: float) -> void:
	time_per_phase_total += delta #miliseconds
	time_per_phase += delta #miliseconds
		
func _log_time() -> void:
	Global.LogMetrics("POINT;" + str(tutorial_phase_data) + ";TIME;" + str(time_per_phase) + ";LEVEL;" + time_for_level)
	time_per_phase = 0 #miliseconds

func _on_boss_finished(success: bool) -> void:
	_log_time()
	Global.LogMetrics("LEVEL;" + time_for_level + ";TIME;" + str(time_per_phase_total) + ";SUCCESS;" + str(success))
	Global.LogMetrics("GAMEOVER")
	
func _log_level_start(level) -> void:
	tutorial_phase_data = 0
	time_per_phase_total = 0 #miliseconds
	time_per_phase = 0 #miliseconds
	time_for_level = level
	Global.LogMetrics("LEVEL;" + level)
	
func _on_boss_started(level: String) -> void:
	Global.LogMetrics("STARTED")
	_log_level_start(level)
	
func _on_boss_restarted(level: String) -> void:
	Global.LogMetrics("RESTARTED")
	_log_level_start(level)
	
func _on_boss_menu_end(level: String) -> void:
	Global.LogMetrics("LEVEL;" + time_for_level + ";TIME;" + str(time_per_phase_total))
	Global.LogMetrics("MENU")
