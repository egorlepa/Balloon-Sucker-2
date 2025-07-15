extends Control

# Main Menu controller script
# Handles navigation between different menu screens

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var high_scores_button: Button = $VBoxContainer/HighScoresButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

@onready var title_label: Label = $TitleLabel
@onready var version_label: Label = $VersionLabel

func _ready():
	"""Initialize the main menu."""
	# Connect button signals
	play_button.pressed.connect(_on_play_pressed)
	high_scores_button.pressed.connect(_on_high_scores_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Set up the UI
	title_label.text = "Balloon Warfare"
	version_label.text = "v1.0"
	
	# Focus the play button by default
	play_button.grab_focus()
	
	# Display current high score if available
	var high_score = GameManager.get_high_score()
	if high_score > 0:
		high_scores_button.text = "High Scores (" + str(high_score) + ")"

func _on_play_pressed():
	"""Handle play button press - start new game."""
	GameManager.start_new_game()

func _on_high_scores_pressed():
	"""Handle high scores button press - show high scores."""
	GameManager.change_scene("res://high_scores.tscn")

func _on_quit_pressed():
	"""Handle quit button press - exit game."""
	get_tree().quit()

func _input(event):
	"""Handle input events."""
	if event.is_action_pressed("ui_cancel"):
		# ESC key quits from main menu
		get_tree().quit()
	elif event.is_action_pressed("ui_accept"):
		# Enter key starts the game
		if play_button.has_focus():
			_on_play_pressed()

# Animation helpers for smooth transitions
func _on_button_mouse_entered(button: Button):
	"""Handle button hover effects."""
	var tween = create_tween()
	tween.tween_property(button, "modulate", Color.YELLOW, 0.1)

func _on_button_mouse_exited(button: Button):
	"""Handle button hover exit effects."""
	var tween = create_tween()
	tween.tween_property(button, "modulate", Color.WHITE, 0.1)

func _on_button_pressed_effect(button: Button):
	"""Handle button press visual effects."""
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.05) 
