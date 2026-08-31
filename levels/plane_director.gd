class_name plane_director
extends CSGCombiner3D

var rng = RandomNumberGenerator.new()

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

# height changes
var target_y_pos = 0.0
const y_mult = 0.5

# evasive maneuver chances
var bool_array = [true, false]
var em_weight = PackedFloat32Array([5,1])
var em_active = false
var em_roll = 0.0
const em_mult = 20.0

func set_target_basis():
	target_basis = Basis.from_euler(Vector3(
	deg_to_rad(target_pitch),
	deg_to_rad(target_yaw),
	deg_to_rad(target_roll)
	))

func stop_evasive_maneuvers():
	em_roll = 0.0
	em_active = false
	
func roll_evasive_maneuvers():
	if em_active == false and bool_array[rng.rand_weighted(em_weight)]:
		em_active = true
		em_roll = get_random_float_range(min_delta,max_delta) * em_mult
		print("EVASIVE MANEUVERS!!", em_roll)
	
func set_plane_y_pos():
	target_y_pos = get_random_float_range(min_delta,max_delta) * y_mult
	
func set_plane_yaw_roll():
	target_yaw = get_random_float_range(min_delta, max_delta)
	target_roll = get_random_float_range(min_delta, max_delta) + em_roll
	
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
			set_delta_spread(-0.5,0.5)
			set_nose_pitch(get_random_float_range(-1,1))
			stop_evasive_maneuvers()
		ENUM_PLANESTATUS.TURBULENCE: 
			set_delta_spread(0,5)
			set_nose_pitch(get_random_float_range(-10,10))
			roll_evasive_maneuvers()
		ENUM_PLANESTATUS.TAKEOFF:
			set_delta_spread(0,1)
			set_nose_pitch(takeoff_pitch + get_random_float_range(-3,3))
			stop_evasive_maneuvers()
		ENUM_PLANESTATUS.LAND:
			set_delta_spread(0,1)
			set_nose_pitch(takeoff_pitch + get_random_float_range(-3,3))
			stop_evasive_maneuvers()
		ENUM_PLANESTATUS.POWEROFF:
			set_delta_spread(0,0)
			set_nose_pitch(0)

func _ready():
	current_status = ENUM_PLANESTATUS.TAKEOFF
	
func _physics_process(delta):
	set_stats()
	set_plane_yaw_roll()
	set_plane_y_pos()
	set_target_basis()
	var t = 1.0 - exp(-rotation_speed * delta)
	plane.transform.basis = plane.transform.basis.slerp(target_basis, t)
	#plane.global_position.y = plane.global_position.y.lerpf(target_y_pos, t)
	plane.global_position.y = lerpf(plane.global_position.y, target_y_pos, t)
	

func _on_level_plane_event(new_state: plane_director.ENUM_PLANESTATUS) -> void:
	current_status = new_state
