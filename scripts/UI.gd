extends Node2D

func change_jump_height(value):
	if value == 0:
		$jump_indicator.value = 0
	else:
		$jump_indicator.value += value
		
func change_melee_indicator(value):
	if value:
		$melee.self_modulate = Color(0,1,0)
	else:
		$melee.self_modulate = Color(1,0,0)	

func change_ranged_indicator(value):
	if value:
		$ranged.self_modulate = Color(0,1,0)
	else:
		$ranged.self_modulate = Color(1,0,0)		

func change_dash_indicator(value):
	if value:
		$dash.self_modulate = Color(0,1,0)
	else:
		$dash.self_modulate = Color(1,0,0)	
