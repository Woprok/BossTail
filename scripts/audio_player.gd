extends AudioStreamPlayer2D

var start_volume: float

func _ready() -> void:
	start_volume = volume_linear
	volume_linear *= AudioClipManager.masterVolume * AudioClipManager.musicVolume
	AudioClipManager.volume_settings_changed.connect(volume_settings_changed)
	
func volume_settings_changed(master: float, music: float, sfx: float) -> void:
	volume_linear = start_volume * master * music
