extends Node2D

@export var speed: float = 50.0
@onready var sprite = $Sprite2D

signal popped

func _process(delta):
	position.y -= speed * delta

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_pop()

func _pop():
	emit_signal("popped")
	
	$Area2D/CollisionShape2D.disabled = true
	$Pop.play()
	$AnimatedSprite2D.play("pop")
	
	$Pop.finished.connect(func():
		queue_free()
	)
	
	$AnimatedSprite2D.animation_finished.connect(func():
		$AnimatedSprite2D.visible = false
	)
