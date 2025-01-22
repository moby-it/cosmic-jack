extends Resource
class_name Tooltip

func tooltip_add_timer(node: Node2D):
	return func():
		print("mouse entered", node.name)
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

func remove(node: Node2D):
	return func():
		print("mouse left", node.name)
		var tooltip: Label = node.get_node("tooltip")
		if tooltip.visible:
			tooltip.visible = false
		var timer: Timer = node.get_node("timer")
		if is_instance_valid(timer):
			timer.stop()
			timer.queue_free()
		else:
			push_warning("timer should be present")

func connect_tooltip_on_hover(node: Node2D, tooltip_content: String):
	var tooltip_node: Label = node.get_node("tooltip")
	tooltip_node.text = tooltip_content
	var area = node.get_node("Area2D")
	area.mouse_entered.connect(tooltip_add_timer(node))
	area.mouse_exited.connect(remove(node))
