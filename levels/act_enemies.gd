extends Node3D
class_name ActEnemies

const imp_scene = preload("res://enemies/character_imp.tscn")
#TODO move this thing later
@onready var imp_respawn_point = $"../../NetworkManager/ImpRespawnPoint0"

# enemy variables
# TODO convert this into a spread sheet
const max_total_enemies = 15
const min_total_enemies = 9
const max_burst_enemies = 5

var target_enemy_count = 0
var enemies_defeated = 0

var imp_pool = []

func get_imp_respawn_loc() -> Vector3:
	return imp_respawn_point.global_position
	
func on_enemy_defeated():
	enemies_defeated = enemies_defeated + 1
	if enemies_defeated < max_total_enemies and enemies_defeated % max_burst_enemies == 0:
		spawn_burst()
		

# spawns the burst of enemies and add them to the pool for 'recycling'
func spawn_burst():
	if not is_multiplayer_authority(): return
	print("spawn burst enemies!")
	for i in range(max_burst_enemies):
		var new_imp = imp_scene.instantiate()
		add_child(new_imp)
		new_imp.global_position = imp_respawn_point.global_position + Vector3(i,0,0)
		new_imp.bIsAlive = true
		new_imp.signal_imp_died.connect(on_enemy_defeated)
		imp_pool.append(new_imp)
	
func start_enemy_wave():
	if not is_multiplayer_authority(): return
	print("start enemy wave")
	target_enemy_count = randi_range(min_total_enemies, max_total_enemies)
	spawn_burst()
