extends CharacterBody3D
var stopped = false
@export var RESPAWN_TIME = 3
var stop_time = 0

func _ready() -> void:
	whirlwind()

func _physics_process(delta):
	stop_time += delta
	if stop_time>=RESPAWN_TIME:
		stopped = false
	if stopped:
		return
	rotate_y(delta*20)


func hit(_health):
	stopped = true
	stop_time = 0

func whirlwind():
	$AnimationPlayer.play("whirlwind_start",2)
	

func _on_body_entered(body):
	if not stopped and body.is_in_group("player") and body.pushed == false:
		body.velocity=(body.global_position-global_position).normalized()*13
		body.velocity.y = 0
		body.pushed = true


func _on_box_hit(body: Node3D) -> void:
	if body.is_in_group("pebble"):
		body.queue_free()
		$box.use_collision=false
		stopped = true
		stop_time = 0
		$AnimationPlayer.play("whirlwind_end")


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "whirlwind_start":
		$box.use_collision = true
