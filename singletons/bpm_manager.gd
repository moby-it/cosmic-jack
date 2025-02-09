extends Node

var beat = 0 
var bpm: int
var time_begin: int
var time_delay: int
var next_beat_time = 0.0
var seconds_per_beat: float

signal on_beat

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not bpm:
		return
	var time = (Time.get_ticks_usec() - time_begin) / 1000000.0 
	time -= time_delay
	if time >= next_beat_time:
		on_beat.emit(beat)
		next_beat_time += seconds_per_beat
		beat += 1
		print("on beat %s" % beat)
		print("time %s" % time)

func reset():
	bpm = 0
	time_begin = 0
	time_delay = 0
	next_beat_time = 0.0
	seconds_per_beat = 0.0
	beat = 0
