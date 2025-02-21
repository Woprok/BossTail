extends CharacterBody3D

var speed:int = 75
var speed_dec:int = 10
var time:int = 0
var max_time:int = 3

func _physics_process(delta):
	time += delta
	if time>max_time:
		queue_free()
	speed -= speed_dec*delta
	var colision = move_and_collide(velocity*speed*delta)
	if colision:
		if colision.get_collider().is_in_group("enemy") or colision.get_collider().is_in_group("player"):
			colision.get_collider().hit(colision.get_collider_shape())
		queue_free()	
	if speed<=0:
		queue_free()

func shoot(origin, end, result):
	if result:
		velocity = result.get("position")-position
		velocity = velocity.normalized()
	else:
		velocity = end - origin
		velocity = velocity.normalized()
