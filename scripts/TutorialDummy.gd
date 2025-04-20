extends CharacterBody3D

var stopped = true
var active = false
var doing = false
var BOXES_IN_VOLLEY=4

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
@export var boss_data: BossDataModel = preload("res://data_resources/BossDataModelInstance.tres")
var BOX = preload("res://scenes/Crates.tscn")

func _ready() -> void:
	boss_data.boss_restart()
	WHIRLWIND_TIME = WHIRLWIND_TIME_MAX
	SLASH_TIME = SLASH_TIME_MAX
	BARRAGE_TIME = BARRAGE_TIME_MAX

func _physics_process(delta):
	if not active:
		return
	#look at player
	if not stopped:
		doing = true
		rotate_y(delta*20)
		whirlwind_time += delta
	if whirlwind_time>=WHIRLWIND_TIME:
		whirlwind_time = 0
		stopped = true
		return
	if doing:
		return
	slash_time+=delta
	if slash_time>=SLASH_TIME:
		slash_time = 0
		slash()
		doing = true
		return
	barrage_time += delta
	if barrage_time>=BARRAGE_TIME:
		barrage_time = 0
		throw()

func slash():
	$AnimationPlayer.play("slash",-1,3)

func throw():
	var init_dir = (get_parent().get_node("Player").position - position).normalized()
	for i in range(BOXES_IN_VOLLEY):
		var dir = init_dir.rotated(Vector3(0,1,0),(randf()*2-1)*PI/4)
		var box = BOX.instantiate()
		box.thrown = true
		box.scale /= box_size_div
		box.get_node("hit/CollisionShape3D").disabled = false
		get_parent().add_child(box)
		box.position = position+dir.normalized()*6
		box.position.y=-4.8
		box.velocity = dir.normalized()*12
		box.velocity.y = 0
	#podle poctu tolik krabic

func _on_body_entered(body):
	if not stopped and body.is_in_group("player") and body.pushed == false:
		body.velocity=(body.global_position-global_position).normalized()*15
		body.velocity.y = 0
		body.pushed = true


func _on_slash_entered(body):
	if body.is_in_group("player"):
		body.hit(10)


func _on_animation_finished(anim_name):
	if anim_name == "slash":
		doing = false
