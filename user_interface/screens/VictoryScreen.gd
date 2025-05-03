extends PausableScreenBase
class_name VictoryScreen

func _ready() -> void:
	%ContinueButton.visible = GameInstance.CanTravelToNextLevel()

func _on_continue_button_pressed() -> void:
	GameInstance.TravelToNextLevel()

func _on_restart_button_pressed() -> void:
	GameInstance.RestartCurrentLevel()

func _on_menu_button_pressed() -> void:
	GameInstance.TravelToMenu()
