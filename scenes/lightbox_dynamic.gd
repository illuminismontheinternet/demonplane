extends CSGBox3D

@export var bIsUnique = false
@export var start_color := Color.ORANGE_RED
@export var start_temp := 2200
@onready var current_light = $SpotLight3D
@onready var current_box = $"."

var custom_mat = StandardMaterial3D

func _ready() -> void:
	if bIsUnique:
		custom_mat = current_box.material.duplicate()
		current_box.material = custom_mat
	current_light.light_temperature = start_temp
	current_box.material.emission = start_color

func _change_light(inColor):
	current_light.light_color = inColor
	current_box.material.emission = inColor
