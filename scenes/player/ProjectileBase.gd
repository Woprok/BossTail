extends CharacterBody3D
class_name ProjectileBase

var speed: int = 2
var gravity: int = -10
@export var destroy_on_hit: bool = true
@export var destroy_on_miss: bool = false
@export var projectile_damage: float = 5.0

var spawner = null
var KILL_ZONE: float = -50.0

func _ready() -> void:
	velocity.y = -1

func is_pickable() -> bool:
	# why is this not on ground ? when it's not moving ? in_on_floor() return false
	return velocity.length() == 0.0

func _physics_process(delta):
	if is_on_floor():
		# should be ignored, if it's just lying on the ground
		return
	velocity.y += speed * gravity * delta
	var collision = move_and_collide(speed * velocity * delta)
	if position.y < KILL_ZONE:
		destroy()
	elif collision:
		if spawner:
			velocity = Vector3(-2,-1,-2)
		else:
			velocity = Vector3(0,0,0)
			_on_hit(collision)

func shoot(new_velocity) -> void:
	velocity = new_velocity

func on_pick_up():
	# same as destroy, both notify spawner and remove self from existance
	destroy()

func _on_hit(collision):
	#if collision.get_collider().is_in_group("minion"):
	#	collision.get_collider().hit(self, projectile_damage)
	
	if collision.get_collider().is_in_group("enemy"):
		collision.get_collider().hit(collision.get_collider_shape(), projectile_damage)
		AudioClipManager.play("res://assets/audio/sfx/HitImpact.wav")
		destroy()		

func _notify_spawner() -> void:
	if spawner:
		spawner.on_projectile_picked(self)
		spawner = null
	
func destroy():
	_notify_spawner()
	queue_free()
