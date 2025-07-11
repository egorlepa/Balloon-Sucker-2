extends Node

## LeaderboardManager handles all PlayFab leaderboard operations
## Including anonymous login, score submission, and leaderboard retrieval
class_name LeaderboardManager

# Signals for UI updates
signal login_completed(success: bool)
signal score_submitted(success: bool)
signal leaderboard_received(entries: Array)
signal leaderboard_error(error_message: String)

# Leaderboard configuration
const LEADERBOARD_NAME = "HighScores"
const MAX_LEADERBOARD_ENTRIES = 10

# Player info
var player_display_name: String = ""
var is_logged_in: bool = false

func _ready():
	# Connect to PlayFab signals
	PlayFabManager.client.logged_in.connect(_on_logged_in)
	PlayFabManager.client.api_error.connect(_on_api_error)
	
	# Generate a display name for the player
	_generate_display_name()
	
	# Attempt to login automatically
	_login_anonymous()

## Generates a random display name for the player
func _generate_display_name():
	var adjectives = ["Swift", "Brave", "Sharp", "Quick", "Mighty", "Clever", "Bold", "Fast", "Strong", "Wise"]
	var nouns = ["Popper", "Hunter", "Shooter", "Master", "Champion", "Hero", "Warrior", "Ace", "Pro", "Star"]
	
	var random_adjective = adjectives[randi() % adjectives.size()]
	var random_noun = nouns[randi() % nouns.size()]
	var random_number = randi() % 1000
	
	player_display_name = "%s%s%d" % [random_adjective, random_noun, random_number]

## Attempts to login anonymously to PlayFab
func _login_anonymous():
	print("Attempting to login to PlayFab...")
	
	# Create combined info request to get player profile
	var combined_info_request = GetPlayerCombinedInfoRequestParams.new()
	combined_info_request.show_all()
	
	# Generate a unique custom ID for this player (persistent across sessions)
	var custom_id = _get_or_create_custom_id()
	
	# Login with custom ID
	PlayFabManager.client.login_with_custom_id(custom_id, true, combined_info_request)

## Gets or creates a persistent custom ID for the player
func _get_or_create_custom_id() -> String:
	var save_file = FileAccess.open("user://player_id.dat", FileAccess.READ)
	var custom_id: String
	
	if save_file:
		custom_id = save_file.get_as_text()
		save_file.close()
	else:
		# Generate new UUID for this player
		custom_id = UUID.v4()
		save_file = FileAccess.open("user://player_id.dat", FileAccess.WRITE)
		save_file.store_string(custom_id)
		save_file.close()
	
	return custom_id

## Called when login succeeds
func _on_logged_in(login_result: LoginResult):
	print("Successfully logged in to PlayFab!")
	is_logged_in = true
	
	# Update display name if this is a new player
	if login_result.NewlyCreated:
		_update_display_name()
	
	emit_signal("login_completed", true)

## Called when API errors occur
func _on_api_error(error: ApiErrorWrapper):
	print("PlayFab API Error: ", error.error_message)
	emit_signal("login_completed", false)
	emit_signal("leaderboard_error", error.error_message)

## Updates the player's display name
func _update_display_name():
	if not is_logged_in:
		return
	
	var request_data = {
		"DisplayName": player_display_name
	}
	
	PlayFabManager.client.post_dict_auth(
		request_data,
		"/Client/UpdateUserTitleDisplayName",
		PlayFab.AUTH_TYPE.SESSION_TICKET,
		_on_display_name_updated
	)

## Called when display name is updated
func _on_display_name_updated(result: Dictionary):
	print("Display name updated to: ", player_display_name)

## Submits a score to the leaderboard
func submit_score(score: int):
	if not is_logged_in:
		print("Cannot submit score - not logged in")
		emit_signal("score_submitted", false)
		return
	
	print("Submitting score: ", score)
	
	var request_data = {
		"Statistics": [
			{
				"StatisticName": LEADERBOARD_NAME,
				"Value": score
			}
		]
	}
	
	PlayFabManager.client.post_dict_auth(
		request_data,
		"/Client/UpdatePlayerStatistics",
		PlayFab.AUTH_TYPE.SESSION_TICKET,
		_on_score_submitted
	)

## Called when score submission completes
func _on_score_submitted(result: Dictionary):
	print("Score submitted successfully!")
	emit_signal("score_submitted", true)
	
	# Automatically fetch updated leaderboard
	get_leaderboard()

## Gets the current leaderboard
func get_leaderboard():
	if not is_logged_in:
		print("Cannot get leaderboard - not logged in")
		emit_signal("leaderboard_error", "Not logged in")
		return
	
	print("Fetching leaderboard...")
	
	var request_data = {
		"StatisticName": LEADERBOARD_NAME,
		"StartPosition": 0,
		"MaxResultsCount": MAX_LEADERBOARD_ENTRIES
	}
	
	PlayFabManager.client.post_dict_auth(
		request_data,
		"/Client/GetLeaderboard",
		PlayFab.AUTH_TYPE.SESSION_TICKET,
		_on_leaderboard_received
	)

## Called when leaderboard data is received
func _on_leaderboard_received(result: Dictionary):
	print("Leaderboard received!")
	
	var entries = []
	if result.has("data") and result.data.has("Leaderboard"):
		var leaderboard_data = result.data.Leaderboard
		
		for entry in leaderboard_data:
			var leaderboard_entry = {
				"position": entry.Position + 1,  # PlayFab uses 0-based indexing
				"display_name": entry.DisplayName if entry.has("DisplayName") else "Anonymous",
				"score": entry.StatValue
			}
			entries.append(leaderboard_entry)
	
	emit_signal("leaderboard_received", entries)

## Gets the player's personal best score
func get_personal_best():
	if not is_logged_in:
		return
	
	var request_data = {
		"StatisticNames": [LEADERBOARD_NAME]
	}
	
	PlayFabManager.client.post_dict_auth(
		request_data,
		"/Client/GetPlayerStatistics",
		PlayFab.AUTH_TYPE.SESSION_TICKET,
		_on_personal_best_received
	)

## Called when personal best is received
func _on_personal_best_received(result: Dictionary):
	if result.has("data") and result.data.has("Statistics"):
		var statistics = result.data.Statistics
		for stat in statistics:
			if stat.StatisticName == LEADERBOARD_NAME:
				print("Personal best: ", stat.Value)
				# You can emit a signal here if needed for UI updates
				break 
