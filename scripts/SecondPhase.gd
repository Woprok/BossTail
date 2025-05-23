extends Node3D

var frog_health = preload("res://data_resources/FrogBossDataModel.tres")
var WaterBubble = preload("res://scenes/WaterBubble.tscn")
var last_bubble = 0
var angle = 0

func _process(delta):
	last_bubble += delta
	angle += delta
	randomize()
	if Global.phase == 2:
		if last_bubble >= 4.0/100.0 * frog_health.boss_current_health + 0.01:
			last_bubble = 0
			var bubble = WaterBubble.instantiate()
			bubble.scale*=2
			$bubbles.add_child(bubble)
			if $Player.platform != null:
				var center_position = $Player.platform.global_position 
				var radius = $Player.platform.radius
				angle = randf()*TAU
				var x = center_position.x + cos(angle) * radius
				var z = center_position.z + sin(angle) * radius
				bubble.position = Vector3(x,4,z)
				bubble.emerge()
