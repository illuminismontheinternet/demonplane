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
	
func restart_health():
	health = max_health

func apply_damage(inAmount, inVelocity):
	apply_damage_rpc.rpc(inAmount, inVelocity)

@rpc("any_peer", "call_local", "reliable")
func apply_damage_rpc(inAmount, inVelocity):
	if not multiplayer.is_server(): return
	if health <= 0: return
	print("server: applying damage: ",inAmount )
	health = max(health - inAmount, 0)
	signal_health_changed.emit(inVelocity, health, max_health)
	if health <= 0:
		signal_died.emit()
