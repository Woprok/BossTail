extends Node2D

# UI simplified to single file
# For current project purposes we need only basic menu with level selection
# Additionally, we have basic HUD and we might have Settings 
# Due to that we will keep MENU, PAUSE, LEVEL, SETTINGS screen contained
# in single UI

@export var menu_scene: String = "res://scenes/MenuScene.tscn"
@export var level1_scene: String = "res://scenes/TutorialScene.tscn"
@export var level2_scene: String = "res://scenes/FirstPhase.tscn"
@export var level2b_scene: String = "res://scenes/SecondPhase.tscn"

enum UIMode {
	MENU,
	PAUSE,
	SETTINGS,
	LEVEL,
	HUD,
	NONE
}

@export var CurrentMode: UIMode = UIMode.MENU

func _ready() -> void:
	switch_UI(CurrentMode)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func switch_UI(mode: UIMode) -> void:
	if mode == UIMode.MENU:
		%MENU_ACTIONS.visible = true
		%PAUSE_ACTIONS.visible = false
		%LEVEL_ACTIONS.visible = false
		%SETTINGS_ACTIONS.visible = false
	elif mode == UIMode.PAUSE:
		%MENU_ACTIONS.visible = false
		%PAUSE_ACTIONS.visible = true
		%LEVEL_ACTIONS.visible = false
		%SETTINGS_ACTIONS.visible = false
	elif mode == UIMode.LEVEL:
		%MENU_ACTIONS.visible = false
		%PAUSE_ACTIONS.visible = false
		%LEVEL_ACTIONS.visible = true
		%SETTINGS_ACTIONS.visible = false
	elif mode == UIMode.SETTINGS:
		%MENU_ACTIONS.visible = false
		%PAUSE_ACTIONS.visible = false
		%LEVEL_ACTIONS.visible = false
		%SETTINGS_ACTIONS.visible = true
	elif mode == UIMode.HUD:
		%MENU_ACTIONS.visible = false
		%PAUSE_ACTIONS.visible = false
		%LEVEL_ACTIONS.visible = false
		%SETTINGS_ACTIONS.visible = false
	else:
		%MENU_ACTIONS.visible = false
		%PAUSE_ACTIONS.visible = false
		%LEVEL_ACTIONS.visible = false
		%SETTINGS_ACTIONS.visible = false

func _unhandled_input(event: InputEvent) -> void:
	# We only need to process the navigation between HUD and PAUSE
	if not event.is_action("pause"):
		return
	if CurrentMode == UIMode.HUD:
		switch_UI(UIMode.PAUSE)
	elif CurrentMode == UIMode.PAUSE:
		switch_UI(UIMode.HUD)

func _on_play_button_pressed() -> void:
	switch_UI(UIMode.LEVEL)

func _on_resume_button_pressed() -> void:
	switch_UI(UIMode.HUD)

func _on_settings_button_pressed() -> void:
	switch_UI(UIMode.SETTINGS)

func _on_menu_button_pressed() -> void:
	# Level transition should move player back to menu level and set UI as MENU
	switch_UI(UIMode.MENU)
	get_tree().change_scene_to_file(menu_scene)

func _on_quit_button_pressed() -> void:
	# Quit
	switch_UI(UIMode.NONE)
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func _on_back_button_pressed() -> void:
	switch_UI(UIMode.MENU)

func _on_level_1_button_pressed() -> void:
	# Level transition should move player to new level and set UI as HUD
	switch_UI(UIMode.HUD)
	get_tree().change_scene_to_file(level1_scene)

func _on_level_2_button_pressed() -> void:
	# Level transition should move player to new level and set UI as HUD
	switch_UI(UIMode.HUD)
	get_tree().change_scene_to_file(level2_scene)


func _on_level_2b_button_pressed() -> void:
	# Level transition should move player to new level and set UI as HUD
	switch_UI(UIMode.HUD)
	get_tree().change_scene_to_file(level2b_scene)
