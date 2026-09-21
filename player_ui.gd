extends Control

@onready var bg_color = $ColorRect
@onready var win = $VBoxContainer/win
@onready var lose = $VBoxContainer/lose
@onready var menu_buttons = $VBoxContainer/MenuOptions

func ui_recieve_match_end(bVictory):
	bg_color.visible = true
	if bVictory:
		win.visible = true
	else:
		lose.visible = true
	await get_tree().create_timer(2).timeout
	menu_buttons.visible = true
	
func _on_back_to_main_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/mainmenu.tscn")


func _on_quit_game_pressed() -> void:
	get_tree().quit()
