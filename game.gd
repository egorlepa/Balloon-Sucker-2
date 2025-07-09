extends Node2D

@onready var balloon_timer: Timer = $SpawnTimer
@onready var score_label: Label = $ScoreLabel
var spawn_interval := 2.0
var min_interval := 0.5
var interval_decay := 0.01
var elapsed_time := 0.0
var score := 0

var Balloon = preload("res://balloon.tscn")

func _ready() -> void:
	randomize()
	# Initialize PlayFab with anonymous login
	_login_to_playfab()
	balloon_timer.start(spawn_interval)
	_spawn_balloon()
	_update_score_display()

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
	elapsed_time += delta

	# Decrease interval gradually
	var new_interval = max(min_interval, spawn_interval - elapsed_time * interval_decay)

	# Apply new interval to the timer (next cycle)
	balloon_timer.wait_time = new_interval

func _spawn_balloon():
	var b = Balloon.instantiate()
	add_child(b)
	
	# Connect to the balloon's destruction signal
	b.connect("balloon_popped", Callable(self, "_on_balloon_popped"))
	
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
	score += 10
	_update_score_display()

func _update_score_display():
	"""Update the score label"""
	if score_label:
		score_label.text = "Score: " + str(score)

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
