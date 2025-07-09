extends Node2D

# Signal emitted when balloon is successfully popped
signal balloon_popped
# Signal emitted when balloon escapes off the screen
signal balloon_escaped

@export var speed: float = 50.0
@export var shrink_rate: float = 0.5
var is_over = false
var is_sucking = false
var initial_scale: Vector2
var has_escaped = false

@onready var sprite = $Sprite2D
@onready var suck = $Suck

func _ready():
	initial_scale = sprite.scale

func _process(delta):
	position.y -= speed * delta
	
	# Check if balloon has escaped off the top of the screen
	if position.y < -100 and not has_escaped:
		has_escaped = true
		emit_signal("balloon_escaped")
		queue_free()
		return

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and is_over:
		if is_sucking == false:
			suck.play()
		is_sucking = true
		sprite.scale -= initial_scale * shrink_rate * delta

		# Calculate normalized scale ratio
		var scale_ratio_x = sprite.scale.x / initial_scale.x
		var scale_ratio_y = sprite.scale.y / initial_scale.y

		# Destroy if it's shrunk to 25% or less
		if scale_ratio_x <= 0.25 and scale_ratio_y <= 0.25:
			# Emit signal before destroying
			emit_signal("balloon_popped")
			queue_free()
	else:
		is_sucking = false
		suck.stop()

func _on_area_2d_mouse_entered() -> void:
	is_over = true

func _on_area_2d_mouse_exited() -> void:
	is_over = false
