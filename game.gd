extends Node2D

@onready var balloon_timer: Timer = $SpawnTimer
var spawn_interval := 2.0
var min_interval := 0.5
var interval_decay := 0.01
var elapsed_time := 0.0

var Balloon = preload("res://balloon.tscn")

func _ready() -> void:
	randomize()
	balloon_timer.start(spawn_interval)
	_spawn_balloon()

func _process(delta):
	elapsed_time += delta

	# Decrease interval gradually
	var new_interval = max(min_interval, spawn_interval - elapsed_time * interval_decay)

	# Apply new interval to the timer (next cycle)
	balloon_timer.wait_time = new_interval

func _spawn_balloon():
	var b = Balloon.instantiate()
	add_child(b)
	
	var viewport_width = get_viewport().get_visible_rect().size.x
	var viewport_height = get_viewport().get_visible_rect().size.y
	var random_x = randi() % int(viewport_width)
	var sprite = b.get_node("Sprite2D")
	var texture_size = sprite.texture.get_size()
	var scaled_height = texture_size.y * sprite.scale.y
	
	b.position = Vector2(random_x, viewport_height+scaled_height/2)
	b.speed = 50.0


func _on_spawn_timer_timeout() -> void:
	_spawn_balloon()
