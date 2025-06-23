extends ScreenBase
class_name SettingsScreen

@export var default_user_settings: UserSettings = preload("res://data_resources/UserSettingsDefaultInstance.tres")

func _ready() -> void:
	# setup the keybind list
	%KeybindList.LoadListFrom(default_user_settings)
	%FullScreenCheckButton.connect("toggled", OnFullScreenToggle)
	LoadValues(default_user_settings.GetUserSettings())

func _exit_tree() -> void:
	%FullScreenCheckButton.disconnect("toggled", OnFullScreenToggle)

func _on_back_button_pressed() -> void:
	UIManager.SwitchToPrevious()

func _on_save_button_pressed() -> void:
	var local: LocalUserSettings = default_user_settings.GetUserSettings()
	# Saves and applies
	%KeybindList.ApplyList()
	%KeybindList.SaveListTo(local)
	# Saves
	SaveValuesTo(local)
	# Rewrite
	default_user_settings.SaveUserSettings(local)
	# Once more apply the new saved settings
	default_user_settings.ApplyLocalSettings()
	UIManager.SwitchToPrevious()

func _on_reset_button_pressed() -> void:
	# Reset keybinds to default
	InputMap.load_from_project_settings()
	var local: LocalUserSettings = default_user_settings.GetUserSettings()
	# Resets
	local.ResetKeybinds()
	local.ResetValues()
	# Rewrite
	default_user_settings.SaveUserSettings(local)	
	# HARD RESET OF UI
	%KeybindList.ClearList()
	%KeybindList.LoadListFrom(default_user_settings)
	LoadValues(local)

func LoadValues(local_user_settings: LocalUserSettings) -> void:
	# load correct value, this option works without saving as it's toggle
	%FullScreenCheckButton.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	%CameraSensitivitySlider.value = local_user_settings.mouse_camera_sensititivy
	%AimSensitivitySlider.value = local_user_settings.mouse_aim_sensititivy
	%MasterVolumeSlider.value = local_user_settings.audio_master_volume
	%MusicVolumeSlider.value = local_user_settings.audio_music_volume
	%SoundVolumeSlider.value = local_user_settings.audio_sound_volume

func OnFullScreenToggle(button_pressed: bool) -> void:
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
func SaveValuesTo(local_user_settings: LocalUserSettings) -> void:
	local_user_settings.is_full_screen = %FullScreenCheckButton.button_pressed
	local_user_settings.mouse_camera_sensititivy = %CameraSensitivitySlider.value
	local_user_settings.mouse_aim_sensititivy = %AimSensitivitySlider.value
	local_user_settings.audio_master_volume = %MasterVolumeSlider.value
	local_user_settings.audio_music_volume = %MusicVolumeSlider.value
	local_user_settings.audio_sound_volume = %SoundVolumeSlider.value
