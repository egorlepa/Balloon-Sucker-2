extends Control

@onready var final_score_label: Label = $CenterContainer/VBoxContainer/ScoreContainer/FinalScoreLabel
@onready var high_score_label: Label = $CenterContainer/VBoxContainer/ScoreContainer/HighScoreLabel
@onready var new_high_score_label: Label = $CenterContainer/VBoxContainer/ScoreContainer/NewHighScoreLabel

func _ready():
	"""Initialize the game over screen"""
	_display_scores()

func _display_scores():
	"""Display the final score and high score"""
	var final_score = GlobalData.final_score
	var high_score = GlobalData.get_high_score()
	
	# Update labels
	final_score_label.text = "Final Score: " + str(final_score)
	high_score_label.text = "High Score: " + str(high_score)
	
	# Check if this is a new high score
	if final_score > high_score:
		GlobalData.save_high_score(final_score)
		new_high_score_label.visible = true
		high_score_label.text = "High Score: " + str(final_score)
	else:
		new_high_score_label.visible = false

func _on_play_again_button_pressed():
	"""Start a new game"""
	get_tree().change_scene_to_file("res://game.tscn")

func _on_main_menu_button_pressed():
	"""Return to main menu"""
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_leaderboard_button_pressed():
	"""Show leaderboard"""
	get_tree().change_scene_to_file("res://leaderboard.tscn") 
