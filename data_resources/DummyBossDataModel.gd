extends BossDataModel
class_name DummyBossDataModel

func _init() -> void:
	has_tutorial_data = true

@export var TutorialPhases: int = 0

@export var Names: Dictionary[int, String] = {
	0: "Peaceful Dummy",
	1: "Sharing Dummy",
	2: "Small Dummy",
	3: "Angry Dummy",
}

@export var Objectives: Dictionary[int, String] = {
	0: "Find & Reach Dummy",
	1: "Cross the Arena",
	2: "Destroy Small Dummy",
	3: "Defeat Angry Dummy",
}

@export var ObjectiveFlavors: Dictionary[int, String] = {
	0: '"It’s just across the arena."',
	1: '"The floor’s safe — the rest, maybe not."',
	2: '"Small, but that box gives it an edge."',
	3: '"Whirlwinds, slashes, and flying boxes — brace yourself."'
}

@export var ControlHintTitles: Dictionary[int, String] = {
	0: "Movement & Camera",
	1: "Jump & Dash",
	2: "Throw & Slash",
	3: "Boss Fight"
}

@export var ControlHints: Dictionary[int, String] = {
	0: "Use (TODO_MOVE WASD) to move, and (TODO_CAMERA_KEYS Q/E or TODO_CAMERA_MOUSE) to look around.",
	1: "Jump with (TODO_JUMP SPACE). Hold to jump higher.\nDash with (TODO_DASH SHIFT) to clear gaps or dodge.\nThe current state of all abilities is shown in the bottom-right corner (Stab, Throw, Dash, Jump).",
	2: "You can’t reach a spinning dummy up close — throw small objects, like rocks.\nAim with (TODO_AIM RMB), throw with (TODO_STAB LMB).\nBreak the box with a precise throw.\nFinish the dummy with a stab (TODO_STAB LMB).",
	3: "The boss combines everything you’ve learned.\nStop its whirlwind by hitting the box.\nWatch out for its box barrage and great slash."
}
