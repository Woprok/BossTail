extends Area3D

var MAX_TIME = 10
var time = 0

func _process(delta):
	time += delta
	if time > MAX_TIME:
		time = 0
		var tween = get_tree().create_tween()
		tween.tween_property(self,"scale",Vector3(0.1,0.1,0.1),0.5)
		tween.tween_callback(queue_free)
