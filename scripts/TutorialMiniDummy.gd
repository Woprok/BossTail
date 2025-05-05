extends CharacterBody3D
var stopped = false
@export var BOX_RESPAWN_TIME = 3
@export var WHIRLWIND_STRENGTH = 15
var stop_time = 10

func _ready() -> void:
	whirlwind()

func _physics_process(delta):
	stop_time += delta
	if stopped and stop_time>=BOX_RESPAWN_TIME:
		stopped = false
		whirlwind()
	if stopped:
		$Area3D/CollisionShape3D.disabled = true
		return
	$Area3D/CollisionShape3D.disabled = false
	rotate_y(delta*20)

func hit(_health):
	stopped = true
	stop_time = 0


func death():
	get_parent().get_node("AnimationPlayer").play("last_wall")
	GameEvents.tutorial_phase.emit(3)
	queue_free()
	
func whirlwind():
	$AnimationPlayer.play("whirlwind_start",2)
	

func _on_body_entered(body):
	if not stopped and body.is_in_group("player") and body.pushed == false:
		var vel = (body.global_position-global_position).normalized()*WHIRLWIND_STRENGTH
		vel.y = 0
		body.velocity = vel
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
