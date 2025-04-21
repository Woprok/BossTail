extends AnimationTree
class_name ToadAnimationController

# Simple animation controller that handles the animation tree state machine
# so that other scripts dont have to play animations by name and can just
# play them on demand and correctly advance through the staged attack animation sequences

var state_machine: AnimationNodeStateMachinePlayback = self.get("parameters/playback")

func _ready() -> void:
	#state_machine.travel("Spit_Antic")
	#self.set("parameters/conditions/anticEnd", true)
	pass
func idle():
	state_machine.start("Idle")
	
func swim_idle():
	state_machine.travel("Swim_Idle")
	
func swim_start_swimming():
	state_machine.travel("Swim_Swimming")

func swim_stop_swimming():
	state_machine.travel("Swim_Idle")

func swim_bubble_atk_start(set_antic_dur: bool = false, antic_dur: float = 0):
	state_machine.travel("Swim_BubbleAtk_Antic")
	if set_antic_dur:
		antic_set_dur_subroutine(antic_dur)
	
func swim_bubble_atk_end_antic():
	antic_end_subroutine()
	
func swim_bubble_atk_end():
	pass
	
func hop_L_start():
	state_machine.travel("Hop_L")
func hop_R_start():
	state_machine.travel("Hop_R")
	
func swipe_start(set_antic_dur: bool = false, antic_dur: float = 0):
	state_machine.travel("Swipe_Antic")
	if set_antic_dur:
		antic_set_dur_subroutine(antic_dur)
	
func swipe_end_antic():
	antic_end_subroutine()
	
func swipe_end():
	state_machine.travel("Swipe_End")
	
func tongue_grab_start(set_antic_dur: bool = false, antic_dur: float = 0):
	state_machine.travel("TongueGrab_Antic")
	if set_antic_dur:
		antic_set_dur_subroutine(antic_dur)
	
func tongue_grab_antic_end():
	antic_end_subroutine()
	
func tongue_grab_end():
	state_machine.travel("TongueGrab_End")
	
func spit_start(set_antic_dur: bool = false, antic_dur: float = 0):
	state_machine.travel("Spit_Antic")
	if set_antic_dur:
		antic_set_dur_subroutine(antic_dur)
	
func spit_antic_end():
	antic_end_subroutine()
	
func spit_end():
	state_machine.travel("Spit_End")
	
func ground_slam_start(set_antic_dur: bool = false, antic_dur: float = 0):
	state_machine.travel("GroundSlam_Antic")
	if set_antic_dur:
		antic_set_dur_subroutine(antic_dur)
	
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
	callback.call()
	timer = null # null the ref -> garbage collector should destroy it now, maybe this is unnecessary idk
	
