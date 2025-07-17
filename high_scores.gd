extends Control

# High Scores screen controller script
# Displays the top high scores

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var scores_container: VBoxContainer = $VBoxContainer/ScoresContainer
@onready var back_button: Button = $VBoxContainer/BackButton
@onready var clear_scores_button: Button = $VBoxContainer/ClearScoresButton

func _ready():
	"""Initialize the high scores screen."""
	# Connect button signals
	back_button.pressed.connect(_on_back_pressed)
	clear_scores_button.pressed.connect(_on_clear_scores_pressed)
	
	# Set up the display
	title_label.text = "High Scores"
	
	# Display the high scores
	_display_high_scores()
	
	# Focus the back button by default
	back_button.grab_focus()

func _display_high_scores():
	"""Display the high scores in the container."""
	# Clear existing score labels
	for child in scores_container.get_children():
		child.queue_free()
	
	# Get high scores from GameManager
	var high_scores = GameManager.get_high_scores()
	
	if high_scores.size() == 0:
		# No scores yet
		var no_scores_label = Label.new()
		no_scores_label.text = "No high scores yet!"
		no_scores_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		no_scores_label.add_theme_color_override("font_color", Color.GRAY)
		scores_container.add_child(no_scores_label)
	else:
		# Display each high score
		for i in range(high_scores.size()):
			var score_label = Label.new()
			score_label.text = str(i + 1) + ". " + str(high_scores[i])
			score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			
			# Color the top 3 scores differently
			if i == 0:
				score_label.add_theme_color_override("font_color", Color.GOLD)
			elif i == 1:
				score_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
			elif i == 2:
				score_label.add_theme_color_override("font_color", Color(0.8, 0.5, 0.2))  # Bronze color
			else:
				score_label.add_theme_color_override("font_color", Color.WHITE)
			
			scores_container.add_child(score_label)

func _on_back_pressed():
	"""Handle back button press - return to main menu."""
	GameManager.return_to_main_menu()

func _on_clear_scores_pressed():
	"""Handle clear scores button press - clear all high scores."""
	# Show confirmation dialog
	var dialog = AcceptDialog.new()
	dialog.dialog_text = "Are you sure you want to clear all high scores?"
	dialog.title = "Clear High Scores"
	
	var cancel_button = dialog.add_cancel_button("Cancel")
	
	add_child(dialog)
	dialog.confirmed.connect(_clear_high_scores)
	dialog.popup_centered()

func _clear_high_scores():
	"""Clear all high scores."""
	GameManager.high_scores.clear()
	GameManager.save_high_scores()
	_display_high_scores()

func _input(event):
	"""Handle input events."""
	if event.is_action_pressed("ui_cancel"):
		# ESC key returns to main menu
		_on_back_pressed()

# Visual effects for buttons
func _on_back_button_mouse_entered():
	"""Handle back button hover effect."""
	var tween = create_tween()
	tween.tween_property(back_button, "modulate", Color.CYAN, 0.1)

func _on_back_button_mouse_exited():
	"""Handle back button hover exit effect."""
	var tween = create_tween()
	tween.tween_property(back_button, "modulate", Color.WHITE, 0.1)

func _on_clear_scores_button_mouse_entered():
	"""Handle clear scores button hover effect."""
	var tween = create_tween()
	tween.tween_property(clear_scores_button, "modulate", Color.RED, 0.1)

func _on_clear_scores_button_mouse_exited():
	"""Handle clear scores button hover exit effect."""
	var tween = create_tween()
	tween.tween_property(clear_scores_button, "modulate", Color.WHITE, 0.1) 
