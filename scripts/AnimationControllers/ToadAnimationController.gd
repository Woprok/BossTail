extends AnimationController
class_name ToadAnimationController

# Simple animation controller that handles the animation tree state machine
# so that other scripts dont have to play animations by name and can just
# play them on demand and correctly advance through the staged attack animation sequences

@export var AnimSeqPrefixes: Dictionary[SEQ_ANIM, String] = {}
@export var TongueNodes: Array[MeshInstance3D] = []

var OnAttackStarted: Signal

func _ready() -> void:
	hide_tongue()
	pass
	
func idle():
	state_machine.travel("Idle")
	
func swim_idle():
	state_machine.travel("Swim_Idle")

func swim_start_swimming():
	state_machine.travel("Swim_Swimming")

func swim_stop_swimming():
	state_machine.travel("Swim_Idle")

func swim_bubble_atk_start(antic_dur: float = 0, end_time: float = -1):
	state_machine.travel("Swim_BubbleAtk_Antic")
	if antic_dur != 0:
		var anim_antic_len = get_anim_length(AnimSeqPrefixes.get(SEQ_ANIM.BUBBLE) + "_antic")
		#if antic_dur < anim_antic_len: Global.LogInfo("swim_bubble_atk(): antic_dur param " + str(antic_dur) + " lower than base dur: " + str(anim_antic_len) + " . using base")
		var max_antic = maxf(anim_antic_len, antic_dur)
		antic_set_dur_subroutine(max_antic)
		if end_time != -1:
			var start_len = get_anim_seq_start_len(SEQ_ANIM.BUBBLE)
			if start_len > 0:
				delayed_call(start_len + end_time + max_antic, Callable(self, "swim_bubble_atk_end"))
	
func swim_bubble_atk_end_antic():
	antic_end_subroutine()
	
func swim_bubble_atk_end():
	pass
	
func hop_L_start():
	state_machine.travel("Hop_L")
func hop_R_start():
	state_machine.travel("Hop_R")

func seq_anim_start(anim_type: SEQ_ANIM, antic_dur: float = 0, end_time: float = -1, end_func_name: String = "") -> void:
	var anim_antic_len = get_anim_seq_antic_len(anim_type)
	#if antic_dur < anim_antic_len: Global.LogInfo("swipe_start(): antic_dur param " + str(antic_dur) + " lower than base dur: " + str(anim_antic_len) + " . using base")
	var max_antic = maxf(anim_antic_len, antic_dur)
	antic_set_dur_subroutine(max_antic)
	if end_time != -1:
		var start_len = get_anim_seq_start_len(anim_type)
		if start_len > 0:
			delayed_call(start_len + end_time + max_antic, Callable(self, end_func_name))

func swipe_start(antic_dur: float = 0, end_time: float = -1):
	show_tongue()
	state_machine.travel("Swipe_Antic")
	if antic_dur >= 0:
		seq_anim_start(SEQ_ANIM.TONGUE_SWIPE, antic_dur, end_time, "swipe_end")
	
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
	if antic_dur >= 0:
		seq_anim_start(SEQ_ANIM.TONGUE_GRAB, antic_dur, end_time, "tongue_grab_end")
	
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
	if antic_dur >= 0:
		seq_anim_start(SEQ_ANIM.SPIT, antic_dur, end_time, "spit_end")
			
func spit_antic_end():
	antic_end_subroutine()
	
func spit_end():
	state_machine.travel("Spit_End")
	var end_len: float = get_anim_seq_end_len(SEQ_ANIM.SPIT)
	if end_len > 0:
		delayed_call(end_len, Callable(self, "hide_tongue"))
	
func ground_slam_start(antic_dur: float = 0, end_time: float = -1):
	state_machine.travel("GroundSlam_Antic")
	if antic_dur >= 0:
		seq_anim_start(SEQ_ANIM.TONGUE_GRAB, antic_dur, end_time, "ground_slam_end")
	
func ground_slam_antic_end():
	antic_end_subroutine()
	
func ground_slam_end():
	state_machine.travel("GroundSlam_End")
	
func jump_start():
	state_machine.travel("Jump_Start")
	
func jump_end():
	state_machine.travel("Jump_End")

func antic_end_subroutine():
	set_sm_cond("anticEnd", true)
	delayed_call(0.1, Callable(self, "set_sm_cond").bind("anticEnd", false))
	OnAttackStarted.emit()

func antic_set_dur_subroutine(duration: float):
	delayed_call(duration, Callable(self, "set_sm_cond").bind("anticEnd", true))
	delayed_call(duration, OnAttackStarted.emit)
	delayed_call(duration + 0.1, Callable(self, "set_sm_cond").bind("anticEnd", false))

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

func get_anim_seq_antic_len(anim_type: SEQ_ANIM) -> float:
	var anim_name: String = AnimSeqPrefixes.get(anim_type) + "-antic"
	var anim_len: float = get_anim_length(anim_name)
	return anim_len

func get_anim_seq_end_len(anim_type: SEQ_ANIM) -> float:
	var anim_name: String = AnimSeqPrefixes.get(anim_type) + "-end"
	var anim_len: float = get_anim_length(anim_name)
	return anim_len


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
