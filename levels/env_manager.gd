extends WorldEnvironment

func SetDaytime() -> void:
	print("SetDaytime")
	
func SetNighttime() -> void:
	print("SetNighttime")

func SetLobbyMode(inCam : Camera3D) -> void:
	inCam.environment = inCam.environment.duplicate()
	inCam.environment.volumetric_fog_enabled = false
	inCam.environment.ambient_light_energy = 1.0
	inCam.environment.ambient_light_sky_contribution = 1.0
	
func SetOutdoors(inCam : Camera3D) -> void:
	#print("outdoor lighting active")
	inCam.environment = inCam.environment.duplicate()
	inCam.environment.volumetric_fog_enabled = true
	
func SetIndoors(inCam : Camera3D) -> void:
	#print("indoor lighting active")
	inCam.environment = inCam.environment.duplicate()
	inCam.environment.volumetric_fog_enabled = false

func _on_plane_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("player_die"):
		SetIndoors(body.get_player_camera())

func _on_plane_area_3d_body_exited(body: Node3D) -> void:
	if body.has_method("player_die"):
		SetOutdoors(body.get_player_camera())

func _on_lobby_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("player_die"):
		SetLobbyMode(body.get_player_camera())
