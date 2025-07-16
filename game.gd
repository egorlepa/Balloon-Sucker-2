extends Node2D

@onready var speed_label: Label = $DebugInfo/SpeedLabel
@onready var spawn_interval_label: Label = $DebugInfo/SpawnIntervalLabel
@onready var difficulty_label: Label = $DebugInfo/DifficultyLabel
@onready var debug_info: Control = $DebugInfo

@onready var health_label: Label = $Health/Label
@onready var score_label: Label = $ScoreLabel

@onready var balloon_timer: Timer = $SpawnTimer
@onready var pause_button: Button = $PauseButton

var pause_menu: Control = null
var pause_menu_scene = preload("res://pause_menu.tscn")

var elapsed_time := 0.0

var min_interval :=  0.1
var max_interval :=  1.0
var spawn_interval := max_interval

var min_speed := 100.0
var max_speed := 200.0
var speed := min_speed

var Balloon = preload("res://balloon.tscn")

var health = 10
var score = 0

var wind_strength := 0.0
var max_wind_strength := 150.0
var wind_change_interval := 2.0
var wind_timer := 0.0

func _ready() -> void:
	health_label.text = str(health)
	score_label.text = str(score)
	randomize()
	balloon_timer.start(spawn_interval)
	_spawn_balloon_batch()
	_change_wind()
	
	# Set up pause functionality
	pause_button.pressed.connect(_on_pause_button_pressed)
	
	# Connect to GameManager signals
	GameManager.game_paused.connect(_on_game_paused)
	GameManager.game_resumed.connect(_on_game_resumed)
	
	# Debug info disabled by default
	debug_info.visible = false

@export var difficulty_curve: Curve
var difficulty := 0.0
var max_difficulty_time := 300.0

func _process(delta):
	elapsed_time += delta
	wind_timer += delta
	if wind_timer >= wind_change_interval:
		wind_timer = 0.0
		_change_wind()

	difficulty = difficulty_curve.sample(elapsed_time / max_difficulty_time)
	difficulty_label.text = "Difficulty: %0.2f%%" % (difficulty*100)

	speed = lerp(min_speed, max_speed, difficulty)
	speed_label.text = "Speed: %0.0f" % speed
		
	spawn_interval = lerp(max_interval, min_interval, difficulty)
	spawn_interval_label.text = "Interval: %0.2f" % spawn_interval
	
	balloon_timer.wait_time = spawn_interval

func _change_wind():
	wind_strength = randf_range(-max_wind_strength, max_wind_strength)
	_notify_wind_change()

func _spawn_balloon_batch():
	var b = Balloon.instantiate()
	b.on_wind_changed(wind_strength)
	add_child(b)
	b.popped.connect(func():
		score += 1
		score_label.text = str(score)	
	)

	var viewport_width = get_viewport().get_visible_rect().size.x
	var viewport_height = get_viewport().get_visible_rect().size.y
	var sprite = b.get_node("AnimatedSprite2D") as AnimatedSprite2D
	var texture_size = sprite.sprite_frames.get_frame_texture("pop", 0).get_size()
	var scaled_height = texture_size.y * sprite.scale.y
	var scaled_width = texture_size.x * sprite.scale.x
	var random_x = scaled_width / 2 + randi() % int(viewport_width - scaled_width)

	b.position = Vector2(random_x, viewport_height + scaled_height / 2)

	## Apply jitter to speed
	var jitter = randf_range(0.75, 1.25)
	b.lift_force = speed * jitter
	b.wind_scale = randf_range(0.75, 1.25)

func _notify_wind_change():
	for b in get_tree().get_nodes_in_group("balloons"):
		if b.has_method("on_wind_changed"):
			b.on_wind_changed(wind_strength)

func _on_spawn_timer_timeout() -> void:
	_spawn_balloon_batch()

func _on_despawn_boundary_body_entered(body: Node2D) -> void:
	health -= 1
	health_label.text = str(health)
	
	var fart := $Fart.duplicate()
	add_child(fart)
	fart.volume_db = linear_to_db(0.2)
	GameManager.play_sound_effect(fart)
	fart.finished.connect(func():
		fart.queue_free()
	)
	
	body.queue_free()
	if health == 0:
		# Game over - pass final score to GameManager
		GameManager.set_game_over(score)

# Pause menu functions
func _on_pause_button_pressed():
	"""Handle pause button press."""
	print("Pause button pressed!")
	GameManager.pause_game()
	print("GameManager.pause_game() called")

func _on_game_paused():
	"""Handle game paused signal - show pause menu."""
	print("Game paused signal received!")
	if pause_menu == null:
		pause_menu = pause_menu_scene.instantiate()
		get_tree().current_scene.add_child(pause_menu)
	pause_menu.visible = true
	print("Pause menu set to visible")

func _on_game_resumed():
	"""Handle game resumed signal - hide pause menu."""
	pause_menu.visible = false
