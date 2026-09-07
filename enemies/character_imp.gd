extends CharacterBody3D

@onready var nav = $NavigationAgent3D
@onready var parent = $"."
@onready var melee_ray = $melee_ray
var bCanAttack = true
const attack_delay = 2.0
@export var attack_damage = 10

var bHasTarget = false
var current_target_node : Node3D
var current_target_position : Vector3
var SPEED = 3.0

func reset_attack():
	bCanAttack = true
	
func attempt_attack():
	if bCanAttack and melee_ray.is_colliding():
		bCanAttack = false
		get_tree().create_timer(attack_delay).timeout.connect(reset_attack)
		var incoming_target = melee_ray.get_collider()
		if incoming_target.has_method("apply_damage"):
			incoming_target.apply_damage(attack_damage)
			
		# check if player 'died'
		if incoming_target.has_method("get_current_health"):
			if incoming_target.get_current_health() <= 50:
				bHasTarget = false

func get_target_player():
	if !is_multiplayer_authority(): return
	var players = get_tree().get_nodes_in_group("player")
	print(players.size())
	if players.size() > 0:
		bHasTarget = true
		current_target_node = players.pick_random()
	
func _physics_process(_delta: float):
	if !is_multiplayer_authority(): return
	var current_loc = global_transform.origin
	var next_loc = nav.get_next_path_position()
	var new_vel = (next_loc	 - current_loc).normalized() * SPEED
	# update avoidance information
	nav.set_velocity(new_vel)
	
	if bHasTarget and current_target_node:
		update_target_position(current_target_node.global_position)
		parent.look_at(current_target_position, Vector3(0,1,0))
		parent.rotation.x = 0
		parent.rotation.z = 0
	else:
		get_target_player()

func update_target_position(inTarget):
	current_target_position = inTarget
	nav.target_position = current_target_position
	
func _on_navigation_agent_3d_target_reached() -> void:
	#print("imp reached target!")
	attempt_attack()

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity,0.25)
	move_and_slide()
