extends Node

# GameManager singleton for handling scene transitions, game state, and persistent data
# This is an autoloaded singleton that can be accessed from anywhere

signal game_over
signal game_paused
signal game_resumed

var current_score: int = 0
var high_scores: Array[int] = []
var game_paused_state: bool = false

# High score system
const MAX_HIGH_SCORES = 10
const SAVE_FILE_PATH = "user://high_scores.save"

func _ready():
	"""Initialize the GameManager and load saved data."""
	load_high_scores()

func _input(event):
	"""Handle global input events like pause/resume."""
	if event.is_action_pressed("ui_cancel") and _is_in_game_scene():
		toggle_pause()

func _is_in_game_scene() -> bool:
	"""Check if we're currently in the main game scene."""
	var current_scene = get_tree().current_scene
	return current_scene != null and current_scene.name == "Game"

# Scene Management
func change_scene(scene_path: String):
	"""Change to a new scene with error handling."""
	var result = get_tree().change_scene_to_file(scene_path)
	if result != OK:
		push_error("Failed to change scene to: " + scene_path)

func start_new_game():
	"""Start a new game by changing to the game scene."""
	current_score = 0
	game_paused_state = false
	get_tree().paused = false
	change_scene("res://game.tscn")

func return_to_main_menu():
	"""Return to the main menu."""
	get_tree().paused = false
	game_paused_state = false
	change_scene("res://main_menu.tscn")

func restart_game():
	"""Restart the current game."""
	start_new_game()

# Game State Management
func set_game_over(final_score: int):
	"""Handle game over state and check for high score."""
	current_score = final_score
	var is_high_score = check_and_add_high_score(final_score)
	change_scene("res://game_over.tscn")
	game_over.emit()

func toggle_pause():
	"""Toggle game pause state."""
	if game_paused_state:
		resume_game()
	else:
		pause_game()

func pause_game():
	"""Pause the game."""
	game_paused_state = true
	get_tree().paused = true
	game_paused.emit()

func resume_game():
	"""Resume the game."""
	game_paused_state = false
	get_tree().paused = false
	game_resumed.emit()

# High Score System
func check_and_add_high_score(score: int) -> bool:
	"""Check if score is a high score and add it. Returns true if it's a new high score."""
	if high_scores.size() < MAX_HIGH_SCORES or score > high_scores[high_scores.size() - 1]:
		high_scores.append(score)
		high_scores.sort()
		high_scores.reverse()

		if high_scores.size() > MAX_HIGH_SCORES:
			high_scores.resize(MAX_HIGH_SCORES)

		save_high_scores()
		return true
	return false

func get_high_scores() -> Array[int]:
	"""Get the current high scores array."""
	return high_scores.duplicate()

func get_high_score() -> int:
	"""Get the highest score."""
	if high_scores.size() > 0:
		return high_scores[0]
	return 0

# Save/Load System
func save_high_scores():
	"""Save high scores to file."""
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(high_scores)
		file.close()

func load_high_scores():
	"""Load high scores from file."""
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var loaded_scores = file.get_var()
			if loaded_scores is Array:
				high_scores = loaded_scores
			file.close()

# Simple Audio Management
func play_sound_effect(audio_stream_player: AudioStreamPlayer):
	"""Play a sound effect."""
	audio_stream_player.play()