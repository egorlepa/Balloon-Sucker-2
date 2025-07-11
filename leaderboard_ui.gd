extends Control

## LeaderboardUI displays the leaderboard data in a nice UI
class_name LeaderboardUI

# UI nodes
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var loading_label: Label = $Panel/VBoxContainer/LoadingLabel
@onready var entries_container: VBoxContainer = $Panel/VBoxContainer/ScrollContainer/VBoxContainer
@onready var close_button: Button = $Panel/VBoxContainer/ButtonContainer/CloseButton
@onready var refresh_button: Button = $Panel/VBoxContainer/ButtonContainer/RefreshButton
@onready var scroll_container: ScrollContainer = $Panel/VBoxContainer/ScrollContainer

# Leaderboard data
var leaderboard_manager: LeaderboardManager
var leaderboard_entries: Array = []

# Signals
signal closed()

func _ready():
	# Connect button signals
	close_button.pressed.connect(_on_close_pressed)
	refresh_button.pressed.connect(_on_refresh_pressed)

	# Allow processing when game is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	# Hide initially
	visible = false

	# Setup UI
	_setup_ui()

## Sets up the UI appearance
func _setup_ui():
	# Configure the panel to fill the screen
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Configure the panel
	var panel = $Panel
	panel.custom_minimum_size = Vector2(600, 500)

	# Center the panel properly
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)

	# Make sure the loading label is visible initially
	loading_label.text = "Loading leaderboard..."
	loading_label.visible = true
	entries_container.visible = false

## Shows the leaderboard UI
func show_leaderboard(manager: LeaderboardManager):
	leaderboard_manager = manager
	visible = true

	# Connect to leaderboard manager signals
	if leaderboard_manager:
		leaderboard_manager.leaderboard_received.connect(_on_leaderboard_received)
		leaderboard_manager.leaderboard_error.connect(_on_leaderboard_error)

		# Request leaderboard data
		_refresh_leaderboard()

## Hides the leaderboard UI
func hide_leaderboard():
	visible = false

	# Disconnect signals
	if leaderboard_manager:
		if leaderboard_manager.leaderboard_received.is_connected(_on_leaderboard_received):
			leaderboard_manager.leaderboard_received.disconnect(_on_leaderboard_received)
		if leaderboard_manager.leaderboard_error.is_connected(_on_leaderboard_error):
			leaderboard_manager.leaderboard_error.disconnect(_on_leaderboard_error)

	emit_signal("closed")

## Called when leaderboard data is received
func _on_leaderboard_received(entries: Array):
	leaderboard_entries = entries
	_display_leaderboard_entries()

## Called when leaderboard error occurs
func _on_leaderboard_error(error_message: String):
	loading_label.text = "Error loading leaderboard: " + error_message
	loading_label.visible = true
	entries_container.visible = false

## Displays the leaderboard entries in the UI
func _display_leaderboard_entries():
	# Clear existing entries
	for child in entries_container.get_children():
		child.queue_free()

	# Hide loading label
	loading_label.visible = false
	entries_container.visible = true

	if leaderboard_entries.is_empty():
		var no_entries_label = Label.new()
		no_entries_label.text = "No entries yet. Be the first to set a high score!"
		no_entries_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		no_entries_label.add_theme_font_size_override("font_size", 18)
		entries_container.add_child(no_entries_label)
		return

	# Create header
	_create_header()

	# Create entries
	for entry in leaderboard_entries:
		_create_entry_row(entry)

## Creates the header row
func _create_header():
	var header_container = HBoxContainer.new()
	header_container.add_theme_constant_override("separation", 20)

	# Position column
	var position_label = Label.new()
	position_label.text = "Rank"
	position_label.custom_minimum_size.x = 80
	position_label.add_theme_font_size_override("font_size", 16)
	position_label.add_theme_color_override("font_color", Color.YELLOW)
	header_container.add_child(position_label)

	# Name column
	var name_label = Label.new()
	name_label.text = "Player"
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color.YELLOW)
	header_container.add_child(name_label)

	# Score column
	var score_label = Label.new()
	score_label.text = "Score"
	score_label.custom_minimum_size.x = 100
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.add_theme_font_size_override("font_size", 16)
	score_label.add_theme_color_override("font_color", Color.YELLOW)
	header_container.add_child(score_label)

	entries_container.add_child(header_container)

	# Add separator
	var separator = HSeparator.new()
	entries_container.add_child(separator)

## Creates an entry row for a leaderboard entry
func _create_entry_row(entry: Dictionary):
	var entry_container = HBoxContainer.new()
	entry_container.add_theme_constant_override("separation", 20)

	# Determine colors based on position
	var text_color = Color.WHITE
	var rank_color = Color.WHITE

	match entry.position:
		1:
			rank_color = Color.GOLD
			text_color = Color.GOLD
		2:
			rank_color = Color.LIGHT_GRAY
			text_color = Color.LIGHT_GRAY
		3:
			rank_color = Color("#CD7F32")  # Bronze
			text_color = Color("#CD7F32")

	# Position
	var position_label = Label.new()
	position_label.text = str(entry.position)
	position_label.custom_minimum_size.x = 80
	position_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	position_label.add_theme_font_size_override("font_size", 14)
	position_label.add_theme_color_override("font_color", rank_color)
	entry_container.add_child(position_label)

	# Player name
	var name_label = Label.new()
	name_label.text = entry.display_name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", text_color)
	entry_container.add_child(name_label)

	# Score
	var score_label = Label.new()
	score_label.text = str(entry.score)
	score_label.custom_minimum_size.x = 100
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.add_theme_font_size_override("font_size", 14)
	score_label.add_theme_color_override("font_color", text_color)
	entry_container.add_child(score_label)

	entries_container.add_child(entry_container)

## Refreshes the leaderboard data
func _refresh_leaderboard():
	if leaderboard_manager:
		loading_label.text = "Loading leaderboard..."
		loading_label.visible = true
		entries_container.visible = false
		leaderboard_manager.get_leaderboard()

## Called when close button is pressed
func _on_close_pressed():
	hide_leaderboard()

## Called when refresh button is pressed
func _on_refresh_pressed():
	_refresh_leaderboard()

## Handle escape key to close
func _input(event):
	if visible and event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			hide_leaderboard()
