extends Node
class_name LevelScreen

func _ready() -> void:
	%DebugLevels.visible = GameInstance.enable_debug

func _on_level_1_button_pressed() -> void:
	Global.phase = 0
	GameInstance.TravelToLevel(GameInstance.GameLevels.TUTORIAL_PHASE_1)

func _on_level_2_button_pressed() -> void:
	Global.phase = 1
	GameInstance.TravelToLevel(GameInstance.GameLevels.FROG_PHASE_1)

func _on_level_2b_button_pressed() -> void:
	Global.phase = 2
	GameInstance.TravelToLevel(GameInstance.GameLevels.FROG_PHASE_2)

func _on_back_button_pressed() -> void:
	UIManager.SwitchToPrevious()

func _on_debug_button_pressed() -> void:
	GameInstance.TravelToLevel(GameInstance.GameLevels.TOAD_ANIMS_TEST)
