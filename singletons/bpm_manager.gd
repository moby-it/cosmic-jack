extends Node

var beat = 0 
var bpm: int
var time_accumulator := 0.0

var next_beat_time = 0.0
var seconds_per_beat: float
var time_to_next_beat = 0.0
signal on_beat

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not bpm:
		return
	time_accumulator += delta
	time_to_next_beat -= delta
	if time_accumulator >= next_beat_time:
		time_to_next_beat = seconds_per_beat
		on_beat.emit(beat)
		next_beat_time += seconds_per_beat
		beat += 1
		print("on beat %s" % beat)
		print(Time.get_ticks_msec())

func reset():
	bpm = 0
	time_accumulator = AudioServer.get_output_latency()
	next_beat_time = 0.0
	seconds_per_beat = 0.0
	beat = 0
