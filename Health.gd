class_name Health
extends Node

signal signal_died
signal signal_restart_health
signal signal_health_changed(outCurrent : float, outMax: float)

@export var max_health : float
var health = 0.0
var bIsDead = false

func _ready() -> void:
	restart_health()

func get_current_health() -> float:
	return health

func restart_health():
	#print("restarting health! id: ", multiplayer.get_unique_id())
	signal_restart_health.emit()
	health = max_health
	bIsDead = false

func apply_damage(inAmount, inVelocity):
	apply_damage_rpc.rpc_id(get_multiplayer_authority(), inAmount, inVelocity)
	
@rpc("any_peer", "call_local", "reliable")
func apply_damage_rpc(inAmount, inVelocity):
	if health <= 0: 
		#print("Health component: already dead on peer id: ", multiplayer.get_unique_id())
		return
	print("server: applying damage: ",inAmount )
	#print("apply_damage_rpc - peer: ", multiplayer.get_unique_id())
	health = max(health - inAmount, 0)
	signal_health_changed.emit(inVelocity, health, max_health)
	if health <= 0:
		bIsDead = true
		signal_died.emit()
