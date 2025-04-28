extends Node3D

var walls_down = false
@export var positions_for_crates:Array[Vector3]
@export var num_of_crates:Array[int]
var Crates = preload("res://scenes/Crates.tscn")
var Boulder = preload("res://scenes/TutorialBoulder.tscn")
var Rock = preload("res://scenes/TutorialRock.tscn")

var boulders_variant = [[Vector3(-24,20,11.7), Vector3(-24,20,5.7),Vector3(-24,20,-0.3), Vector3(-24,20,-11.7)],[Vector3(-24,20,11.7), Vector3(-24,20,0.3),Vector3(-24,20,-5.7), Vector3(-24,20,-11.7)],
		[Vector3(-24,20,11.7), Vector3(-24,20,5.7),Vector3(-24,20,-5.7), Vector3(-24,20,-11.7)]]
var time_crates = 0
var time_boulder = 0
var TIME_CRATES = 1
var TIME_BOULDER = 1.7

func _process(delta):
	if not walls_down and $Player.position.distance_to($Enemy.position)<=115:
		$walls.show()
		$AnimationPlayer.play("walls",2)
		$Player.part=2
		GameEvents.tutorial_phase.emit(1)
		walls_down=true
	time_crates += delta
	time_boulder += delta
	if time_crates>TIME_CRATES:
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
	if time_boulder > TIME_BOULDER:
		time_boulder = 0
		var boulder1 = Boulder.instantiate()
		var boulder2 = Boulder.instantiate()
		var boulder3 = Boulder.instantiate()
		var boulder4 = Boulder.instantiate()
		var variant = randi()%3
		$obstacles/obliquePlatform/boulders.add_child(boulder1)
		$obstacles/obliquePlatform/boulders.add_child(boulder2)
		$obstacles/obliquePlatform/boulders.add_child(boulder3)
		$obstacles/obliquePlatform/boulders.add_child(boulder4)
		boulder1.position = boulders_variant[variant][0]
		boulder2.position = boulders_variant[variant][1]
		boulder3.position = boulders_variant[variant][2]
		boulder4.position = boulders_variant[variant][3]

func respawn_player():
	$Player.respawn()

func addRock(target_position:Vector3):
	var rock = Rock.instantiate()
	$obstacles/pebbles.add_child(rock)
	if $obstacles/pebbles.get_child_count()>10:
		var to_remove = $obstacles/pebbles.get_child(0)
		$obstacles/pebbles.remove_child(to_remove)
		to_remove.queue_free()
	rock.global_position = target_position

func _on_animation_finished(anim_name):
	if anim_name=="walls":
		$obstacles.show()
		$walls2.show()
		$MiniDummy.show()
		$arena/spikes.show()


func _on_last_part_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		$Player.part = 4
		GameEvents.tutorial_phase.emit(3)
		$Enemy.active = true
		$walls2.show()
		$AnimationPlayer.play("last_wall")
