extends Control

@onready var leaderboard_list: VBoxContainer = $VBoxContainer/ScrollContainer/LeaderboardList
@onready var loading_label: Label = $VBoxContainer/LoadingLabel
@onready var error_label: Label = $VBoxContainer/ErrorLabel
@onready var submit_button: Button = $VBoxContainer/ButtonContainer/SubmitScoreButton

var game_scene: Node2D = null

func _ready():
	"""Initialize the leaderboard"""
	_hide_loading()
	_hide_error()
	_load_leaderboard()

func _hide_loading():
	"""Hide the loading label"""
	loading_label.visible = false

func _show_loading():
	"""Show the loading label"""
	loading_label.visible = true
	_hide_error()

func _hide_error():
	"""Hide the error label"""
	error_label.visible = false
	error_label.text = ""

func _show_error(message: String):
	"""Show an error message"""
	error_label.text = message
	error_label.visible = true
	_hide_loading()

func _load_leaderboard():
	"""Load the leaderboard from PlayFab"""
	if not PlayFabManager.client_config.is_logged_in():
		_show_error("Not logged in to PlayFab")
		return
	
	_show_loading()
	_clear_leaderboard()
	
	# Get leaderboard data using PlayFab API
	var request_body = {
		"StatisticName": "HighScore",
		"StartPosition": 0,
		"MaxResultsCount": 10
	}
	
	PlayFabManager.client.post_dict_auth(request_body, "/Client/GetLeaderboard", PlayFab.AUTH_TYPE.SESSION_TICKET, Callable(self, "_on_leaderboard_loaded"))

func _on_leaderboard_loaded(result):
	"""Called when leaderboard data is loaded from PlayFab"""
	_hide_loading()
	
	if result.has("data") and result.data.has("Leaderboard"):
		var leaderboard_data = result.data.Leaderboard
		_populate_leaderboard(leaderboard_data)
	else:
		_show_error("Failed to load leaderboard data")

func _populate_leaderboard(leaderboard_data: Array):
	"""Populate the leaderboard UI with score data"""
	_clear_leaderboard()
	
	if leaderboard_data.is_empty():
		var no_scores_label = Label.new()
		no_scores_label.text = "No scores yet. Be the first to submit!"
		no_scores_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		no_scores_label.add_theme_font_size_override("font_size", 18)
		no_scores_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
		leaderboard_list.add_child(no_scores_label)
		return
	
	for i in range(leaderboard_data.size()):
		var entry = leaderboard_data[i]
		var position = i + 1
		var display_name = entry.get("DisplayName", "Anonymous")
		var score = entry.get("StatValue", 0)
		
		var entry_container = _create_leaderboard_entry(position, display_name, score)
		leaderboard_list.add_child(entry_container)

func _create_leaderboard_entry(position: int, display_name: String, score: int) -> Control:
	"""Create a single leaderboard entry UI element"""
	var entry_container = HBoxContainer.new()
	
	# Position label
	var position_label = Label.new()
	position_label.text = str(position) + "."
	position_label.custom_minimum_size = Vector2(40, 0)
	position_label.add_theme_font_size_override("font_size", 20)
	position_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	entry_container.add_child(position_label)
	
	# Player name label
	var name_label = Label.new()
	name_label.text = display_name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	entry_container.add_child(name_label)
	
	# Score label
	var score_label = Label.new()
	score_label.text = str(score)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.custom_minimum_size = Vector2(80, 0)
	score_label.add_theme_font_size_override("font_size", 20)
	score_label.add_theme_color_override("font_color", Color(1, 1, 0.5, 1))
	entry_container.add_child(score_label)
	
	return entry_container

func _clear_leaderboard():
	"""Clear all leaderboard entries"""
	for child in leaderboard_list.get_children():
		child.queue_free()

func _on_refresh_button_pressed():
	"""Refresh the leaderboard"""
	_load_leaderboard()

func _on_submit_score_button_pressed():
	"""Submit the current game score to the leaderboard"""
	if not PlayFabManager.client_config.is_logged_in():
		_show_error("Not logged in to PlayFab")
		return
	
	# Get the current game score
	var current_score = 0
	if game_scene and game_scene.has_method("get_current_score"):
		current_score = game_scene.get_current_score()
	
	if current_score <= 0:
		_show_error("No score to submit")
		return
	
	# Submit the score
	var request_body = {
		"Statistics": [
			{
				"StatisticName": "HighScore",
				"Value": current_score
			}
		]
	}
	
	PlayFabManager.client.post_dict_auth(request_body, "/Client/UpdatePlayerStatistics", PlayFab.AUTH_TYPE.SESSION_TICKET, Callable(self, "_on_score_submitted"))

func _on_score_submitted(result):
	"""Called when score is successfully submitted"""
	print("Score submitted successfully: ", result)
	_load_leaderboard()  # Refresh the leaderboard

func _on_back_button_pressed():
	"""Return to the game scene"""
	get_tree().change_scene_to_file("res://game.tscn")

func set_game_scene(scene: Node2D):
	"""Set reference to the game scene for score access"""
	game_scene = scene 
