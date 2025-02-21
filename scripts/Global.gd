extends Node

var indicator = preload("res://scenes/indicator_target.tscn")
var target_indicator = indicator.instantiate()
var player

func show_indicator(player):
	self.player = player
	player.add_child(target_indicator)
	
func hide_indicator():
	player.remove_child(target_indicator)
