extends Node3D

signal plane_event(new_state: plane_director.ENUM_PLANESTATUS)
signal match_finished(bVictory: bool)

# 300 seconds is 5 minutes
@export var match_duration := 300
@onready var act_engines = $CSGCombiner3D/ACT_Engines

enum ENUM_ACT {
	NONE,
	ENGINES,
	PILOT,
	WING_RIGHT,
	WING_LEFT
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
		"time": 10,
		"type": plane_director.ENUM_PLANESTATUS.IDLE,
		"act" : ENUM_ACT.NONE
	},
	{
		"time": 15,
		"type": plane_director.ENUM_PLANESTATUS.IDLE,
		"act" : ENUM_ACT.ENGINES
	},
	{
		"time": 20,
		"type": plane_director.ENUM_PLANESTATUS.TURBULENCE,
		"act" : ENUM_ACT.NONE
	},
	{
		"time": 30,
		"type": plane_director.ENUM_PLANESTATUS.IDLE,
		"act" : ENUM_ACT.NONE
	},
	{
		"time": 40,
		"type": plane_director.ENUM_PLANESTATUS.LAND,
		"act" : ENUM_ACT.NONE
	},
	{
		"time": 50,
		"type": plane_director.ENUM_PLANESTATUS.POWEROFF,
		"act" : ENUM_ACT.NONE
	}
]

var next_event := 0
var start_time := 0.0

func start_match():
	start_time = Time.get_ticks_msec() /  1000.0

func get_elapsed_time() -> float:
	return (Time.get_ticks_msec() / 1000.0) - start_time

func execute_plane_event(event_type: plane_director.ENUM_PLANESTATUS):
	plane_event.emit(event_type)

func execute_act_event(act_type: ENUM_ACT):
	if act_type == ENUM_ACT.ENGINES:
		print("ENGINES ARE BROKEN - GO FIX THEM!!")
		act_engines.start_broken_minigame()
		
# normal funcs
func _ready() -> void:
	start_match()
	
func _physics_process(_delta: float) -> void:
	var seconds = get_elapsed_time()
	while next_event < events.size() and seconds >= events[next_event].time:
		execute_plane_event(events[next_event].type)
		execute_act_event(events[next_event].act)
		print(events[next_event])
		next_event += 1
		
	if seconds >= match_duration:
		match_finished.emit()
