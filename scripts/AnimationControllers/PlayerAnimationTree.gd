extends AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	print("condition isRunning: " + str(self["parameters/conditions/isRunning"]))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	if event.is_action_pressed("jump"):
		print("isRunning flipped")
		self.set("parameters/conditions/isRunning", not self["parameters/conditions/isRunning"])
