extends CharacterBody2D

# Speed of the Brownian motion
@export var speed: float = 350.0
# Time interval to update direction
@export var update_interval: float = 0.2

var time_since_last_update: float = 0.0
var current_direction: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
    time_since_last_update += delta
    if time_since_last_update >= update_interval:
        time_since_last_update = 0.0
        current_direction = Vector2(
            randf() - 0.5,
            randf() - 0.5
        ).normalized()
    
    velocity = current_direction * speed
    move_and_slide()
