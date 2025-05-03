extends PausableScreenBase
class_name PauseScreen

func _on_resume_button_pressed() -> void:
	GameInstance.ResumeGame()

func _on_menu_button_pressed() -> void:
	GameInstance.TravelToMenu()
