extends Node3D

var walls_down = false
@export var positions_for_crates:Array[Vector3]
@export var num_of_crates:Array[int]
var Crates = preload("res://scenes/Crates.tscn")
var time_crates = 0
var reset_position_part2 = Vector3(-25,1, 35)

func _process(delta):
	if not walls_down and $Player.position.distance_to($Enemy.position)<=115:
		$walls.show()
		$AnimationPlayer.play("walls",2)
		$Player.part=2
		walls_down=true
	time_crates += delta
	if time_crates>1:
		time_crates = 0
		var crates = Crates.instantiate()
		var random_pos = -1
		while random_pos==-1:
			random_pos = randi()%positions_for_crates.size()
			if num_of_crates[random_pos]>=3:
				random_pos = -1
				continue
			$obstacles/crates.add_child(crates)
			crates.pos_index = random_pos
			num_of_crates[random_pos] += 1
			crates.position = positions_for_crates[random_pos]

func respawn_player():
	if $Player.part == 2:
		$Player.respawn(reset_position_part2)

func _on_animation_finished(anim_name):
	if anim_name=="walls":
		$obstacles.show()
