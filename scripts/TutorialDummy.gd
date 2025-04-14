extends CharacterBody3D

var stopped = true
var doing = false
var WHIRLWIND_TIME_MAX = 9
var WHIRLWIND_TIME_MIN = 3
var WHIRLWIND_TIME = 0
var SLASH_TIME_MAX = 10
var SLASH_TIME_MIN = 2
var SLASH_TIME = 0
var BARRAGE_TIME_MAX = 10 
var BARRAGE_TIME_MIN = 5
var BARRAGE_TIME = 0
var whirlwind_time = 0
var barrage_time = 0
var slash_time = 0

var box_size_div = 2
var BOX = preload("res://scenes/Crates.tscn")

func _physics_process(delta):
	if not stopped:
		doing = true
		rotate_y(delta*20)
		whirlwind_time += delta
	if whirlwind_time>=WHIRLWIND_TIME:
		WHIRLWIND_TIME = randi()%(WHIRLWIND_TIME_MAX-WHIRLWIND_TIME_MIN)+WHIRLWIND_TIME_MIN
		whirlwind_time = 0
		stopped = true
		return
	if doing:
		return
	slash_time+=delta
	if slash_time>=SLASH_TIME:
		slash_time = 0
		SLASH_TIME = randi()%(SLASH_TIME_MAX-SLASH_TIME_MIN)+SLASH_TIME_MIN
		slash()
		doing = true
		return
	barrage_time += delta
	if barrage_time>=BARRAGE_TIME:
		barrage_time = 0
		BARRAGE_TIME = randi()%(BARRAGE_TIME_MAX-BARRAGE_TIME_MIN)+BARRAGE_TIME_MIN
		throw()

func slash():
	$AnimationPlayer.play("slash",-1,3)

func throw():
	var box = BOX.instantiate()
	box.thrown = true
	box.scale /= box_size_div
	box.get_node("hit/CollisionShape3D").disabled = false
	get_parent().add_child(box)
	box.position = position+(get_parent().get_node("Player").position - position).normalized()
	box.velocity = (get_parent().get_node("Player").position - position).normalized()*10
	#podle poctu tolik krabic

func _on_body_entered(body):
	if not stopped and body.is_in_group("player") and body.pushed == false:
		body.velocity=(body.global_position-global_position).normalized()*15
		body.velocity.y = 0
		body.pushed = true


func _on_slash_entered(body):
	if body.is_in_group("player"):
		print("slash")


func _on_animation_finished(anim_name):
	if anim_name == "slash":
		doing = false
