extends CharacterBody3D

@onready var head = $neck/head
@onready var body = $"."
@onready var camera = $neck/head/Camera3D
@onready var wep_parent = $neck/head/Camera3D/weapon

@onready var melee_parent = $neck/head/Camera3D/weapon/melee
@onready var wep_wrench = $neck/head/Camera3D/weapon/melee/wrench
@onready var melee_ray = $neck/head/Camera3D/weapon/melee_ray

# ui elements
@onready var hud_manager = $player_ui

# viewbob constants
const viewbob_const = 0.05
var target_melee_basis = Basis.IDENTITY
const melee_rand_pos = 1.0

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

func _show_end_screen(bVictory):
	hud_manager.ui_recieve_match_end(bVictory)
		
func _handle_weapon_input():
	if Input.is_action_just_pressed("attack"):
		_action_swing_melee()
		
func _action_swing_melee():
	var rand_rot := Vector3(
		randf_range(-melee_rand_pos, -melee_rand_pos/2),
		randf_range(melee_rand_pos*0.75, melee_rand_pos),
		randf_range(0, 0),
	)
	target_melee_basis = Basis.from_euler(rand_rot)
	# attempt fix
	if melee_ray.is_colliding():
		var current_interactable = melee_ray.get_collider()
		current_interactable.attempt_repair()
	
func _handle_melee_reset(delta):
	var t = delta * 10
	melee_parent.basis = melee_parent.basis.slerp(target_melee_basis,t*2)
	target_melee_basis = target_melee_basis.slerp(Basis.IDENTITY,t)
		
func _handle_movebob():
	wep_parent.position.y = sin(position.x) * viewbob_const
	wep_parent.position.x = sin(position.z) * viewbob_const
	
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
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion:
		_rotate_look(event.relative.x, event.relative.y)

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	
func _ready():
	if not is_multiplayer_authority(): return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = true
		
func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
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
	_handle_weapon_input()
	_handle_melee_reset(delta)
	_handle_movebob()
	move_and_slide()

func _on_level_match_finished(bVictory: bool) -> void:
	_show_end_screen(bVictory)
