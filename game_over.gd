extends Control

# Game Over screen controller script
# Displays final score, high score status, and provides restart/menu options

@onready var game_over_label: Label = $VBoxContainer/GameOverLabel
@onready var final_score_label: Label = $VBoxContainer/FinalScoreLabel
@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel
@onready var new_high_score_label: Label = $VBoxContainer/NewHighScoreLabel

@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var main_menu_button: Button = $VBoxContainer/MainMenuButton

var is_new_high_score: bool = false

func _ready():
	"""Initialize the game over screen."""
	# Connect button signals
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# Set up the display
	game_over_label.text = "Game Over!"
	final_score_label.text = "Final Score: " + str(GameManager.current_score)
	
	# Check if this is a new high score
	var high_scores = GameManager.get_high_scores()
	if high_scores.size() > 0:
		high_score_label.text = "High Score: " + str(high_scores[0])
		is_new_high_score = GameManager.current_score > 0 and (high_scores.size() == 0 or GameManager.current_score >= high_scores[0])
	else:
		high_score_label.text = "High Score: 0"
		is_new_high_score = GameManager.current_score > 0
	
	# Show new high score message if applicable
	if is_new_high_score:
		new_high_score_label.text = "NEW HIGH SCORE!"
		new_high_score_label.modulate = Color.YELLOW
		new_high_score_label.visible = true
		_animate_new_high_score()
	else:
		new_high_score_label.visible = false
	
	# Focus the restart button by default
	restart_button.grab_focus()

func _animate_new_high_score():
	"""Animate the new high score label."""
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(new_high_score_label, "modulate", Color.RED, 0.5)
	tween.tween_property(new_high_score_label, "modulate", Color.YELLOW, 0.5)

func _on_restart_pressed():
	"""Handle restart button press - start a new game."""
	GameManager.restart_game()

func _on_main_menu_pressed():
	"""Handle main menu button press - return to main menu."""
	GameManager.return_to_main_menu()

func _input(event):
	"""Handle input events."""
	if event.is_action_pressed("ui_cancel"):
		# ESC key returns to main menu
		_on_main_menu_pressed()
	elif event.is_action_pressed("ui_accept"):
		# Enter key restarts the game
		if restart_button.has_focus():
			_on_restart_pressed()

# Visual effects for buttons
func _on_restart_button_mouse_entered():
	"""Handle restart button hover effect."""
	var tween = create_tween()
	tween.tween_property(restart_button, "modulate", Color.GREEN, 0.1)

func _on_restart_button_mouse_exited():
	"""Handle restart button hover exit effect."""
	var tween = create_tween()
	tween.tween_property(restart_button, "modulate", Color.WHITE, 0.1)

func _on_main_menu_button_mouse_entered():
	"""Handle main menu button hover effect."""
	var tween = create_tween()
	tween.tween_property(main_menu_button, "modulate", Color.CYAN, 0.1)

func _on_main_menu_button_mouse_exited():
	"""Handle main menu button hover exit effect."""
	var tween = create_tween()
	tween.tween_property(main_menu_button, "modulate", Color.WHITE, 0.1) 
