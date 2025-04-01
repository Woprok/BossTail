extends Area3D
var player_in_area:bool = false
var time = 0
var speed = 5
@onready var player = get_parent().get_node("Player")
@onready var bigLily = get_parent().get_node("lilyPlatforms/largeLily")
var active = 8
var target_position
var dispersed = false
var dispersed_time = 0
var TIME_OF_DISPERSED = 30
var split_off_time = 0
var TIME_SPLIT_OFF = 4

func _process(delta):
	if active<=0 and get_children().size()==1:
		queue_free()
	if active<=0:
		$CollisionShape3D.disabled = true
	else:
		$CollisionShape3D.disabled = false
	if player_in_area:
		time += delta
		if time>1:
			time=0
			player.hit(self)
	if dispersed:
		$CollisionShape3D.disabled = true
		dispersed_time += delta
		if dispersed_time>=TIME_OF_DISPERSED:
			dispersed = false
		else:
			return
	else:
		$CollisionShape3D.disabled = false
		split_off_time+=delta
		if split_off_time>TIME_SPLIT_OFF:
			split_off()
	if player.platform != null and (player.platform.is_in_group("shard") or player.platform.is_in_group("big_lily")):
		chase_position(delta,player.position)
	else:
		if target_position!= null and target_position.distance_to(position)>=0.2:
			chase_position(delta, target_position)
		else:
			target_position = fly_around(bigLily.position,20)
			chase_position(delta, target_position)

func chase_position(delta, target_position):
	var dir = target_position-position
	dir = dir.normalized()
	position += dir*speed*delta
	

func fly_around(center, radius):
	var angle = randf() * TAU
	var distance = sqrt(randf()) * radius
	var x = center.x + distance * cos(angle)
	var z = center.z + distance * sin(angle)
	return Vector3(x,center.y+3, z)
	

func split_off():
	split_off_time = 0
	var size = 0
	for node in get_children():
		if node.is_in_group("fly") and node.split_off==false:
			size += 1
	if size!=0:
		var fly_num = randi() % size
		var i = -1
		for node in get_children():
			if node.is_in_group("fly") and node.split_off==false:
				i+=1
				if i == fly_num:
					node.split_off = true
					active-=1
					return


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = true
	if body.is_in_group("pebble"):
		dispersed = true
		dispersed_time = 0
		body.respawn()
	if body.is_in_group("frog_bubble"):
		body.queue_free()


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		time=0
