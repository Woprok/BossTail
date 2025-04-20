extends Node
class_name MenuScreen

func _on_play_button_pressed() -> void:
	UIManager.SwitchToMode(UI.Mode.LEVEL)

func _on_settings_button_pressed() -> void:
	UIManager.SwitchToMode(UI.Mode.SETTINGS)

func _on_quit_button_pressed() -> void:
	GameInstance.Quit()
