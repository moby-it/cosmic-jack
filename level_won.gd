extends ColorRect


func _on_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
