extends WorldEnvironment

func SetDaytime() -> void:
	print("SetDaytime")
	
func SetNighttime() -> void:
	print("SetNighttime")
	
func SetOutdoors() -> void:
	print("outdoor lighting active")
	get_viewport().get_camera_3d().environment.volumetric_fog_enabled = true
	
func SetIndoors() -> void:
	print("indoor lighting active")
	get_viewport().get_camera_3d().environment.volumetric_fog_enabled = false

func _on_plane_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("player_die"):
		SetIndoors()

func _on_plane_area_3d_body_exited(body: Node3D) -> void:
	if body.has_method("player_die"):
		SetOutdoors()
