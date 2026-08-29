extends CSGBox3D

@onready var current_light = $SpotLight3D
@onready var current_box = $"."

func _change_light(inColor):
	current_light.light_color = inColor
	current_box.get_material(0).emission = inColor
