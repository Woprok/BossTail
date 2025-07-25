extends CanvasLayer
# UI Manager handles all UI across all levels (scenes)
# Utilizes screens (Menu, Pause, Settings, Level, HUD) to show UI elements
# class_name UIManager #Defined as autoloaded Global as UIManager.tscn

# Defines pairs of UI.Mode to PackedScenes representing individual screens
@export var Screens: Dictionary[UI.Mode, PackedScene] = {}
@export var PreviousMode: UI.Mode = UI.Mode.MENU
@export var CurrentMode: UI.Mode = UI.Mode.MENU
var CurrentInstance: ScreenBase

func _ready() -> void:
	_switch_UI(CurrentMode)
	
# Switches between different UI Screens
func _switch_UI(new_mode: UI.Mode) -> void:
	# Cleans up current screen instance
	if CurrentInstance:
		remove_child(CurrentInstance)
		CurrentInstance.queue_free()
	# Instantiate next screen (safely) and save the previous in case of "Back"
	PreviousMode = CurrentMode
	CurrentMode = new_mode
	var scene = Screens[CurrentMode]
	if not scene:
		Global.LogError("MISSING %s." % UI.Mode.keys()[new_mode])
		return
	CurrentInstance = scene.instantiate()
	add_child(CurrentInstance)

func _set_cursor_mode(new_mode: UI.Mode) -> void:
	match new_mode:
		UI.Mode.HUD: # for HUD we want to capture it
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		UI.Mode.NONE: # if I ever decide that we can hide HUD
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
		_: #UI.Mode.PAUSE, UI.Mode.MENU, UI.Mode.SETTINGS:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func IsPauseable() -> bool:
	match CurrentMode:
		UI.Mode.VICTORY:
			return false
		UI.Mode.DEFEAT:
			return false
		UI.Mode.MENU:
			return false
		_:
			return true

func IsGame() -> bool:
	match CurrentMode:
		UI.Mode.HUD: # for HUD we want to capture it
			return true
		UI.Mode.NONE: # if I ever decide that we can hide HUD
			return true
		_: #UI.Mode.PAUSE, UI.Mode.MENU, UI.Mode.SETTINGS:
			return false

func SwitchToMode(mode: UI.Mode) -> void:
	_set_cursor_mode(mode)
	_switch_UI(mode)

func SwitchToPrevious() -> void:
	_set_cursor_mode(PreviousMode)
	_switch_UI(PreviousMode)
