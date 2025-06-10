extends Node

var num_players: int = 8
var bus: String = "master"
var volumeMultiplier: float = 1.0

var available: Array[AudioStreamPlayer] = []
var queue: Array[String] = []

func _ready():    
	for i in num_players:
		var player = AudioStreamPlayer.new()
		add_child(player)
		available.append(player)
		player.finished.connect(_on_stream_finished.bind(player))
		player.bus = bus
		player.volume_linear *= volumeMultiplier
		
func _on_stream_finished(stream: AudioStreamPlayer):   
	available.append(stream)
	
func play(sound_path: String, volumeMultiplier: float = 1.0):
	queue.append(sound_path)
	
func _process(delta):
	if not queue.is_empty() and not available.is_empty():
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()
