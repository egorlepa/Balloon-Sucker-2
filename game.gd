extends Node2D

@onready var speed_label: Label = $DebugInfo/SpeedLabel
@onready var spawn_interval_label: Label = $DebugInfo/SpawnIntervalLabel
@onready var health_label: Label = $Health/Label

@onready var balloon_timer: Timer = $SpawnTimer
var elapsed_time := 0.0

var min_interval :=  0.1
var max_interval :=  1.0
var spawn_interval := max_interval

var min_speed := 200.0
var max_speed := 500.0
var speed := min_speed

var Balloon = preload("res://balloon.tscn")

var health = 10

func _ready() -> void:
	health_label.text = str(health)
	randomize()
	balloon_timer.start(spawn_interval)
	_spawn_balloon_batch()

var difficulty := 0.0
var max_difficulty_time := 300.0

func _process(delta):
	elapsed_time += delta

	difficulty = clamp(elapsed_time / max_difficulty_time, 0.0, 1.0)

	speed = lerp(min_speed, max_speed, difficulty)
	var new_interval = lerp(max_interval, min_interval, difficulty)

	# Update labels and timer
	speed_label.text = "Speed: %0.0f" % speed
	spawn_interval_label.text = "Interval: %0.2f" % new_interval
	balloon_timer.wait_time = new_interval

var max_spawn_per_event := 10

func _spawn_balloon_batch():
	var b = Balloon.instantiate()
	add_child(b)

	var viewport_width = get_viewport().get_visible_rect().size.x
	var viewport_height = get_viewport().get_visible_rect().size.y
	var sprite = b.get_node("AnimatedSprite2D") as AnimatedSprite2D
	var texture_size = sprite.sprite_frames.get_frame_texture("pop", 0).get_size()
	var scaled_height = texture_size.y * sprite.scale.y
	var scaled_width = texture_size.x * sprite.scale.x
	var random_x = scaled_width / 2 + randi() % int(viewport_width - scaled_width)

	b.position = Vector2(random_x, viewport_height + scaled_height / 2)

	# Apply jitter to speed
	var jitter = randf_range(0.75, 1.25)
	b.speed = speed * jitter

func _on_spawn_timer_timeout() -> void:
	_spawn_balloon_batch()

func _on_despawn_boundary_area_entered(area: Area2D) -> void:
	health -= 1
	health_label.text = str(health)
	
	var fart := $Fart.duplicate()
	add_child(fart)
	fart.play(0.2)
	fart.finished.connect(func():
		fart.queue_free()
	)
	
	area.get_parent().queue_free()
	if health == 0:
		get_tree().paused = true
