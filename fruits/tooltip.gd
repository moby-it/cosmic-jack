extends Resource
class_name Tooltip

func tooltip_add_timer(node: Control):
	return func():
		var tooltip_node = node.get_node("tooltip")
		tooltip_node.visible = false
		var timer = node.get_node("timer")
		if is_instance_valid(timer):
			return
		timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = 1.0
		timer.autostart = true
		timer.timeout.connect(func(): tooltip_node.visible = true)
		timer.name = "timer"
		node.add_child(timer)

func remove(node: Control):
	return func():
		var tooltip: Label = node.get_node("tooltip")
		if tooltip.visible:
			tooltip.visible = false
		var timer: Timer = node.get_node("timer")
		if is_instance_valid(timer):
			timer.stop()
			timer.queue_free()
		else:
			push_warning("timer should be present")

func connect_tooltip_on_hover(node: Control, tooltip_content: String):
	node.text = tooltip_content
	node.mouse_entered.connect(tooltip_add_timer(node))
	node.mouse_exited.connect(remove(node))
