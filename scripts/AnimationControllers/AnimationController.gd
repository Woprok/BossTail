extends AnimationTree
class_name AnimationController

@export var DebugLogs : bool = false
var prevent_delayed_call_exec: bool = false
var state_machine: AnimationNodeStateMachinePlayback = self.get("parameters/playback")

func get_anim_length(anim_name: String) -> float:
	var animation_player: AnimationPlayer = get_node(anim_player)
	if animation_player.has_animation(anim_name):
		return animation_player.get_animation(anim_name).length
	else:
		if DebugLogs: Global.LogError("Animation " + anim_name + " not found")
		return -1

func delayed_call(delay: float, delayed_callback: Callable) -> void:
	var newTimer: SceneTreeTimer = get_tree().create_timer(delay)
	var callback: Callable = Callable(self, "delayed_call_cleanup").bind(newTimer, delayed_callback)
	newTimer.timeout.connect(callback)
	
func delayed_call_cleanup(timer: SceneTreeTimer, callback: Callable) -> void:
	if not prevent_delayed_call_exec:
		callback.call()
	if timer:
		timer = null

func set_sm_cond(cond_name: String, cond_val: bool):
	self.set("parameters/conditions/" + cond_name, cond_val)
