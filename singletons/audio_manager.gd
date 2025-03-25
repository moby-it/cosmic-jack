extends Node

var beat = 0 
var bpm: int
var time_begin: int
var time_delay: float
var next_beat_time = 0.0
var seconds_per_beat: float
var time_to_next_beat = 0.0
var paused = false
var paused_time_offset: float
signal on_beat
signal on_pause

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not bpm:
		return
	var time = (Time.get_ticks_usec() - time_begin) / 1000000.0 
	time -= time_delay # it seems that the time delay is not needed
	time_to_next_beat = next_beat_time - time
	#print("time %s, next_beat_time %s" % [time, next_beat_time])
	if time >= next_beat_time:
		if not paused:
			on_beat.emit(beat)
			beat += 1
			#print("on beat %s" % beat)
		next_beat_time += seconds_per_beat
		time_to_next_beat = seconds_per_beat
		#print("time %s" % time)

func trigger_pause():
		if not paused:
			pause() 
		else:
			await unpause()

func pause():
	#var time = (Time.get_ticks_usec() - time_begin) / 1000000.0
	paused_time_offset = seconds_per_beat - time_to_next_beat
	#print("pause at offset: ", paused_time_offset)
	#print("next beat after: ", time_to_next_beat)
	paused = true
	on_pause.emit()

func unpause():
	await get_tree().create_timer(time_to_next_beat + paused_time_offset).timeout
	paused = false
	paused_time_offset = 0.0
	on_pause.emit()
	
func reset():
	paused = false
	bpm = 0
	time_begin = 0
	time_delay = 0
	next_beat_time = 0.0
	seconds_per_beat = 0.0
	time_to_next_beat = 0.0
	beat = 0
