extends CharacterBody3D

var speed:int = 2
var gravity:int = -10
var HEIGHT_OF_ARC:float = 3

var time_of_extend = 0
var time_bubble = 0
var time_swipe = 0
var EXTEND_TIME = 5
var SAME_PLATFORM_TIME = 2
var DIFF_PLATFORM_TIME = 10
var BUBBLE_TIME = 5
var TONGUE_TIME = 10

var doing = false
var swipe = false
var jump = false
var tongue = false
var extended = false
var path:Array[Node]
var stage = 1
var subphase = 0
var platform: Node

@onready var player = get_parent().get_node("Player")
@onready var flies = get_parent().get_node("flies")
@onready var health = get_parent().get_node("Player/health/ui/health_boss")
var Bubble = preload("res://scenes/Bubble.tscn")

func _ready():
	randomize()
	var i = randi()%5
	_on_ground_entered(get_parent().get_node("stonePlatforms").get_child(i))
	position = platform.position
	position.y = 1.653
	
func _physics_process(delta):
	velocity.y += speed*gravity*delta
	var collision = move_and_collide(speed*velocity*delta)
	if collision and jump:
		jump = false
		$AnimationPlayer.play("GAME_02-jump-end")
	if path != [] and path[0]==platform:
			path = []
	if path!=[] and not jump:
		jump_direction(path[0].global_position)
		path.pop_front()
	if doing:
		return
	if stage == 1:
		if subphase == 0:
			time_bubble += delta
			time_swipe+=delta
			if health.health <= 25 and not doing and platform==player.platform:
				pass
			if health.health <= 25 and not doing and platform!=player.platform:
				plan_path(player.platform)
				if path.size()<=3:
					doing = true
				else:
					path = []
			if health.health <= 50 and not doing:
				if platform == player.platform and time_swipe>SAME_PLATFORM_TIME:
					randomize()
					SAME_PLATFORM_TIME = randi()%2+2
					swipe = true
					doing = true
					$AnimationPlayer.play("GAME_03-tongue_grab-start")
					time_swipe = 0
				if platform!=player.platform and platform.neighbors.has(player.platform) and time_swipe>DIFF_PLATFORM_TIME:
					swipe = true
					doing = true
					$AnimationPlayer.play("GAME_03-tongue_grab-start")
					time_swipe = 0
			if health.health!=100 and time_bubble>BUBBLE_TIME and platform != player.platform and not doing:
				doing = true
				bubble_spit()
		
		else:
			#swimming a utoky z vody
			pass
		if not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("GAME_01-idle")
	#	time_of_extend += delta
	#	if time_of_extend >= EXTEND_TIME and extended:
	#		$AnimationPlayer.play("GAME_03-tongue_grab-end")
	#	if path==[]:
	#		for fly in flies.get_children():
	#			if fly.groupSize>=3:
	#				if platform == fly.platform:
	#					if position.distance_to(fly.position)<6:
	#						look_at(Vector3(fly.position.x,position.y,fly.position.z))
	#						extend()
	#						break
	#					continue
	#				plan_path(fly.platform)
	#				break

func bubble_spit():
	var bubble = Bubble.instantiate()
	get_parent().add_child(bubble)
	bubble.position = position-transform.basis.z
	bubble.position.y+=0.2
	look_at(Vector3(player.position.x,position.y, player.position.z))
	bubble.shoot(player.position)
	time_bubble = 0
	doing = false


func tongue_swipe():
	var tween = get_tree().create_tween()
	tween.tween_property(self,"rotation",self.rotation+Vector3(0,6.2,0),0.5)
	tween.tween_callback(after_swipe)


func after_swipe():
	$AnimationPlayer.play("GAME_03-tongue_grab-end")
	doing = false
	time_swipe = 0

func jump_direction(target_position):
	look_at(Vector3(target_position.x,position.y,target_position.z))	
	var height = target_position.y - global_position.y + HEIGHT_OF_ARC
	height = abs(height)
	var displacement_y = target_position.y-position.y
	var displacemnt_xz = Vector3(target_position.x-position.x,0,target_position.z-position.z)
	var velocity_y = Vector3.UP * sqrt(-2*gravity*height)
	var velocity_xz = displacemnt_xz/(sqrt(-2*height/gravity)+sqrt(2*(displacement_y-height)/gravity))
	velocity = velocity_y+velocity_xz
	jump = true
	$AnimationPlayer.play("GAME_02-jump-start")

#func extend():
#	if extended:
#		return
#	$AnimationPlayer.play("GAME_03-tongue_grab-start")
#	time_of_extend = 0
#	return
	
func plan_path(target):
	if platform == target:
		return	
	var next = platform
	while target != next:
		var min = INF
		var o = null
		for n in next.neighbors:
			var dist = n.global_position.distance_to(target.global_position)
			if dist<min:
				min = dist
				o = n
		path.append(o)
		next = o
		
func hit(area):
	if health.health == 100:
		time_bubble = 0
	if area.is_in_group("hp1"):
		health.decHealth(1)
	if area.is_in_group("hp5"):
		health.decHealth(5)
	if area.is_in_group("hp10"):
		health.decHealth(10)
	if health.health<=0:
		#death
		pass

func _on_ground_entered(area):
	if area.is_in_group("stone_platform") or area.is_in_group("lily_platform"):
		if area.is_in_group("stone_platform") and area!=platform:
			if area.get_node("boulders/boulder1").is_visible()==false or area.get_node("boulders/boulder1").position.y<-3:
				area.get_node("boulders/boulder1").position = area.boulder1Position
				area.get_node("boulders/boulder1").show()
			if area.get_node("boulders/boulder2").is_visible()==false or area.get_node("boulders/boulder2").position.y<-3:
				area.get_node("boulders/boulder2").position = area.boulder2Position
				area.get_node("boulders/boulder2").show()
		platform = area


func _on_tongue_body_entered(body):
	if body.is_in_group("player"):
		if swipe:
			body.hit(body.get_node("CollisionShape3D"))
			body.launch(transform.basis.z)
	if body.is_in_group("fly"):
		body.queue_free()


func _on_animation_finished(anim_name):
	if anim_name=="GAME_03-tongue_grab-end":
		extended = false
		$tongue/CollisionShape3D.disabled = true
		$tongueShape.disabled = true		
	if anim_name == "GAME_03-tongue_grab-start":
		extended = true
		$tongue/CollisionShape3D.disabled = false
		$tongueShape.disabled = false
		if swipe:
			tongue_swipe()
