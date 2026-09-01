extends Control

@onready var bg_color = $ColorRect
@onready var win = $win
@onready var lose = $lose

func ui_recieve_match_end(bVictory):
	bg_color.visible = true
	if bVictory:
		win.visible = true
	else:
		lose.visible = true
	
