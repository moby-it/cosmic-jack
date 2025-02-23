extends Resource
class_name Wave

@export var enabled = true

@export var title = "Wave Title"
@export var subtitle = ""
@export_multiline var description = ""

@export var convoys: Array[Convoy]
@export_file("*.wav", "*.mp3") var audio_track
@export var bpm: int
@export var ammo: Ammo

@export var goal: String
@export_multiline var solution: String
