class_name Pickup
extends Node

enum ENUM_PICKUPTYPE {
	WRENCH,
	HAMMER,
	AXE,
	SHOVEL,
	GASCAN,
}

var pickup_type = ENUM_PICKUPTYPE.GASCAN
var bIsGrounded = true

@export var raycast : RayCast3D
@export var spotlight : SpotLight3D
@export var mesh : Node3D

func attempt_gravity() -> void:
	while not bIsGrounded:
		await get_tree().create_timer(0.01).timeout
		get_parent().global_position += Vector3(0,-0.1,0)
		if raycast.is_colliding():
			bIsGrounded = true
	
func on_drop(inPosition : Vector3) -> void:
	print("drop here")
	get_parent().global_position = inPosition
	mesh.visible = true
	set_spotlight_active(true)
	bIsGrounded = false
	attempt_gravity()
	
func on_pickup() -> void:
	# hide everything
	mesh.visible = false
	set_spotlight_active(false)
	
func get_type() -> ENUM_PICKUPTYPE:
	return pickup_type
	
func set_spotlight_active(bIsActive) -> void:
	if spotlight:
		spotlight.visible = bIsActive
	
func _ready() -> void:
	set_spotlight_active(true)
