extends Control

## Game Over Screen displays final score and leaderboard
class_name GameOverScreen

# UI nodes
@onready var game_over_label: Label = $Panel/VBoxContainer/GameOverLabel
@onready var final_score_label: Label = $Panel/VBoxContainer/FinalScoreLabel
@onready var personal_best_label: Label = $Panel/VBoxContainer/PersonalBestLabel
@onready var leaderboard_ui: LeaderboardUI = $Panel/VBoxContainer/LeaderboardContainer/LeaderboardUI
@onready var restart_button: Button = $Panel/VBoxContainer/ButtonContainer/RestartButton
@onready var view_leaderboard_button: Button = $Panel/VBoxContainer/ButtonContainer/ViewLeaderboardButton
@onready var quit_button: Button = $Panel/VBoxContainer/ButtonContainer/QuitButton

# Game data
var final_score: int = 0
var personal_best: int = 0
var leaderboard_manager: LeaderboardManager

# Signals
signal restart_requested()
signal quit_requested()

func _ready():
	# Connect button signals
	restart_button.pressed.connect(_on_restart_pressed)
	view_leaderboard_button.pressed.connect(_on_view_leaderboard_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Hide initially
	visible = false
	
	# Setup UI
	_setup_ui()

## Sets up the UI appearance
func _setup_ui():
	# Configure the panel
	var panel = $Panel
	panel.custom_minimum_size = Vector2(800, 600)
	
	# Center the panel
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	# Hide leaderboard initially
	leaderboard_ui.visible = false

## Shows the game over screen with the final score
func show_game_over(score: int, manager: LeaderboardManager):
	final_score = score
	leaderboard_manager = manager
	
	# Update UI
	final_score_label.text = "Final Score: " + str(final_score)
	
	# Check if it's a new personal best
	_check_personal_best()
	
	# Show the screen
	visible = true
	
	# Focus on restart button
	restart_button.grab_focus()

## Checks if the current score is a personal best
func _check_personal_best():
	if leaderboard_manager:
		# Request personal best (this is a simplified approach)
		# In a real implementation, you'd want to track this properly
		personal_best_label.text = "Check leaderboard to see your ranking!"
		personal_best_label.visible = true

## Hides the game over screen
func hide_game_over():
	visible = false
	leaderboard_ui.hide_leaderboard()

## Called when restart button is pressed
func _on_restart_pressed():
	hide_game_over()
	emit_signal("restart_requested")

## Called when view leaderboard button is pressed
func _on_view_leaderboard_pressed():
	if leaderboard_manager:
		leaderboard_ui.show_leaderboard(leaderboard_manager)

## Called when quit button is pressed
func _on_quit_pressed():
	emit_signal("quit_requested")

## Handle input for quick restart
func _input(event):
	if visible and event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			_on_restart_pressed()
		elif event.keycode == KEY_ESCAPE:
			hide_game_over() 
