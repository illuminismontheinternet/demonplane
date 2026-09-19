extends Node3D

@onready var main_island = $island01
@onready var bg_island_02 = $island02
@onready var bg_island_03 = $island03

#@rpc("any_peer", "call_local","reliable")
func set_islands_visible(inVis : bool) -> void:
	main_island.visible = inVis
	bg_island_02.visible = inVis
	bg_island_03.visible = inVis

func start_island_minigame() -> void:
	set_islands_visible(true)
	if not is_multiplayer_authority(): return
	print("island mini game starting")

func _ready() -> void:
	set_islands_visible(true)
