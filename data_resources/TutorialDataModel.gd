extends Resource
class_name TutorialDataModel

@export var TutorialFirstPhases: int = 0
@export var TutorialLastPhases: int = 3
@export var TutorialPhases: int = 0

# Pairs of tutorial symbols to actions 
@export var TutorialActions: Dictionary[StringName, StringName] = {
	"TUTORIAL_MOVE_UP": "move_forward",
	"TUTORIAL_MOVE_DOWN": "move_back",
	"TUTORIAL_MOVE_LEFT": "strafe_left",
	"TUTORIAL_MOVE_RIGHT": "strafe_right",
	"TUTORIAL_CAMERA_UP": "camera_up",
	"TUTORIAL_CAMERA_DOWN": "camera_down",
	"TUTORIAL_CAMERA_LEFT": "camera_left",
	"TUTORIAL_CAMERA_RIGHT": "camera_right",
	"TUTORIAL_JUMP": "jump",
	"TUTORIAL_DASH": "dash",
	"TUTORIAL_AIM": "aim",
	"TUTORIAL_STAB": "fight",
	"TUTORIAL_PAUSE": "pause",
	"TUTORIAL_DEBUG": "debug",
}

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
	0: "Use TUTORIAL_MOVE_UP TUTORIAL_MOVE_DOWN TUTORIAL_MOVE_LEFT TUTORIAL_MOVE_RIGHT to move, and TUTORIAL_CAMERA_UP TUTORIAL_CAMERA_DOWN TUTORIAL_CAMERA_LEFT TUTORIAL_CAMERA_RIGHT or Mouse to look around.",
	1: "Jump with TUTORIAL_JUMP. Hold to jump higher.\nDash with TUTORIAL_DASH to clear gaps or dodge.\nThe current state of all abilities is shown in the bottom-right corner (Stab, Throw, Dash, Jump).",
	2: "You can’t reach a spinning dummy up close — throw small objects, like pebbles.\nAim with TUTORIAL_AIM, shoot with TUTORIAL_STAB.\nPick up pebbles and shoot the box to break it.\nAfter breaking the box, the dummy will be stunned — use that chance to finish it with a stab TUTORIAL_STAB.",
	3: "The boss combines everything you’ve learned.\nStop its whirlwind by shooting the box.\nWatch out for its box barrage and great slash."
}
