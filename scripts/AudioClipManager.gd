extends Node

var num_players: int = 8
var bus: String = "master"
var volumeMultiplier: float = 1.0

var available: Array[AudioStreamPlayer] = []
var queue: Array[Array] = []

func _ready():    
	for i in num_players:
		var player = AudioStreamPlayer.new()
		add_child(player)
		available.append(player)
		player.volume_linear *= volumeMultiplier
		player.bus = bus
		player.finished.connect(_on_stream_finished.bind(player, player.volume_linear))
		
func _on_stream_finished(stream: AudioStreamPlayer, base_volume: float):   
	available.append(stream)
	stream.volume_linear = base_volume
	
func play(sound_path: String, volumeMultiplier: float = 1.0):
	queue.append([sound_path, volumeMultiplier])
	
func _process(delta):
	if not queue.is_empty() and not available.is_empty():
		var q_element = queue.pop_front()
		var clip_path = q_element[0]
		var volumeMult = q_element[1]
		var assigned_stream = available[0]
		assigned_stream.stream = load(clip_path)
		assigned_stream.volume_linear *= volumeMult
		assigned_stream.play()
		available.pop_front()
