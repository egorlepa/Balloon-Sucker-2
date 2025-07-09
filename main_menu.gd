extends Control

@onready var high_score_label: Label = $VBoxContainer/TitleContainer/HighScoreLabel

func _ready():
	"""Initialize the main menu and PlayFab"""
	# Initialize PlayFab with anonymous login
	_initialize_playfab()
	
	# Update high score display
	_update_high_score_display()

func _update_high_score_display():
	"""Update the high score label"""
	var high_score = GlobalData.get_high_score()
	high_score_label.text = "High Score: " + str(high_score)

func _initialize_playfab():
	"""Initialize PlayFab connection"""
	if not PlayFabManager.client_config.is_logged_in():
		print("Initializing PlayFab connection...")
		PlayFabManager.client.login_anonymous()
		PlayFabManager.client.connect("logged_in", Callable(self, "_on_playfab_logged_in"))
	else:
		print("Already logged in to PlayFab")

func _on_playfab_logged_in(login_result):
	"""Called when PlayFab login is successful"""
	print("PlayFab initialized successfully: ", login_result.PlayFabId)

func _on_play_button_pressed():
	"""Start the game"""
	get_tree().change_scene_to_file("res://game.tscn")

func _on_leaderboard_button_pressed():
	"""Show the leaderboard"""
	get_tree().change_scene_to_file("res://leaderboard.tscn")

func _on_quit_button_pressed():
	"""Quit the game"""
	get_tree().quit() 
