extends Resource
class_name UserSettings

# This is equal to project settings, thus it should be User/AppData/Roaming/Mouseketeer
var path_local_user: String = "user://"
var user_data_folder: String = "user_profile_data"
var path_user_settings_resource: String = "local_user_settings.tres"

@export var customizable_keybinds: Dictionary[StringName, String] = {
	"move_forward": "Move Forward",
	"move_back": "Move Back",
	"strafe_left": "Strafe Left",
	"strafe_right": "Strafe Right",
	"move_left": "Move Left",
	"move_right": "Move Right",
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
	_apply_keybinds(settings)

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
