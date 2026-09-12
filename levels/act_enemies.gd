extends Node3D
class_name ActEnemies

@onready var multiplayer_spawner = $EnemySpawner
@onready var network_manager = $"../../NetworkManager"

const imp_scene = preload("res://enemies/character_imp.tscn")
#TODO move this thing later
@onready var imp_respawn_point0 = $ImpRespawnPoint0
@onready var imp_respawn_point1 = $ImpRespawnPoint1

# enemy variables
# TODO convert this into a spread sheet
const max_total_enemies = 15
const min_total_enemies = 9
const max_burst_enemies = 5

var target_enemy_count = 0
var enemies_defeated = 0

var imp_pool = []

func get_imp_respawn_loc(inSelection) -> Vector3:
	if inSelection == 0:
		return imp_respawn_point0.global_position
	else:
		return imp_respawn_point1.global_position
	
func on_enemy_defeated():
	if not is_multiplayer_authority(): return
	enemies_defeated = enemies_defeated + 1
	if enemies_defeated < max_total_enemies and enemies_defeated % max_burst_enemies == 0:
		spawn_burst()
		
func spawn_imp(inIteration) -> Node:
	var new_imp = imp_scene.instantiate()
	add_child(new_imp, true)
	new_imp.global_position = get_imp_respawn_loc(0) + Vector3(inIteration,0,0)
	new_imp.bIsAlive = true
	new_imp.signal_imp_died.connect(on_enemy_defeated)
	imp_pool.append(new_imp)
	return new_imp
	
# spawns the burst of enemies and add them to the pool for 'recycling'
func spawn_burst():
	for i in range(max_burst_enemies):
		spawn_imp(i)

func start_enemy_wave():
	if !is_multiplayer_authority(): return
	target_enemy_count = randi_range(min_total_enemies, max_total_enemies)
	spawn_burst()
