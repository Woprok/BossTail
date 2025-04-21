extends CharacterBody3D

var stopped = true
var active = false
var doing = false
var last_cd_change = 0
var num_of_volley = 1
var actual_volley = 1
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
var VOLLEY_TIME = 1
var whirlwind_time = 0
var last_whirlwind = 0
var barrage_time = 0
var slash_time = 0
var volley_time = 0

var box_size_div = 2
@export var boss_data: BossDataModel = preload("res://data_resources/DummyBossDataModel.tres")
var BOX = preload("res://scenes/Crates.tscn")


func _ready() -> void:
	boss_data.boss_restart()
	GameEvents.boss_changed.emit(boss_data)
	
	WHIRLWIND_TIME = WHIRLWIND_TIME_MAX
	SLASH_TIME = SLASH_TIME_MAX
	BARRAGE_TIME = BARRAGE_TIME_MAX

func _physics_process(delta):
	if not active:
		return
	if not stopped:
		doing = true
		rotate_y(delta*20)
		whirlwind_time += delta
	if whirlwind_time>=WHIRLWIND_TIME:
		whirlwind_time = 0
		push()
		$box.use_collision=false
		stopped = true
		$AnimationPlayer.play("whirlwind_end")
		return
	if doing:
		if actual_volley<num_of_volley:
			if volley_time<VOLLEY_TIME:
				volley_time+=delta
			else:
				throw()
				volley_time = 0
		return
	look_at(Vector3(get_parent().get_node("Player").position.x,position.y,get_parent().get_node("Player").position.z))
	slash_time+=delta
	if slash_time>=SLASH_TIME:
		slash_time = 0
		barrage_time -= 1
		slash()
		doing = true
		return
	barrage_time += delta
	if barrage_time>=BARRAGE_TIME:
		barrage_time = 0
		slash_time -= 1
		actual_volley = 0
		throw()

func hit(hp):
	if stopped==false:
		return
	boss_data.boss_decrease_health(hp)
	last_cd_change += hp
	last_whirlwind += hp
	if last_cd_change>=25:
		SLASH_TIME = max(SLASH_TIME_MIN, SLASH_TIME-2.5)
		BARRAGE_TIME = max(BARRAGE_TIME_MIN, BARRAGE_TIME-2.5)
		WHIRLWIND_TIME = max(WHIRLWIND_TIME_MIN, WHIRLWIND_TIME-2.5)
		num_of_volley+=1
		last_cd_change = 0 
	if last_whirlwind>=10:
		last_whirlwind = 0
		whirlwind()

func slash():
	$AnimationPlayer.play("slash",-1,3)

func whirlwind():
	barrage_time = 0
	slash_time = 0 
	$AnimationPlayer.play("whirlwind_start",2)
	

func push():
	var player = get_parent().get_node("Player")
	player.velocity=(player.global_position-global_position).normalized()*25
	player.velocity.y = 0
	player.pushed = true

func throw():
	var init_dir = (get_parent().get_node("Player").position - position).normalized()
	actual_volley+=1
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
	if actual_volley<num_of_volley:
		doing = true
	else:
		doing = false

func _on_body_entered(body):
	if not stopped and body.is_in_group("player") and body.pushed == false:
		body.velocity=(body.global_position-global_position).normalized()*12
		body.velocity.y = 0
		body.pushed = true


func _on_slash_entered(body):
	if body.is_in_group("player"):
		body.hit(10)


func _on_box_hit(body: Node3D) -> void:
	if body.is_in_group("pebble"):
		body.queue_free()
		whirlwind_time = 0
		$box.use_collision=false
		stopped = true
		$AnimationPlayer.play("whirlwind_end")


func _on_animation_finished(anim_name):
	if anim_name == "slash":
		doing = false
	if anim_name == "whirlwind_start":
		stopped = false
		$box.use_collision = true
	if anim_name == "whirlwind_end":
		doing = false
