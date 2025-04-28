extends Node
# Manages transitions between levels & screens
# class_name GameInstance #Defined as autoloaded Global

@export var enable_debug: bool = true

# Opted for enum, this makes it less likely to miss-spell 
enum GameLevels {
	MENU,
	TUTORIAL_PHASE_1,
	FROG_PHASE_1,
	FROG_PHASE_2,
	TOAD_ANIMS_TEST,
}

@export var default_user_settings: UserSettings = preload("res://data_resources/UserSettingsDefaultInstance.tres")

@export var CurrentLevel: GameLevels = GameLevels.MENU
# Levels
@export var Levels: Dictionary[GameLevels, String] = {
	GameLevels.MENU: "res://scenes/MenuScene.tscn",
	GameLevels.TUTORIAL_PHASE_1: "res://scenes/TutorialScene.tscn",
	GameLevels.FROG_PHASE_1: "res://scenes/FirstPhase.tscn",
	GameLevels.FROG_PHASE_2: "res://scenes/SecondPhase.tscn",
	GameLevels.TOAD_ANIMS_TEST: "res://scenes/test_scenes/ToadAnimationTesting.tscn",
}
@export var LevelTransitions: Dictionary[GameLevels, GameLevels] = {
	GameLevels.TUTORIAL_PHASE_1: GameLevels.FROG_PHASE_1
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_and_apply_local_user_settings()

func _load_and_apply_local_user_settings() -> void:
	default_user_settings.ApplyLocalSettings()	

func _unhandled_input(event: InputEvent) -> void:
	if _try_handle_pause(event):
		return
	if _try_handle_debug(event):
		return

func _try_handle_pause(event: InputEvent) -> bool:
	# We only need to process the navigation between HUD and PAUSE, thus in non menu level.
	if not event.is_action_pressed("pause") or not _can_pause():
		return false
	if _is_paused():
		ResumeGame()
	else:
		PauseGame()
	return true
		
func _try_handle_debug(event: InputEvent) -> bool:
	if not event.is_action_pressed("debug") or not enable_debug:
		return false
	# Swift debug tricks here
	PlayerVictorious()
	
	return true
		
func _can_pause() -> bool:
	return CurrentLevel != GameLevels.MENU

func _is_paused() -> bool:
	Global.LogInfo(get_tree().get_current_scene())
	return get_tree().paused
	
func _resume() -> void:
	get_tree().paused = false
	
func _pause() -> void:
	get_tree().paused = true

func PlayerDefeated():
	UIManager.SwitchToMode(UI.Mode.DEFEAT)
	_pause()
	
func PlayerVictorious():
	UIManager.SwitchToMode(UI.Mode.VICTORY)
	_pause()

# Level transition should move player to menu level and set UI as MENU
func TravelToMenu(new_level: GameLevels = GameLevels.MENU) -> void:
	CurrentLevel = new_level
	get_tree().change_scene_to_file(Levels[new_level])
	UIManager.SwitchToMode(UI.Mode.MENU)
	_resume()
	
# Level transition should move player to new level and set UI as HUD
func TravelToLevel(new_level: GameLevels) -> void:
	CurrentLevel = new_level
	get_tree().change_scene_to_file(Levels[new_level])
	UIManager.SwitchToMode(UI.Mode.HUD)
	_resume()

# This returns value based on CurrentLevel being in LevelTransitions
func CanTravelToNextLevel() -> bool:
	return LevelTransitions.has(CurrentLevel)

# This requires some basic setup, see LevelTransitions
func TravelToNextLevel() -> void:
	if not CanTravelToNextLevel():
		Global.LogError("UNVERIFIED ATTEMPT TO ACCESS NEXT LEVEL")
		return
	Global.phase += 1
	TravelToLevel(LevelTransitions[CurrentLevel])

# Reload the last set scene
func RestartCurrentLevel() -> void:
	get_tree().reload_current_scene()
	UIManager.SwitchToMode(UI.Mode.HUD)
	_resume()

func Quit() -> void:
	UIManager.SwitchToMode(UI.Mode.NONE)
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func PauseGame() -> void:
	UIManager.SwitchToMode(UI.Mode.PAUSE)
	_pause()
	
func ResumeGame() -> void:
	UIManager.SwitchToPrevious()
	_resume()
