extends SequenceAnimationController
class_name BigDummyAnimController

@export var AnimSeqPrefixes: Dictionary[SEQ_ANIM, String] = {}

func idle():
	state_machine.travel("Idle")

#brute force play start seq anim
func barrage_play_start():
	state_machine.start("Barrage_Start")

func barrage_start(antic_dur: float = 0, end_time: float = -1):
	pass
	state_machine.travel("Barrage_Antic")
	if antic_dur >= 0:
		seq_anim_start(AnimSeqPrefixes.get(SEQ_ANIM.BARRAGE), antic_dur, end_time)
	
func barrage_end_antic():
	self.antic_end_subroutine()
	
func barrage_end():
	pass
	#state_machine.travel("Barrage_End")
	
#brute force play start seq anim
func great_slash_play_start():
	state_machine.start("Great_Slash_Start")
	
func great_slash_start(antic_dur: float = 0, end_time: float = -1):	
	state_machine.travel("Great_Slash_Antic")
	if antic_dur >= 0:
		seq_anim_start(AnimSeqPrefixes.get(SEQ_ANIM.SLASH), antic_dur, end_time, "great_slash_end")
	
func great_slash_end_antic():
	self.antic_end_subroutine()
	
func great_slash_end():
	state_machine.travel("Great_Slash_End")
	
func whirlwind_start(antic_dur: float = 0, end_time: float = -1):
	state_machine.travel("Whirlwind_Antic")
	if antic_dur >= 0:
		seq_anim_start(AnimSeqPrefixes.get(SEQ_ANIM.WHIRLWIND), antic_dur, end_time, "whirlwind_end")
	
func whirlwind_end_antic():
	self.antic_end_subroutine()
	pass
	
func whirlwind_end():
	state_machine.travel("Whirlwind_End")
	
enum SEQ_ANIM {
	BARRAGE,
	SLASH,
	WHIRLWIND,
}

func get_seq_anim_start_name(seq_type: SEQ_ANIM) -> String:
	return AnimSeqPrefixes.get(seq_type) + "-start"

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == get_seq_anim_start_name(SEQ_ANIM.BARRAGE):
		barrage_end()
	elif anim_name == get_seq_anim_start_name(SEQ_ANIM.SLASH):
		great_slash_end()
	elif anim_name == get_seq_anim_start_name(SEQ_ANIM.WHIRLWIND):
		whirlwind_end()
