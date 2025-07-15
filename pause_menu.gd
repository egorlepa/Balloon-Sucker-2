extends Control

# Pause Menu controller script
# Handles pause menu functionality during gameplay

@onready var pause_label: Label = $VBoxContainer/PauseLabel
@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var main_menu_button: Button = $VBoxContainer/MainMenuButton

func _ready():
	"""Initialize the pause menu."""
	# Connect button signals
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# Set up the display
	pause_label.text = "Game Paused"
	
	# Focus the resume button by default
	resume_button.grab_focus()
	
	# Connect to GameManager signals
	GameManager.game_resumed.connect(_on_game_resumed)

func _on_resume_pressed():
	"""Handle resume button press - resume the game."""
	GameManager.resume_game()

func _on_restart_pressed():
	"""Handle restart button press - restart the game."""
	GameManager.restart_game()

func _on_main_menu_pressed():
	"""Handle main menu button press - return to main menu."""
	GameManager.return_to_main_menu()

func _on_game_resumed():
	"""Handle game resumed signal - hide pause menu."""
	visible = false

func _input(event):
	"""Handle input events."""
	if event.is_action_pressed("ui_cancel"):
		# ESC key resumes the game
		_on_resume_pressed()
	elif event.is_action_pressed("ui_accept"):
		# Enter key acts on focused button
		if resume_button.has_focus():
			_on_resume_pressed()

# Visual effects for buttons
func _on_resume_button_mouse_entered():
	"""Handle resume button hover effect."""
	var tween = create_tween()
	tween.tween_property(resume_button, "modulate", Color.GREEN, 0.1)

func _on_resume_button_mouse_exited():
	"""Handle resume button hover exit effect."""
	var tween = create_tween()
	tween.tween_property(resume_button, "modulate", Color.WHITE, 0.1)

func _on_restart_button_mouse_entered():
	"""Handle restart button hover effect."""
	var tween = create_tween()
	tween.tween_property(restart_button, "modulate", Color.ORANGE, 0.1)

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
