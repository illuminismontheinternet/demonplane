class_name Health
extends Node

signal signal_died
signal signal_health_changed(outCurrent : float, outMax: float)

@export var max_health : float = 100.0
var health = max_health

func _ready() -> void:
	restart_health()

func get_current_health() -> float:
	return health
	
@rpc("any_peer", "call_local","reliable")
func restart_health_rpc():
	health = max_health
	
func restart_health():
	restart_health_rpc.rpc()

func apply_damage(inAmount, inVelocity):
	apply_damage_rpc.rpc_id(get_multiplayer_authority(), inAmount, inVelocity)
	#apply_damage_rpc(inAmount, inVelocity)
	
@rpc("any_peer", "call_local","reliable")
func apply_damage_rpc(inAmount, inVelocity):
	#if not multiplayer.is_server(): return
	if health <= 0: 
		print("Health component: already dead on peer id: ", multiplayer.get_unique_id())
		return
	#print("server: applying damage: ",inAmount )
	print("apply_damage_rpc - peer: ", multiplayer.get_unique_id())
	health = max(health - inAmount, 0)
	signal_health_changed.emit(inVelocity, health, max_health)
	if health <= 0:
		signal_died.emit()
