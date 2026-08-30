class_name plane_director
extends CSGCombiner3D

@onready var plane = $"."

enum ENUM_PLANESTATUS {
	TAKEOFF,
	IDLE,
	TURBULENCE,
	LAND,
	POWEROFF
}
var current_status = ENUM_PLANESTATUS.IDLE

# random stuff
var min_delta = 0.0
var max_delta = 0.0
const rotation_speed = 5.0

# plane stuff
var target_pitch = 0.0
var target_yaw = 0.0
var target_roll = 0.0
const takeoff_pitch = 5
var target_basis : Basis

func set_target_basis():
	target_basis = Basis.from_euler(Vector3(
	deg_to_rad(target_pitch),
	deg_to_rad(target_yaw),
	deg_to_rad(target_roll)
	))
	
func set_nose_pitch(inPitch):
	target_pitch = inPitch

func set_delta_spread(inLower, inUpper):
	min_delta = get_random_float_range(-inUpper,inLower)
	max_delta = get_random_float_range(inLower,inUpper)
	
func get_random_float_range(inMinDelta, inMaxDelta) -> float:
	return randf_range(inMinDelta, inMaxDelta)

func set_stats():
	match current_status:
		ENUM_PLANESTATUS.IDLE: 
			set_delta_spread(0,0.1)
			set_nose_pitch(0.0)
		ENUM_PLANESTATUS.TURBULENCE: 
			set_delta_spread(0,5)
			set_nose_pitch(get_random_float_range(-1,1))
		ENUM_PLANESTATUS.TAKEOFF:
			set_delta_spread(0,1)
			set_nose_pitch(takeoff_pitch)
		ENUM_PLANESTATUS.LAND:
			set_delta_spread(0,1)
			set_nose_pitch(-takeoff_pitch)
		ENUM_PLANESTATUS.POWEROFF:
			set_delta_spread(0,0)
			set_nose_pitch(0)

func _ready():
	current_status = ENUM_PLANESTATUS.TAKEOFF
	
func _physics_process(delta):
	set_stats()
	set_target_basis()
	var t = 1.0 - exp(-rotation_speed * delta)
	plane.transform.basis = plane.transform.basis.slerp(target_basis, t)


func _on_level_plane_event(new_state: plane_director.ENUM_PLANESTATUS) -> void:
	current_status = new_state
