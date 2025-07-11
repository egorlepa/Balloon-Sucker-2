extends Node2D

@onready var speed_label: Label = $DebugInfo/SpeedLabel
@onready var spawn_interval_label: Label = $DebugInfo/SpawnIntervalLabel
@onready var difficulty_label: Label = $DebugInfo/DifficultyLabel

@onready var health_label: Label = $Health/Label
@onready var score_label: Label = $ScoreLabel

@onready var balloon_timer: Timer = $SpawnTimer

# Game Over Screen
@onready var game_over_screen: GameOverScreen = $GameOverScreen

var elapsed_time := 0.0

var min_interval :=  0.1
var max_interval :=  1.0
var spawn_interval := max_interval

var min_speed := 200.0
var max_speed := 500.0
var speed := min_speed

var Balloon = preload("res://balloon.tscn")

var health = 10
var score = 0

# Leaderboard integration
var leaderboard_manager: LeaderboardManager
var game_over := false

func _ready() -> void:
	health_label.text = str(health)
	score_label.text = str(score)
	randomize()
	balloon_timer.start(spawn_interval)
	_spawn_balloon_batch()
	
	# Initialize leaderboard manager
	_setup_leaderboard()
	
	# Setup game over screen
	_setup_game_over_screen()

## Sets up the leaderboard manager and connects signals
func _setup_leaderboard():
	leaderboard_manager = LeaderboardManager.new()
	add_child(leaderboard_manager)
	
	# Connect to leaderboard signals
	leaderboard_manager.login_completed.connect(_on_login_completed)
	leaderboard_manager.score_submitted.connect(_on_score_submitted)
	leaderboard_manager.leaderboard_received.connect(_on_leaderboard_received)
	leaderboard_manager.leaderboard_error.connect(_on_leaderboard_error)

## Sets up the game over screen and connects signals
func _setup_game_over_screen():
	# Connect game over screen signals
	game_over_screen.restart_requested.connect(_on_restart_requested)
	game_over_screen.quit_requested.connect(_on_quit_requested)

## Called when PlayFab login completes
func _on_login_completed(success: bool):
	if success:
		print("PlayFab login successful! Player: ", leaderboard_manager.player_display_name)
	else:
		print("PlayFab login failed!")

## Called when score is submitted to leaderboard
func _on_score_submitted(success: bool):
	if success:
		print("Score submitted to leaderboard!")
	else:
		print("Failed to submit score to leaderboard")

## Called when leaderboard data is received
func _on_leaderboard_received(entries: Array):
	print("Leaderboard entries received: ", entries.size())
	# The leaderboard UI will handle displaying this data

## Called when leaderboard error occurs
func _on_leaderboard_error(error_message: String):
	print("Leaderboard error: ", error_message)

## Called when restart is requested from game over screen
func _on_restart_requested():
	_restart_game()

## Called when quit is requested from game over screen
func _on_quit_requested():
	get_tree().quit()

@export var difficulty_curve: Curve
var difficulty := 0.0
var max_difficulty_time := 300.0

func _process(delta):
	if game_over:
		return
		
	elapsed_time += delta

	difficulty = difficulty_curve.sample(elapsed_time / max_difficulty_time)
	difficulty_label.text = "Difficulty: %0.2f%%" % (difficulty*100)

	speed = lerp(min_speed, max_speed, difficulty)
	speed_label.text = "Speed: %0.0f" % speed
		
	spawn_interval = lerp(max_interval, min_interval, difficulty)
	spawn_interval_label.text = "Interval: %0.2f" % spawn_interval
	
	balloon_timer.wait_time = spawn_interval

var max_spawn_per_event := 10

func _spawn_balloon_batch():
	if game_over:
		return
		
	var b = Balloon.instantiate()
	add_child(b)
	b.popped.connect(func():
		if not game_over:
			score += 1
			score_label.text = str(score)	
	)

	var viewport_width = get_viewport().get_visible_rect().size.x
	var viewport_height = get_viewport().get_visible_rect().size.y
	var sprite = b.get_node("AnimatedSprite2D") as AnimatedSprite2D
	var texture_size = sprite.sprite_frames.get_frame_texture("pop", 0).get_size()
	var scaled_height = texture_size.y * sprite.scale.y
	var scaled_width = texture_size.x * sprite.scale.x
	var random_x = scaled_width / 2 + randi() % int(viewport_width - scaled_width)

	b.position = Vector2(random_x, viewport_height + scaled_height / 2)

	# Apply jitter to speed
	var jitter = randf_range(0.75, 1.25)
	b.speed = speed * jitter

func _on_spawn_timer_timeout() -> void:
	_spawn_balloon_batch()

func _on_despawn_boundary_area_entered(area: Area2D) -> void:
	if game_over:
		return
		
	health -= 1
	health_label.text = str(health)
	
	var fart := $Fart.duplicate()
	add_child(fart)
	fart.play(0.2)
	fart.finished.connect(func():
		fart.queue_free()
	)
	
	area.get_parent().queue_free()
	if health == 0:
		_game_over()

## Handles game over logic
func _game_over():
	game_over = true
	get_tree().paused = true
	
	print("Game Over! Final Score: ", score)
	
	# Submit score to leaderboard
	if leaderboard_manager and leaderboard_manager.is_logged_in:
		leaderboard_manager.submit_score(score)
	
	# Show game over screen
	game_over_screen.show_game_over(score, leaderboard_manager)

## Restarts the game
func _restart_game():
	game_over = false
	get_tree().paused = false
	
	# Hide game over screen
	game_over_screen.hide_game_over()
	
	# Reset game state
	health = 10
	score = 0
	elapsed_time = 0.0
	difficulty = 0.0
	speed = min_speed
	spawn_interval = max_interval
	
	# Update UI
	health_label.text = str(health)
	score_label.text = str(score)
	
	# Clear existing balloons
	for child in get_children():
		if child.has_method("queue_free") and child != leaderboard_manager and child != game_over_screen:
			if child.name.begins_with("Balloon") or child.name.begins_with("@Balloon"):
				child.queue_free()
	
	# Restart timer
	balloon_timer.start(spawn_interval)

## Add leaderboard button functionality (L key to view leaderboard)
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_L and not game_over:
			if leaderboard_manager:
				# Pause the game
				get_tree().paused = true
				
				# Create a temporary leaderboard UI for in-game viewing
				var temp_leaderboard = preload("res://leaderboard_ui.tscn").instantiate()
				add_child(temp_leaderboard)
				temp_leaderboard.show_leaderboard(leaderboard_manager)
				temp_leaderboard.closed.connect(func():
					# Resume the game when leaderboard is closed
					get_tree().paused = false
					temp_leaderboard.queue_free()
				)
