extends "res://Scripts/platform.gd"

class_name CloudPlatform

func response() -> void:
	emit_signal("delete_object", self)
