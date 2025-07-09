extends Node2D

@onready var balloon_timer: Timer = $SpawnTimer
@onready var score_label: Label = $ScoreLabel
@onready var lives_label: Label = $LivesLabel
@onready var pause_menu: Control = $PauseMenu
var spawn_interval := 2.0
var min_interval := 0.5
var interval_decay := 0.01
var elapsed_time := 0.0
var score := 0
var lives := 3
var game_over := false
var is_paused := false

var Balloon = preload("res://balloon.tscn")

func _ready() -> void:
	randomize()
	# Initialize PlayFab with anonymous login
	_login_to_playfab()
	balloon_timer.start(spawn_interval)
	_spawn_balloon()
	_update_score_display()
	_update_lives_display()

	# Hide pause menu initially
	pause_menu.visible = false

func _input(event):
	"""Handle input events"""
	if event.is_action_pressed("ui_cancel") and not game_over:  # ESC key
		_toggle_pause()

func _toggle_pause():
	"""Toggle pause state"""
	is_paused = not is_paused

	if is_paused:
		_pause_game()
	else:
		_resume_game()

func _pause_game():
	"""Pause the game"""
	get_tree().paused = true
	pause_menu.visible = true

func _resume_game():
	"""Resume the game"""
	get_tree().paused = false
	pause_menu.visible = false

func _login_to_playfab():
	"""Login to PlayFab using anonymous authentication"""
	if PlayFabManager.client_config.is_logged_in():
		print("Already logged in to PlayFab")
		return

	# Anonymous login
	PlayFabManager.client.login_anonymous()
	PlayFabManager.client.connect("logged_in", Callable(self, "_on_playfab_logged_in"))

func _on_playfab_logged_in(login_result):
	"""Called when PlayFab login is successful"""
	print("Successfully logged in to PlayFab: ", login_result.PlayFabId)

func _process(delta):
	if game_over or is_paused:
		return

	elapsed_time += delta

	# Decrease interval gradually
	var new_interval = max(min_interval, spawn_interval - elapsed_time * interval_decay)

	# Apply new interval to the timer (next cycle)
	balloon_timer.wait_time = new_interval

func _spawn_balloon():
	if game_over:
		return

	var b = Balloon.instantiate()
	add_child(b)

	# Connect to the balloon's signals
	b.connect("balloon_popped", Callable(self, "_on_balloon_popped"))
	b.connect("balloon_escaped", Callable(self, "_on_balloon_escaped"))

	var viewport_width = get_viewport().get_visible_rect().size.x
	var viewport_height = get_viewport().get_visible_rect().size.y
	var random_x = randi() % int(viewport_width)
	var sprite = b.get_node("Sprite2D")
	var texture_size = sprite.texture.get_size()
	var scaled_height = texture_size.y * sprite.scale.y

	b.position = Vector2(random_x, viewport_height+scaled_height/2)
	b.speed = 50.0

func _on_balloon_popped():
	"""Called when a balloon is successfully popped"""
	if game_over:
		return
	score += 10
	_update_score_display()

func _on_balloon_escaped():
	"""Called when a balloon escapes off the screen"""
	if game_over:
		return
	lives -= 1
	_update_lives_display()

	if lives <= 0:
		_trigger_game_over()

func _trigger_game_over():
	"""Trigger game over state"""
	game_over = true
	balloon_timer.stop()

	# Submit final score
	submit_score_to_leaderboard()

	# Show game over screen after a short delay
	await get_tree().create_timer(1.0).timeout
	_show_game_over_screen()

func _show_game_over_screen():
	"""Show the game over screen"""
	# Store the final score in a global variable or pass it to the game over scene
	GlobalData.final_score = score
	get_tree().change_scene_to_file("res://game_over.tscn")

func _update_score_display():
	"""Update the score label"""
	if score_label:
		score_label.text = "Score: " + str(score)

func _update_lives_display():
	"""Update the lives label"""
	if lives_label:
		lives_label.text = "Lives: " + str(lives)

func get_current_score() -> int:
	"""Get the current score"""
	return score

func submit_score_to_leaderboard():
	"""Submit the current score to PlayFab leaderboard"""
	if not PlayFabManager.client_config.is_logged_in():
		print("Not logged in to PlayFab")
		return

	# Submit score using PlayFab UpdatePlayerStatistics
	var request_body = {
		"Statistics": [
			{
				"StatisticName": "HighScore",
				"Value": score
			}
		]
	}

	PlayFabManager.client.post_dict_auth(request_body, "/Client/UpdatePlayerStatistics", PlayFab.AUTH_TYPE.SESSION_TICKET, Callable(self, "_on_score_submitted"))

func _on_score_submitted(result):
	"""Called when score is successfully submitted to PlayFab"""
	print("Score submitted successfully: ", result)

func _on_spawn_timer_timeout() -> void:
	_spawn_balloon()

func _on_leaderboard_button_pressed():
	"""Navigate to the leaderboard scene"""
	get_tree().change_scene_to_file("res://leaderboard.tscn")

func _on_submit_score_button_pressed():
	"""Submit the current score to the leaderboard"""
	submit_score_to_leaderboard()

func _on_menu_button_pressed():
	"""Return to main menu"""
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_pause_resume_pressed():
	"""Resume game from pause menu"""
	_toggle_pause()

func _on_pause_menu_pressed():
	"""Go to main menu from pause menu"""
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_pause_restart_pressed():
	"""Restart game from pause menu"""
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game.tscn")
