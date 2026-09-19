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

@export var spotlight : SpotLight3D
@export var mesh : Node3D

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
	set_spotlight_active(false)
