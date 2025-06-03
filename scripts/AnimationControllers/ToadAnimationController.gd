extends SequenceAnimationController
class_name ToadAnimationController

# Simple animation controller that handles the animation tree state machine
# so that other scripts dont have to play animations by name and can just
# play them on demand and correctly advance through the staged attack animation sequences

@export var TongueNodes: Array[MeshInstance3D] = []

@export var AnimSeqPrefixes: Dictionary[SEQ_ANIM, String] = {}

func _ready() -> void:
	hide_tongue()
	pass
	
func idle():
	hide_tongue()
	state_machine.travel("Idle")
	
func swim_idle():
	hide_tongue()
	state_machine.travel("Swim_Idle")

func swim_start_swimming():
	hide_tongue()
	state_machine.travel("Swim_Swimming")

func swim_stop_swimming():
	hide_tongue()
	state_machine.travel("Swim_Idle")

func swim_bubble_atk_start(antic_dur: float = 0, end_time: float = -1):
	hide_tongue()
	state_machine.travel("Swim_BubbleAtk_Antic")
	if antic_dur != 0:
		var anim_antic_len = get_anim_length(AnimSeqPrefixes.get(SEQ_ANIM.BUBBLE) + "_antic")
		#if antic_dur < anim_antic_len: Global.LogInfo("swim_bubble_atk(): antic_dur param " + str(antic_dur) + " lower than base dur: " + str(anim_antic_len) + " . using base")
		var max_antic = maxf(anim_antic_len, antic_dur)
		antic_set_dur_subroutine(max_antic)
		if end_time != -1:
			var start_len = get_anim_seq_start_len(AnimSeqPrefixes.get(SEQ_ANIM.BUBBLE))
			if start_len > 0:
				delayed_call(start_len + end_time + max_antic, Callable(self, "swim_bubble_atk_end"))
	
func swim_bubble_atk_end_antic():
	antic_end_subroutine()
	
func swim_bubble_atk_end():
	pass
	
func hop_L_start():
	hide_tongue()
	state_machine.travel("Hop_L")
func hop_R_start():
	hide_tongue()
	state_machine.travel("Hop_R")

func swipe_start(antic_dur: float = 0, end_time: float = -1):
	show_tongue()
	state_machine.travel("Swipe_Antic")
	if antic_dur >= 0:
		seq_anim_start(AnimSeqPrefixes.get(SEQ_ANIM.TONGUE_SWIPE), antic_dur, end_time, "swipe_end")
	
func swipe_end_antic():
	antic_end_subroutine()
	
func swipe_end():
	state_machine.travel("Swipe_End")
	#var end_len: float = get_anim_seq_end_len(AnimSeqPrefixes.get(SEQ_ANIM.TONGUE_SWIPE))
	#if end_len > 0:
	#	delayed_call(end_len, Callable(self, "hide_tongue"))
	
func tongue_grab_start(antic_dur: float = 0, end_time: float = -1):
	show_tongue()
	state_machine.travel("TongueGrab_Antic")
	if antic_dur >= 0:
		seq_anim_start(AnimSeqPrefixes.get(SEQ_ANIM.TONGUE_GRAB), antic_dur, end_time, "tongue_grab_end")
	
func tongue_grab_antic_end():
	antic_end_subroutine()
	
func tongue_grab_end():
	state_machine.travel("TongueGrab_End")
	
	#var end_len: float = get_anim_seq_end_len(AnimSeqPrefixes.get(SEQ_ANIM.TONGUE_GRAB))
	#if end_len > 0:
	#	delayed_call(end_len, Callable(self, "hide_tongue"))
	
func spit_start(antic_dur: float = 0, end_time: float = -1):
	show_tongue()
	state_machine.travel("Spit_Antic")
	if antic_dur >= 0:
		seq_anim_start(AnimSeqPrefixes.get(SEQ_ANIM.SPIT), antic_dur, end_time, "spit_end")
			
func spit_antic_end():
	antic_end_subroutine()
	
func spit_end():
	state_machine.travel("Spit_End")
	#var end_len: float = get_anim_seq_end_len(AnimSeqPrefixes.get(SEQ_ANIM.TONGUE_GRAB))
	#if end_len > 0:
	#	delayed_call(end_len, Callable(self, "hide_tongue"))
	
func ground_slam_start(antic_dur: float = 0, end_time: float = -1):
	hide_tongue()
	state_machine.travel("GroundSlam_Antic")
	if antic_dur >= 0:
		seq_anim_start(AnimSeqPrefixes.get(SEQ_ANIM.GROUND_SLAM), antic_dur, end_time, "ground_slam_end")
	
func ground_slam_antic_end():
	antic_end_subroutine()
	
func ground_slam_end():
	state_machine.travel("GroundSlam_End")
	
func jump_start():
	hide_tongue()
	state_machine.travel("Jump_Start")
	
func jump_end():
	state_machine.travel("Jump_End")

func hide_tongue():
	for node in TongueNodes:
		node.hide()

func show_tongue():
	for node in TongueNodes:
		node.show()
		
		
enum SEQ_ANIM {
	BUBBLE,
	SPIT,
	TONGUE_GRAB,
	TONGUE_SWIPE,
	GROUND_SLAM,
}
