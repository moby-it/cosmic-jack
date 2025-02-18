extends Resource
class_name Wave

@export var enabled = true
@export var convoys: Array[Convoy]
@export_file("*.wav", "*.mp3") var audio_track
@export var bpm: int
@export var ammo: Ammo
