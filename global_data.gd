extends Node

# Global data storage for game state
var final_score: int = 0
var high_score: int = 0

func _ready():
	"""Initialize global data"""
	_load_high_score()

func _load_high_score():
	"""Load high score from save file"""
	if FileAccess.file_exists("user://highscore.save"):
		var file = FileAccess.open("user://highscore.save", FileAccess.READ)
		high_score = file.get_32()
		file.close()

func save_high_score(score: int):
	"""Save high score to file"""
	if score > high_score:
		high_score = score
		var file = FileAccess.open("user://highscore.save", FileAccess.WRITE)
		file.store_32(high_score)
		file.close()

func get_high_score() -> int:
	"""Get the current high score"""
	return high_score 
