extends PausableScreenBase
class_name DefeatScreen

func _on_restart_button_pressed() -> void:
	GameInstance.RestartCurrentLevel()

func _on_menu_button_pressed() -> void:
	GameInstance.TravelToMenu()
