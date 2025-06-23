extends Resource
class_name UserSettings

# This is equal to project settings, thus it should be User/AppData/Roaming/Mouseketeer
var path_local_user: String = "user://"
var user_data_folder: String = "user_profile_data"
var path_user_settings_resource: String = "local_user_settings.tres"

@export var customizable_keybinds: Dictionary[StringName, String] = {
	"move_forward": "Move Forward",
	"move_back": "Move Back",
	"strafe_left": "Move Left",
	"strafe_right": "Move Right",
	"camera_up": "Camera Up",
	"camera_down": "Camera Down",
	"camera_left": "Camera Left",
	"camera_right": "Camera Right",
	"jump": "Jump",
	"dash": "Dash",
	"fight": "Attack / Throw (During Aim)",
	"aim": "Aim",
	"pause": "Pause / Menu",
}

func GetUserSettingsFullPath() -> String:
	return path_local_user + user_data_folder + '/' + path_user_settings_resource

func ApplyLocalSettings() -> void:
	var settings = GetUserSettings()
	_apply_audio(settings)
	_apply_keybinds(settings)
#	_apply_sensitivity(settings)
	_apply_window(settings)

func _apply_window(settings: LocalUserSettings) -> void:
	ToggleFullScreen(settings.is_full_screen)
	
func ToggleFullScreen(is_full_screen: bool) -> void:
	if is_full_screen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif not is_full_screen and DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _apply_audio(settings: LocalUserSettings) -> void:
	AudioClipManager.set_volume_multipliers(
		settings.audio_master_volume, 
		settings.audio_music_volume, 
		settings.audio_sound_volume
	)

#func _apply_sensitivity(_settings: LocalUserSettings) -> void:
#	Global.LogInfo("Sensitivity is applied directly on the character.")
#	pass

func _apply_keybinds(settings: LocalUserSettings) -> void:
	for keybind in customizable_keybinds.keys():
		if settings.HasKeybind(keybind):
			var bindings = settings.GetKeybind(keybind)
			InputMap.action_erase_events(keybind)
			for bind in bindings:
				InputMap.action_add_event(keybind, bind)

func GetUserSettings() -> LocalUserSettings:
	var existing = null
	if FileAccess.file_exists(GetUserSettingsFullPath()):
		existing = load(GetUserSettingsFullPath())
	else:
		existing = LocalUserSettings.new()
	return existing
	
func SaveUserSettings(local_user_settings: LocalUserSettings) -> void:
	_verify_save_directory()
	ResourceSaver.save(local_user_settings, GetUserSettingsFullPath())
		
func _verify_save_directory() -> void:
	var data_directory = DirAccess.open(path_local_user)
	if !data_directory.dir_exists(user_data_folder):
		data_directory.make_dir(user_data_folder) 
