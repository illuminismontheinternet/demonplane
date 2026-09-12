extends CharacterBody3D

signal signal_imp_died 

@onready var nav = $NavigationAgent3D
@onready var parent = $"."
@onready var melee_ray = $mesh_parent/melee_ray
@onready var imp_mesh = $mesh_parent

enum IMP_STATE {
	IDLE,
	SEARCHING,
	HUNTING,
	ATTACKING,
	JUMPINGLINK,
	DEAD
}
var current_state = IMP_STATE.IDLE

# act_enemies manager is just parent
var act_enemies : ActEnemies

@export var attack_damage = 10
const attack_delay = 2.0
var bCanAttack = true
var attack_velocity_multiplier = 2.0

var current_target_node : Node3D
var current_target_position : Vector3
var SPEED = 3.0
var new_safe_velocity : Vector3

var target_jump_link : Vector3

# health variables
@onready var health_component = $Health
# WARNING isAlive is used as a 'sleep variable'
var bIsAlive = false

@rpc("any_peer", "call_local", "reliable")
func imp_reset_loc_rpc():
	global_position = act_enemies.get_imp_respawn_loc(0)
	
func imp_hurt(inVelocity, _inHealth, _inMaxHealth):
	#print("imp_hurt")
	velocity += inVelocity

@rpc("any_peer","call_local","reliable")
func imp_die_rpc():
	signal_imp_died.emit()
	current_state = IMP_STATE.DEAD
	bIsAlive = false
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	imp_mesh.rotation.x = deg_to_rad(-85)
	nav.set_velocity(Vector3.ZERO)

func imp_die():
	imp_die_rpc.rpc()
	
func reset_attack():
	bCanAttack = true

func attempt_attack():
	if bIsAlive and bCanAttack and melee_ray.is_colliding():
		bCanAttack = false
		get_tree().create_timer(attack_delay).timeout.connect(reset_attack)
		var incoming_target = melee_ray.get_collider()
		# NOTE: this requires the health on same level as collider
		#print("imp incoming target: ",incoming_target)
		var target_health = incoming_target.get_node_or_null("Health")
		#print("target health: ", target_health)
		if target_health:
			var hurt_velocity = (incoming_target.global_position - parent.global_position).normalized() * attack_velocity_multiplier
			target_health.apply_damage(attack_damage, hurt_velocity)

func get_target_player():
	if !is_multiplayer_authority(): return
	if bIsAlive:
		var players = get_tree().get_nodes_in_group("player")
		#print(players.size())
		if players.size() > 0:
			current_target_node = players.pick_random()#players.get(0)#
			current_state = IMP_STATE.HUNTING

func turn_to_loc(inPosition):
	imp_mesh.look_at(inPosition, Vector3(0,1,0))
	imp_mesh.rotation.x = 0
	imp_mesh.rotation.z = 0
			
func handle_state_machine():
# Handle states
	#print("state: ", current_state)
	match current_state:
		IMP_STATE.IDLE:
			current_state = IMP_STATE.SEARCHING
		IMP_STATE.SEARCHING:
			get_target_player()
		IMP_STATE.HUNTING:
			# Face the target
			if current_target_node:
				update_target_position(current_target_node.global_position)
				turn_to_loc(current_target_position)
			else:
				current_state = IMP_STATE.SEARCHING
			# Move to target
			var current_loc = global_transform.origin
			var next_loc = nav.get_next_path_position()
			var new_vel = (next_loc	 - current_loc).normalized() * SPEED
			# update avoidance information
			nav.set_velocity(new_vel)
			velocity = velocity.move_toward(new_safe_velocity,0.25)
		IMP_STATE.ATTACKING:
			attempt_attack()
			current_state = IMP_STATE.SEARCHING
		IMP_STATE.JUMPINGLINK:
			# Face the target
			update_target_position(current_target_node.global_position)
			turn_to_loc(current_target_position)
			velocity = velocity.move_toward(new_safe_velocity,0.25)
			await get_tree().create_timer(2).timeout
			current_state = IMP_STATE.SEARCHING
		IMP_STATE.DEAD:
			print("IMP DEAD")
			
func _ready() -> void:
	act_enemies = get_parent()
	health_component.signal_died.connect(imp_die)
	health_component.signal_health_changed.connect(imp_hurt)
	
func _physics_process(_delta: float):
	if not is_on_floor():
		velocity.y -= 5.8
		
	if !is_multiplayer_authority(): return
	if bIsAlive:
		handle_state_machine()
		move_and_slide()

func update_target_position(inTarget):
	if !is_multiplayer_authority(): return
	current_target_position = inTarget
	nav.target_position = current_target_position
	
func _on_navigation_agent_3d_target_reached() -> void:
	if !is_multiplayer_authority(): return
	current_state = IMP_STATE.ATTACKING

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if !is_multiplayer_authority(): return
	new_safe_velocity = safe_velocity

func _on_navigation_agent_3d_link_reached(_details: Dictionary) -> void:
	if !is_multiplayer_authority(): return
	current_state = IMP_STATE.JUMPINGLINK
	target_jump_link = _details["link_exit_position"]
