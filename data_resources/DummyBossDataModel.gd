extends BossDataModel
class_name DummyBossDataModel

@export var TutorialPhases: int = 0

@export var Objectives: Dictionary[int, String] = {
	0: "Get to the Dummy",
	1: "Traverse the arena",
	2: "Pass through small dummy",
	3: "Beat the dummy",
}

@export var Names: Dictionary[int, String] = {
	0: "Peaceful Dummy",
	1: "Sharing Dummy",
	2: "Small Dummy",
	3: "Angry Dummy",
}

@export var ControlHelps: Dictionary[int, String] = {
	0: "You can move and control camera",
	1: "Jump over obstacles with SPACE_KEY. Dash to gain forward movement boost with DASH_KEY.",
	2: "You can throw small objects, such as rock with AIM_KEY + SLASH_KEY.",
	3: "Beware, dummy can hit back. Hit it harder with SLASH_KEY."
}

#During the boss fights, player can see controls in left-center of the screens. (Small unobtrusive way.) 
# Additionally, important controls such as attacks and other are shown next to their indicators in bottom right panel. Finally, the boss health bar has objective for current part written under it. Guiding player through this fight.

#Objective: Move toward the Dummy
#Objective: Reach Dummy, Use Jump
#Objective: Reach Dummy, Avoid being hit, Pick & Throw

#Control List:
#WASD, SPACE, SHIFT, LMB, RMB
