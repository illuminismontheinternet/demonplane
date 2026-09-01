extends Node3D

signal fully_repaired

@onready var light = $lightbox3
@onready var fuel_mesh = $fuel_cyl
@onready var air_mesh = $air_cyl
@onready var spark_mesh = $spark_cyl

@onready var components = [
	fuel_mesh,
	air_mesh,
	spark_mesh
]

var bNeedsFixing = false
var required_fixes = 0
const max_fixes = 5
const min_next_time = 1.0
const max_next_time = 6.0

var broken_color = Color.RED
var fixed_color = Color.GREEN

var rng = RandomNumberGenerator.new()

func start_broken_minigame():
	required_fixes = rng.randi_range(0, max_fixes)
	light._change_light(broken_color)
	break_random_component()

func end_broken_minigame():
	light._change_light(fixed_color)
	
func break_random_component():
	print(components[rng.randi_range(0,components.size()-1)])
	do_break_component(components[rng.randi_range(0,components.size()-1)])
	
func do_break_component(inMesh):
	#inMesh.get_material(0).emission = broken_color
	inMesh.material.emission_enabled = true
	inMesh.material.emission = broken_color
	
func do_fix_component(inMesh):
	#inMesh.get_material(0).emission = fixed_color
	inMesh.material.emission_enabled = false
	inMesh.material.emission = fixed_color
	required_fixes = required_fixes - 1
	if required_fixes > 0:
		await get_tree().create_timer(randf_range(min_next_time,max_next_time))
		break_random_component()
	else:
		end_broken_minigame()
		fully_repaired.emit()
		
func _on_fuel_cyl_repaired() -> void:
	do_fix_component(fuel_mesh)

func _on_spark_cyl_repaired() -> void:
	do_fix_component(spark_mesh)

func _on_air_cyl_repaired() -> void:
	do_fix_component(air_mesh)
