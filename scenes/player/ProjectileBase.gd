extends CharacterBody3D
class_name ProjectileBase

var speed: int = 2
var gravity: int = -10
@export var HEIGHT_OF_ARC: float = 2.0
@export var destroy_on_hit: bool = true
@export var destroy_on_miss: bool = false
@export var projectile_damage: float = 5.0
var spawner = null
var KILL_ZONE: float = -50.0

func _ready() -> void:
	velocity.y = -1

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

func shoot(origin, end, result) -> void:
	if result:
		var result_position = result.get("position")
		var height = result_position.y - global_position.y + HEIGHT_OF_ARC
		height = abs(height)
		var displacement_y = result_position.y-global_position.y
		var displacemnt_xz = Vector3(result_position.x - global_position.x, 0, result_position.z - global_position.z)
		var velocity_y = Vector3.UP * sqrt(-2 * gravity * height)
		var velocity_xz = displacemnt_xz / (sqrt(-2 * height / gravity) + sqrt(2 * (displacement_y - height) / gravity))
		velocity = velocity_y + velocity_xz
	else:
		velocity = end - origin
		var height = velocity.y / 8
		velocity = velocity.normalized()
		velocity *= 40
		velocity.y = height

func on_pick_up():
	_notify_spawner()
	destroy()

func _on_hit(collision):
	if collision.get_collider().is_in_group("enemy"):
		collision.get_collider().hit(collision.get_collider_shape(), projectile_damage)
		destroy()

func _notify_spawner() -> void:
	if spawner:
		spawner.on_projectile_picked(self)
		spawner = null
	
func destroy():
	_notify_spawner()
	queue_free()
