extends Node3D

signal plane_event(new_state: plane_director.ENUM_PLANESTATUS)
signal match_finished(bVictory: bool)

# 300 seconds is 5 minutes
@export var match_duration := 300

# schedule the game
var events = [
	{
		"time": 0,
		"type": plane_director.ENUM_PLANESTATUS.TAKEOFF
	},
	{
		"time": 10,
		"type": plane_director.ENUM_PLANESTATUS.IDLE
	},
	{
		"time": 20,
		"type": plane_director.ENUM_PLANESTATUS.TURBULENCE
	},
	{
		"time": 30,
		"type": plane_director.ENUM_PLANESTATUS.IDLE
	},
	{
		"time": 40,
		"type": plane_director.ENUM_PLANESTATUS.LAND
	},
	{
		"time": 50,
		"type": plane_director.ENUM_PLANESTATUS.POWEROFF
	}
]
var next_event := 0
var start_time := 0.0

func start_match():
	start_time = Time.get_ticks_msec() /  1000.0

func get_elapsed_time() -> float:
	return (Time.get_ticks_msec() / 1000.0) - start_time

func execute_event(event_type: plane_director.ENUM_PLANESTATUS):
	plane_event.emit(event_type)
		
# normal funcs
func _ready() -> void:
	start_match()
	
func _physics_process(_delta: float) -> void:
	var seconds = get_elapsed_time()
	while next_event < events.size() and seconds >= events[next_event].time:
		execute_event(events[next_event].type)
		print(events[next_event])
		next_event += 1
		
		
	if seconds >= match_duration:
		match_finished.emit()
