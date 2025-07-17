extends Control

# Pause Menu controller script
# Handles pause menu functionality during gameplay

@onready var pause_label: Label = $VBoxContainer/PauseLabel
@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var main_menu_button: Button = $VBoxContainer/MainMenuButton

var background_panel: Panel

func _ready():
	"""Initialize the pause menu."""
	# Connect button signals
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# Set up the display
	pause_label.text = "Game Paused"
	
	# Make buttons match main menu style
	_setup_button_styles()
	
	# Focus the resume button by default
	resume_button.grab_focus()
	
	# Connect to GameManager signals
	GameManager.game_resumed.connect(_on_game_resumed)
	
	# Make this control fill the entire screen as an overlay
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Create a semi-transparent background panel
	background_panel = Panel.new()
	background_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background_panel.modulate = Color(0, 0, 0, 0.7)  # Dark semi-transparent background
	background_panel.mouse_filter = Control.MOUSE_FILTER_STOP  # Block mouse events
	add_child(background_panel)
	move_child(background_panel, 0)  # Put it behind other elements
	
	# Style the existing pause label to match main menu title
	pause_label.add_theme_font_size_override("font_size", 48)
	pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Center the VBoxContainer to match main menu layout
	if $VBoxContainer:
		$VBoxContainer.set_anchors_preset(Control.PRESET_CENTER)
		$VBoxContainer.set_offsets_preset(Control.PRESET_CENTER)
		
		# Match main menu spacing and sizing
		$VBoxContainer.add_theme_constant_override("separation", 20)

func _on_resume_pressed():
	"""Handle resume button press - resume the game."""
	GameManager.resume_game()

func _on_restart_pressed():
	"""Handle restart button press - restart the game."""
	# Clean up the pause menu before restarting
	queue_free()
	GameManager.restart_game()

func _on_main_menu_pressed():
	"""Handle main menu button press - return to main menu."""
	# Clean up the pause menu before returning
	queue_free()
	GameManager.return_to_main_menu()

func _on_game_resumed():
	"""Handle game resumed signal - hide pause menu."""
	visible = false


func _setup_button_styles():
	"""Set up button styles to match main menu."""
	var buttons = [resume_button, restart_button, main_menu_button]
	for button in buttons:
		if button:
			# Match main menu button sizing and spacing
			button.custom_minimum_size = Vector2(200, 50)
			# Connect hover effects
			button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
			button.mouse_exited.connect(_on_button_mouse_exited.bind(button))
			button.pressed.connect(_on_button_pressed_effect.bind(button))

func _input(event):
	"""Handle input events."""
	if event.is_action_pressed("ui_cancel"):
		# ESC key resumes the game
		_on_resume_pressed()
	elif event.is_action_pressed("ui_accept"):
		# Enter key acts on focused button
		if resume_button.has_focus():
			_on_resume_pressed()

# Visual effects for buttons - match main menu style
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
