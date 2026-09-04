extends Node3D

signal plane_event(new_state: plane_director.ENUM_PLANESTATUS)
signal match_finished(bVictory: bool)

# 300 seconds is 5 minutes
@export var match_duration := 300
@onready var act_engines = $CSGPlaneParent/ACT_Engines

# game ending variables
var bEnginesBroken = false

enum ENUM_ACT {
	NONE,
	ENGINES,
	PILOT,
	WING_RIGHT,
	WING_LEFT,
	ATTEMPT_LAND
}
var current_act = ENUM_ACT.NONE

# schedule the game
var events = [
	{
		"time": 0,
		"type": plane_director.ENUM_PLANESTATUS.TAKEOFF,
		"act" : ENUM_ACT.NONE
	},
	{
		"time": 5,
		"type": plane_director.ENUM_PLANESTATUS.IDLE,
		"act" : ENUM_ACT.NONE
	},
	{
		"time": 10,
		"type": plane_director.ENUM_PLANESTATUS.IDLE,
		"act" : ENUM_ACT.ENGINES
	},
	{
		"time": 15,
		"type": plane_director.ENUM_PLANESTATUS.TURBULENCE,
		"act" : ENUM_ACT.NONE
	},
	{
		"time": 20,
		"type": plane_director.ENUM_PLANESTATUS.IDLE,
		"act" : ENUM_ACT.NONE
	},
	{
		"time": 25,
		"type": plane_director.ENUM_PLANESTATUS.LAND,
		"act" : ENUM_ACT.ATTEMPT_LAND
	},
	{
		"time": 30,
		"type": plane_director.ENUM_PLANESTATUS.POWEROFF,
		"act" : ENUM_ACT.NONE
	}
]
var next_event := 0
var start_time := 0.0

@rpc("authority", "call_local", "reliable")
func end_match():
	#print("level manager end match - peer: ", multiplayer.get_unique_id())
	if bEnginesBroken:
		match_finished.emit(false)
	else:
		match_finished.emit(true)
		
func start_match():
	start_time = Time.get_ticks_msec() /  1000.0

func get_elapsed_time() -> float:
	return (Time.get_ticks_msec() / 1000.0) - start_time

@rpc("authority", "call_local", "reliable")
func execute_plane_event(event_type: plane_director.ENUM_PLANESTATUS):
	plane_event.emit(event_type)

@rpc("authority", "call_local", "reliable")
func execute_act_event(act_type: ENUM_ACT):
	if act_type == ENUM_ACT.ENGINES:
		bEnginesBroken = true
		#print("execute_act_event - peer: ", multiplayer.get_unique_id())
		#print("ENGINES ARE BROKEN - GO FIX THEM!!")
		act_engines.start_broken_minigame()
	if act_type == ENUM_ACT.ATTEMPT_LAND:
		end_match.rpc()
		
# normal funcs
func _ready() -> void:
	if not is_multiplayer_authority(): return
	start_match()
	
func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	var seconds = get_elapsed_time()
	while next_event < events.size() and seconds >= events[next_event].time:
		execute_plane_event.rpc(events[next_event].type)
		execute_act_event.rpc(events[next_event].act)
		next_event += 1
	# calling this on the schedule now
	#if seconds >= match_duration:
		#match_finished.emit()

func _on_act_engines_fully_repaired() -> void:
	bEnginesBroken = false
