extends Node3D

@export var speed = 0.1

func _physics_process(_delta: float) -> void:
	rotate(Vector3.UP, speed)
