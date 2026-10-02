extends Control


@onready var main_container = $MainContainer
@onready var options_container = $OptionsContainer
@onready var quit_container = $QuitContainer

func set_container(inContainer) -> void:
	main_container.visible = false
	options_container.visible = false
	quit_container.visible = false
	inContainer.visible = true
	
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/base_level.tscn")

func _on_options_button_pressed() -> void:
	set_container(options_container)
	
func _on_quit_button_pressed() -> void:
	set_container(quit_container)

func _on_exit_game_button_pressed() -> void:
	get_tree().quit()

func _on_back_button_pressed() -> void:
	set_container(main_container)


func _on_fullscreen_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
