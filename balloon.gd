extends RigidBody2D

@export var lift_force := 100.0
@export var wind_scale := 1.0

signal popped

var rotation_stiffness := 1500.0
var rotation_damping := 20.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var color: BalloonColor

enum BalloonColor { BLUE, GREEN, ORANGE, PINK, PURPLE, RED, YELLOW }

var color_map := {
	BalloonColor.BLUE: preload("res://sprites/balloon_blue.tres"),
	BalloonColor.GREEN: preload("res://sprites/balloon_green.tres"),
	BalloonColor.ORANGE: preload("res://sprites/balloon_orange.tres"),
	BalloonColor.PINK: preload("res://sprites/balloon_pink.tres"),
	BalloonColor.PURPLE: preload("res://sprites/balloon_purple.tres"),
	BalloonColor.RED: preload("res://sprites/balloon_red.tres"),
	BalloonColor.YELLOW: preload("res://sprites/balloon_yellow.tres"),
}

func _ready():
	add_to_group("balloons")
	var random_color = color_map.keys()[randi() % color_map.size()]
	sprite.frames = color_map[random_color]
	color = random_color
	
var wind_force := 0.0

func on_wind_changed(new_wind: float):
	wind_force = new_wind
	
func _physics_process(delta):
	apply_central_force(Vector2(0, -lift_force))
	
	apply_force(Vector2(wind_force * wind_scale, 0), Vector2(0, -10)) 
	
	var restoring_torque = -rotation * rotation_stiffness - angular_velocity * rotation_damping
	apply_torque(restoring_torque)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_pop()

func _pop():
	emit_signal("popped")
	
	$CollisionShape2D.disabled = true
	$Pop.play()
	$AnimatedSprite2D.play("pop")
	
	$Pop.finished.connect(func():
		queue_free()
	)
	
	$AnimatedSprite2D.animation_finished.connect(func():
		$AnimatedSprite2D.visible = false
	)
