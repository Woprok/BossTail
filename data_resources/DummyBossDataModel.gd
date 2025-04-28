extends BossDataModel
class_name DummyBossDataModel

func _init() -> void:
	has_tutorial_data = true

@export var TutorialPhases: int = 0

@export var Objectives: Dictionary[int, String] = {
	0: "Get to the Dummy",
	1: "Traverse the arena",
	2: "Pass through Small Dummy by destroying it",
	3: "Beat the Angry Dummy",
}

@export var Names: Dictionary[int, String] = {
	0: "Peaceful Dummy",
	1: "Sharing Dummy",
	2: "Small Dummy",
	3: "Angry Dummy",
}

@export var ControlHintTitles: Dictionary[int, String] = {
	0: "Movement & Camera",
	1: "Jump & Dash",
	2: "Throw & Slash",
	3: "BOSS"
}

@export var ControlHints: Dictionary[int, String] = {
	0: "You can move (TODO_MOVE WASD) and control camera (TODO_CAMERA Q/E or Mouse).",
	1: "Abilities are shown down here.\nJump over obstacles with (TODO_JUMP SPACE).\nDash to gain forward movement boost with (TODO_DASH SHIFT).",
	2: "You can throw small objects, such as rock.\n Start AIM with (TODO_AIM RMB) and THROW (TODO_STAB LMB).",
	3: "Bosses will hit you back.\nUse everything you have and see to beat them.\n"
}
