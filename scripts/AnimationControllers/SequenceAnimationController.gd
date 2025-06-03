extends AnimationController
class_name SequenceAnimationController

func get_anim_seq_start_len(anim_prefix: String) -> float:	
	var antic_name: String = anim_prefix + "-antic"
	var start_name: String = anim_prefix + "-start"
	var antic_len: float = get_anim_length(antic_name)
	var start_len: float = get_anim_length(start_name)
	if antic_len < 0 or start_len < 0:
		if DebugLogs: Global.LogError("Wrong animation data for " + anim_prefix + " anim sequence")
		return -1
	Global.LogInfo(anim_prefix + "len: " + str(antic_len) + " + " + str(start_len))
	return antic_len + start_len

func get_anim_seq_antic_len(anim_prefix: String) -> float:
	var anim_name: String = anim_prefix + "-antic"
	var anim_len: float = get_anim_length(anim_name)
	return anim_len

func get_anim_seq_end_len(anim_prefix: String) -> float:
	var anim_name: String = anim_prefix + "-end"
	var anim_len: float = get_anim_length(anim_name)
	return anim_len

func seq_anim_start(anim_prefix: String, antic_dur: float = 0, end_time: float = -1, end_func_name: String = "") -> void:
	var anim_antic_len = get_anim_seq_antic_len(anim_prefix)
	#if antic_dur < anim_antic_len: Global.LogInfo("swipe_start(): antic_dur param " + str(antic_dur) + " lower than base dur: " + str(anim_antic_len) + " . using base")
	var max_antic = maxf(anim_antic_len, antic_dur)
	antic_set_dur_subroutine(max_antic)
	if end_time != -1:
		var start_len = get_anim_seq_start_len(anim_prefix)
		if start_len > 0:
			delayed_call(start_len + end_time + max_antic, Callable(self, end_func_name))

func antic_end_subroutine():
	set_sm_cond("anticEnd", true)
	delayed_call(0.1, Callable(self, "set_sm_cond").bind("anticEnd", false))

func antic_set_dur_subroutine(duration: float):
	delayed_call(duration, Callable(self, "set_sm_cond").bind("anticEnd", true))
	delayed_call(duration + 0.1, Callable(self, "set_sm_cond").bind("anticEnd", false))
