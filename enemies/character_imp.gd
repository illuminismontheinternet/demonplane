extends CharacterBody3D

@onready var nav = $NavigationAgent3D
@onready var parent = $"."
@onready var melee_ray = $mesh_parent/melee_ray
@onready var imp_mesh = $mesh_parent

var bCanAttack = true
const attack_delay = 2.0
@export var attack_damage = 10
var attack_velocity_multiplier = 2.0

var bHasTarget = false
var current_target_node : Node3D
var current_target_position : Vector3
var SPEED = 3.0

# health variables
@onready var health_component = $Health
var bIsAlive = true

func imp_hurt(inVelocity, _inHealth, _inMaxHealth):
	#print("imp_hurt")
	velocity += inVelocity
	
func imp_die():
	bIsAlive = false
	imp_mesh.rotation.x = -85
	nav.set_velocity(Vector3.ZERO)
	
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
		if players.size() > 1:
			bHasTarget = true
			current_target_node = players.get(1)#players.pick_random()

func _ready() -> void:
	health_component.signal_died.connect(imp_die)
	health_component.signal_health_changed.connect(imp_hurt)
	
func _physics_process(_delta: float):
	if not is_on_floor():
		velocity.y -= 9.8
		
	if !is_multiplayer_authority(): return
	if bIsAlive:
		var current_loc = global_transform.origin
		var next_loc = nav.get_next_path_position()
		var new_vel = (next_loc	 - current_loc).normalized() * SPEED
		# update avoidance information
		nav.set_velocity(new_vel)
		
		if bHasTarget and current_target_node:
			update_target_position(current_target_node.global_position)
			imp_mesh.look_at(current_target_position, Vector3(0,1,0))
			imp_mesh.rotation.x = 0
			imp_mesh.rotation.z = 0
		else:
			get_target_player()

func update_target_position(inTarget):
	current_target_position = inTarget
	nav.target_position = current_target_position
	
func _on_navigation_agent_3d_target_reached() -> void:
	attempt_attack()

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity,0.25)
	move_and_slide()
