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

func set_spotlight_active(bIsActive) -> void:
	if spotlight:
		spotlight.visible = bIsActive
	
func _ready() -> void:
	set_spotlight_active(false)
