extends Control

# Instructions screen controller script
# Explains how to play the game

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var instructions_text: RichTextLabel = $VBoxContainer/InstructionsText
@onready var back_button: Button = $VBoxContainer/BackButton

func _ready():
	"""Initialize the instructions screen."""
	# Connect button signals
	back_button.pressed.connect(_on_back_pressed)
	
	# Set up the display
	title_label.text = "How to Play"
	
	# Set up the instructions text
	var instructions = """
[center][color=yellow][b]Balloon Warfare[/b][/color][/center]

[b]Objective:[/b]
Pop as many balloons as possible before they escape!

[b]Controls:[/b]
• [color=cyan]Left Click[/color] - Pop balloons
• [color=cyan]ESC[/color] - Pause game / Return to menu
• [color=cyan]Enter[/color] - Confirm selections

[b]Gameplay:[/b]
• Balloons float up from the bottom of the screen
• Click on balloons to pop them and earn points
• Different colored balloons behave the same way
• Wind affects balloon movement
• Game gets harder over time with faster balloons

[b]Health System:[/b]
• You start with 10 health points
• Each balloon that escapes costs 1 health
• Game ends when health reaches 0

[b]Scoring:[/b]
• Each popped balloon = 1 point
• Try to beat your high score!
• Top 10 scores are saved

[b]Tips:[/b]
• Watch for wind effects - balloons drift sideways
• Focus on balloons closest to escaping
• The game gets progressively harder
• Don't let too many balloons escape at once!

[center][color=green]Good luck and have fun![/color][/center]
"""
	
	instructions_text.text = instructions
	
	# Focus the back button by default
	back_button.grab_focus()

func _on_back_pressed():
	"""Handle back button press - return to main menu."""
	GameManager.return_to_main_menu()

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
