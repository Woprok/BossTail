extends AnimationController
class_name PlayerAnimationController

func idle():
	state_machine.travel("Idle")
	
func run():
	state_machine.travel("Run")
	
func dash_start():
	state_machine.travel("Dash_start")
	
func dash_end():
	state_machine.travel("Dash_end")

func falling():
	state_machine.travel("Falling")

func jump_start():
	state_machine.travel("Jump_start")
	
func jump_descending():
	state_machine.travel("Jump_looping")
	
func jump_land():
	state_machine.travel("Jump_end")
	
func hit_flinch():
	state_machine.start("Hit_flinch")
	
func death():
	state_machine.start("Death")
	
func attack():
	var current_node = state_machine.get_current_node()
	if current_node == "Lunge_right":
		lunge_l()
	else:
		lunge_r()

func attack_settle():
	var current_node = state_machine.get_current_node()
	if current_node == "Lunge_right":
		lunge_settle_r()
	elif current_node == "Lunge_left":
		lunge_settle_l()
	else:
		idle()
		
func lunge_r():
	state_machine.travel("Lunge_right")
	
func lunge_l():
	state_machine.travel("Lunge_left")

func lunge_settle_l():
	state_machine.travel("Lunge_left_settle")
	
func lunge_settle_r():
	state_machine.travel("Lunge_right_settle")
