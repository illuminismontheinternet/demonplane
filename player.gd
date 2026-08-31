extends CharacterBody3D

@onready var head = $neck/head
@onready var body = $"."
@onready var camera = $neck/head/Camera3D

const SPEED_MULT = 1.0
var SPRINT_MULT = 1.0
const SPRINT_MAX = 2.0
const STOP_SPEED = 2
var MOMEMTUM_MULT = 1.1

const JUMP_VELOCITY = 5.5
const AIR_CONTROL = 1.1
const TERMINAL_VELOCITY = 53.5

# looking
const LOOKSENS_HOR = 0.001
const LOOKSENS_VERT = 0.1
const MINCAM = -89.5
const MAXCAM = 89.5
var temp_rot = 0.0
var bCanLook = true

const TARGET_SWAY = 0.0
const LERP_SWAY = 0.1

var OLD_VELOCITY : Vector3
var OUTSIDE_VELOCITY : Vector3
var air_dir : Vector3
var wish_dir : Vector3

var bWasFalling = false

func _handle_land():
	print("_handle_land")
	
func _rotate_look(inRelX, inRelY):
	if bCanLook:
		body.rotate_y(-inRelX * LOOKSENS_HOR)
		temp_rot = camera.rotation.x
		temp_rot += deg_to_rad(-inRelY * LOOKSENS_VERT)
		temp_rot = clamp(temp_rot, deg_to_rad(MINCAM), deg_to_rad(MAXCAM))
		camera.rotation.x = temp_rot
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_rotate_look(event.relative.x, event.relative.y)
		
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
func _physics_process(delta: float) -> void:	
	# do normal inputs
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(-input_dir.x, 0, -input_dir.y)).normalized()
	if is_on_floor():
		if bWasFalling:
			#print("we landed!")
			bWasFalling = false
			# calculate velocity difference for damage
			_handle_land()
			
		# Handle directional input
		air_dir = Vector3.ZERO
		if direction:
			wish_dir.x = direction.x * SPEED_MULT * SPRINT_MULT * MOMEMTUM_MULT
			wish_dir.z = direction.z * SPEED_MULT * SPRINT_MULT * MOMEMTUM_MULT
		else:
			wish_dir.x = move_toward(wish_dir.x, 0, STOP_SPEED)
			wish_dir.z = move_toward(wish_dir.z, 0, STOP_SPEED)
			OUTSIDE_VELOCITY.x = 0#move_toward(OUTSIDE_VELOCITY.x, 0, STOP_SPEED * delta)
			OUTSIDE_VELOCITY.z = 0#move_toward(OUTSIDE_VELOCITY.z, 0, STOP_SPEED * delta)
			MOMEMTUM_MULT = move_toward(MOMEMTUM_MULT, 1, delta)
		# handle SPRINT
		if Input.is_action_pressed("sprint"):
			SPRINT_MULT = SPRINT_MAX
			MOMEMTUM_MULT = move_toward(MOMEMTUM_MULT, 3, delta * 2)
		else:
			SPRINT_MULT = 1.0
		
		# handle jump
		if Input.is_action_just_pressed("jump"):
				velocity.y += JUMP_VELOCITY
	# not on floor
	else: 
		# Handle falling
		bWasFalling = true
	
		OLD_VELOCITY = velocity
		
		wish_dir.x = move_toward(wish_dir.x, 0, delta * 2)
		wish_dir.z = move_toward(wish_dir.z, 0, delta * 2)
		# Handle directional input for air control
		if direction:
			air_dir.x = direction.x * SPEED_MULT * AIR_CONTROL
			air_dir.z = direction.z * SPEED_MULT  * AIR_CONTROL
		else:
			air_dir.x = move_toward(air_dir.x, 0, delta/10)
			air_dir.z = move_toward(air_dir.z, 0, delta/10)
		
		# do the fall calculation since we are in air
		var grav = get_gravity().y * delta
		if velocity.y + grav >= -TERMINAL_VELOCITY:
			velocity.y += grav

	# Calculate final velocities
	velocity.x = wish_dir.x + air_dir.x + OUTSIDE_VELOCITY.x
	velocity.z = wish_dir.z + air_dir.z + OUTSIDE_VELOCITY.z

	if input_dir.x > 0:
		head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(-TARGET_SWAY), LERP_SWAY)
	elif input_dir.x < 0:
		head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(TARGET_SWAY), LERP_SWAY)
	else:
		head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(0), LERP_SWAY)
	
	move_and_slide()
