extends Node
# Manages transitions between levels & screens
# class_name GameInstance #Defined as autoloaded Global

# Opted for enum, this makes it less likely to miss-spell 
enum GameLevels {
	MENU,
	TUTORIAL_PHASE_1,
	FROG_PHASE_1,
	FROG_PHASE_2,
}

@export var CurrentLevel: GameLevels = GameLevels.MENU
# Levels
@export var Levels: Dictionary[GameLevels, String] = {
	GameLevels.MENU: "res://scenes/MenuScene.tscn",
	GameLevels.TUTORIAL_PHASE_1: "res://scenes/TutorialScene.tscn",
	GameLevels.FROG_PHASE_1: "res://scenes/FirstPhase.tscn",
	GameLevels.FROG_PHASE_2: "res://scenes/SecondPhase.tscn",
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	# We only need to process the navigation between HUD and PAUSE, thus in non menu level.
	if not event.is_action_pressed("pause") or not _can_pause():
		return
	if _is_paused():
		ResumeGame()
	else:
		PauseGame()
		
func _can_pause() -> bool:
	return CurrentLevel != GameLevels.MENU

func _is_paused() -> bool:
	Global.LogInfo(get_tree().get_current_scene())
	return get_tree().paused
	
func _resume() -> void:
	get_tree().paused = false
	
func _pause() -> void:
	get_tree().paused = true

# Level transition should move player to menu level and set UI as MENU
func TravelToMenu(new_level: GameLevels = GameLevels.MENU) -> void:
	CurrentLevel = new_level
	get_tree().change_scene_to_file(Levels[new_level])
	UIManager.SwitchToMenu()
	_resume()
	
# Level transition should move player to new level and set UI as HUD
func TravelToLevel(new_level: GameLevels) -> void:
	CurrentLevel = new_level
	get_tree().change_scene_to_file(Levels[new_level])
	UIManager.SwitchToHUD()
	_resume()

func Quit() -> void:
	UIManager.SwitchToNone()
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func PauseGame() -> void:
	UIManager.SwitchToPause()
	_pause()
	
func ResumeGame() -> void:
	UIManager.SwitchToPrevious()
	_resume()
