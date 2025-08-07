extends StaticBody2D

class_name Platform

@export var jump_force: float = 0.0
signal delete_object(obstacle)

func get_jump_force() -> float:
	return jump_force
