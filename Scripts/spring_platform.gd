extends "res://Scripts/platform.gd"

class_name SpringPlatform

func response() -> void:
	$Spring.play("default")

func _on_spring_animation_finished() -> void:
	$Spring.frame = 0
	$Spring.stop()
