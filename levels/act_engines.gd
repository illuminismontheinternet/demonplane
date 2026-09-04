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

@rpc("authority", "call_local", "reliable")
func start_broken_minigame_rpc(inFixes):
	#print("start broken mini game - peer: ", multiplayer.get_unique_id())
	required_fixes = inFixes
	light._change_light(broken_color)

func start_broken_minigame():
	if not is_multiplayer_authority(): return
	var fix_count = randi_range(1, max_fixes)
	print("act_engines: fix_count is: ", fix_count)
	start_broken_minigame_rpc.rpc(fix_count)
	break_random_component()
	
@rpc("authority", "call_local", "reliable")
func end_broken_minigame_rpc():
	light._change_light(fixed_color)
	
@rpc("authority", "call_local", "reliable")
func break_component_rpc(inID):
	do_break_component(inID)
	
func break_random_component():
	var target_comp = rng.randi_range(0,components.size()-1)
	break_component_rpc.rpc(target_comp)
	
func do_break_component(inID):
	components[inID].material.emission_enabled = true
	components[inID].material.emission = broken_color
	
@rpc("authority", "call_local", "reliable")
func fully_repaired_rpc():
	fully_repaired.emit()
	
func inner_fix_component():
	required_fixes = required_fixes - 1
	print("act_engines required fixes: ", required_fixes)
	if required_fixes > 0:
		break_random_component()
	else:
		end_broken_minigame_rpc.rpc()
		fully_repaired_rpc.rpc()
		
@rpc("any_peer", "call_local", "reliable")
func do_fix_component_rpc(inComponentID):
	print("do_fix_component - peer: ", multiplayer.get_unique_id())
	if required_fixes > 0:
		components[inComponentID].material.emission_enabled = false
		components[inComponentID].material.emission = fixed_color
		if not is_multiplayer_authority(): return
		inner_fix_component()
		
func _on_fuel_cyl_repaired() -> void:
	do_fix_component_rpc.rpc(0)

func _on_spark_cyl_repaired() -> void:
	do_fix_component_rpc.rpc(2)

func _on_air_cyl_repaired() -> void:
	do_fix_component_rpc.rpc(1)
