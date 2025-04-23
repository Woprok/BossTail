extends AnimationTree
class_name ToadAnimationController

# Simple animation controller that handles the animation tree state machine
# so that other scripts dont have to play animations by name and can just
# play them on demand and correctly advance through the staged attack animation sequences

@export var DebugLogs: bool = true
@export var AnimSeqPrefixes: Dictionary[SEQ_ANIM, String] = {}
@export var TongueNodes: Array[MeshInstance3D] = []

var state_machine: AnimationNodeStateMachinePlayback = self.get("parameters/playback")

var prevent_delayed_call_exec: bool = false

func _ready() -> void:
	hide_tongue()
	pass
	
func idle():
	state_machine.start("Idle")
	
func swim_idle():
	state_machine.travel("Swim_Idle")
	
func swim_start_swimming():
	state_machine.travel("Swim_Swimming")

func swim_stop_swimming():
	state_machine.travel("Swim_Idle")

func swim_bubble_atk_start(antic_dur: float = 0, end_time: float = -1):
	state_machine.travel("Swim_BubbleAtk_Antic")
	if antic_dur != 0:
		antic_set_dur_subroutine(antic_dur)
		if end_time != -1:
			var start_len = get_anim_seq_start_len(SEQ_ANIM.BUBBLE)
			if start_len > 0:
				delayed_call(start_len + end_time + antic_dur, Callable(self, "swim_bubble_atk_end"))
	
func swim_bubble_atk_end_antic():
	antic_end_subroutine()
	
func swim_bubble_atk_end():
	pass
	
func hop_L_start():
	state_machine.travel("Hop_L")
func hop_R_start():
	state_machine.travel("Hop_R")
	
func swipe_start(antic_dur: float = 0, end_time: float = -1):
	show_tongue()
	state_machine.travel("Swipe_Antic")
	if antic_dur != 0:
		antic_set_dur_subroutine(antic_dur)
		if end_time != -1:
			var start_len = get_anim_seq_start_len(SEQ_ANIM.TONGUE_SWIPE)
			if start_len > 0:
				delayed_call(start_len + end_time + antic_dur, Callable(self, "swipe_end"))
	
func swipe_end_antic():
	antic_end_subroutine()
	
func swipe_end():
	state_machine.travel("Swipe_End")
	var end_len: float = get_anim_seq_end_len(SEQ_ANIM.TONGUE_SWIPE)
	if end_len > 0:
		delayed_call(end_len, Callable(self, "hide_tongue"))
	
func tongue_grab_start(antic_dur: float = 0, end_time: float = -1):
	show_tongue()
	state_machine.travel("TongueGrab_Antic")
	if antic_dur != 0:
		antic_set_dur_subroutine(antic_dur)
		if end_time != -1:
			var start_len = get_anim_seq_start_len(SEQ_ANIM.TONGUE_GRAB)
			if start_len > 0:
				delayed_call(start_len + end_time + antic_dur, Callable(self, "tongue_grab_end"))
	
func tongue_grab_antic_end():
	antic_end_subroutine()
	
func tongue_grab_end():
	state_machine.travel("TongueGrab_End")
	
	var end_len: float = get_anim_seq_end_len(SEQ_ANIM.TONGUE_GRAB)
	if end_len > 0:
		delayed_call(end_len, Callable(self, "hide_tongue"))
	
func spit_start(antic_dur: float = 0, end_time: float = -1):
	show_tongue()
	state_machine.travel("Spit_Antic")
	if antic_dur != 0:
		antic_set_dur_subroutine(antic_dur)
		if end_time != -1:
			var start_len = get_anim_seq_start_len(SEQ_ANIM.SPIT)
			if start_len > 0:
				delayed_call(start_len + end_time + antic_dur, Callable(self, "spit_end"))
			
func spit_antic_end():
	antic_end_subroutine()
	
func spit_end():
	state_machine.travel("Spit_End")
	var end_len: float = get_anim_seq_end_len(SEQ_ANIM.SPIT)
	if end_len > 0:
		delayed_call(end_len, Callable(self, "hide_tongue"))
	
func ground_slam_start(antic_dur: float = 0, end_time: float = -1):
	state_machine.travel("GroundSlam_Antic")
	if antic_dur != 0:
		antic_set_dur_subroutine(antic_dur)
		if end_time != -1:
			var start_len = get_anim_seq_start_len(SEQ_ANIM.GROUND_SLAM)
			if start_len > 0:
				delayed_call(start_len + end_time + antic_dur, Callable(self, "ground_slam_end"))
	
func ground_slam_antic_end():
	antic_end_subroutine()
	
func ground_slam_end():
	state_machine.travel("GroundSlam_End")
	
func jump_start():
	state_machine.travel("Jump_Start")
func jump_end():
	state_machine.travel("Jump_End")

func set_sm_cond(cond_name: String, cond_val: bool):
	self.set("parameters/conditions/" + cond_name, cond_val)

func antic_end_subroutine():
	set_sm_cond("anticEnd", true)
	delayed_call(0.1, Callable(self, "set_sm_cond").bind("anticEnd", false))

func antic_set_dur_subroutine(duration: float):
	delayed_call(duration, Callable(self, "set_sm_cond").bind("anticEnd", true))
	delayed_call(duration + 0.1, Callable(self, "set_sm_cond").bind("anticEnd", false))

func delayed_call(delay: float, call: Callable) -> void:
	var newTimer: SceneTreeTimer = get_tree().create_timer(delay)
	var callback: Callable = Callable(self, "delayed_call_cleanup").bind(newTimer, call)
	newTimer.timeout.connect(callback)
	
func delayed_call_cleanup(timer: SceneTreeTimer, callback: Callable) -> void:
	if not prevent_delayed_call_exec:
		callback.call()
	timer = null # null the ref -> garbage collector should destroy it now, maybe this is unnecessary idk

func get_anim_seq_start_len(anim_type : SEQ_ANIM) -> float:
	var anim_prefix: String = AnimSeqPrefixes.get(anim_type)
	var antic_name: String = anim_prefix + "-antic"
	var start_name: String = anim_prefix + "-start"
	var antic_len: float = get_anim_length(antic_name)
	var start_len: float = get_anim_length(start_name)
	if antic_len < 0 or start_len < 0:
		if DebugLogs: Global.LogError("Wrong animation data for " + str(anim_type) + " anim sequence")
		return -1
	Global.LogInfo(SEQ_ANIM.keys()[anim_type] + "len: " + str(antic_len) + " + " + str(start_len))
	return antic_len + start_len

func get_anim_seq_end_len(anim_type: SEQ_ANIM) -> float:
	var anim_name: String = AnimSeqPrefixes.get(anim_type) + "-end"
	var anim_len: float = get_anim_length(anim_name)
	return anim_len

func get_anim_length(name: String) -> float:
	var animation_player: AnimationPlayer = get_node(anim_player)
	if animation_player.has_animation(name):
		return animation_player.get_animation(name).length
	else:
		if DebugLogs: Global.LogError("Animation " + name + " not found")
		return -1

enum SEQ_ANIM {
	BUBBLE,
	SPIT,
	TONGUE_GRAB,
	TONGUE_SWIPE,
	GROUND_SLAM,
}

func hide_tongue():
	for node in TongueNodes:
		node.hide()

func show_tongue():
	for node in TongueNodes:
		node.show()
