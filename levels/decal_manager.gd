extends Node3D

@export var decal_impact_pool_size = 49
@onready var decal_impact = $Decal_Impact
@onready var network_manager = $".."

var current_index = 0
var impact_array = []

func place_decal_impact(inPosition, inNormal) -> void:
	impact_array.get(current_index).global_position = inPosition
	impact_array.get(current_index).look_at(inPosition, inNormal)
	print(impact_array.get(current_index).rotation)
	current_index = current_index + 1
	if current_index >= decal_impact_pool_size:
		current_index = 0
	
func create_pool():
	# Add the first one!
	impact_array.append(decal_impact)
	for i in range(0,decal_impact_pool_size):
		# Create copies of the basic decal
		var decal_copy = decal_impact.duplicate()
		add_child(decal_copy)
		impact_array.append(decal_copy)
	#print(impact_array.size())

func _ready() -> void:
	create_pool();
