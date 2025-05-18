extends CharacterBody3D
var stopped = false
var speed = 5
var gravity = -3
var jump = false
var box_hit = true

@export var BOX_RESPAWN_TIME = 3
@export var STUNNED_TIME = 2
@export var WHIRLWIND_STRENGTH = 15

var Box = preload("res://scenes/Crates.tscn")
var stop_time = 10

func _ready() -> void:
	whirlwind()

func _physics_process(delta):
	stop_time += delta
	if jump:
		velocity.y += speed*gravity*delta
		var _collision = move_and_collide(speed*velocity*delta)
	else:
		velocity.y = 0
	if stopped and ((box_hit and stop_time>=BOX_RESPAWN_TIME) or (not box_hit and stop_time>=STUNNED_TIME)):
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
	if box_hit == false:
		return
	get_parent().get_node("AnimationPlayer").play("last_wall")
	GameEvents.tutorial_phase.emit(3)
	queue_free()
	
func whirlwind():
	if box_hit:
		box_hit = false
		jump = true
		velocity.y = speed
		var box = Box.instantiate()
		box.dummy_box = true
		box.dummy_parent = self
		box.get_node("hit/CollisionShape3D").disabled = false
		get_parent().add_child.call_deferred(box)
		box.position = Vector3(position.x,-5.25,position.z)
		box.scale/=4

func _on_body_entered(body):
	if not stopped and body.is_in_group("player") and body.pushed == false:
		var vel = (body.global_position-global_position).normalized()*WHIRLWIND_STRENGTH
		vel.y = 0
		body.velocity = vel
		body.pushed = true


func _on_box_hit(body: Node3D) -> void:
	if body.is_in_group("pebble"):
		box_hit = true
		stopped = true
		jump = true
		stop_time = 0
		

func _on_ground_body_entered(_body: Node3D) -> void:
	if velocity.y<0:
		jump = false
