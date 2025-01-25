extends CharacterBody3D

# Speed of the Brownian motion
export var speed: float = 1.0

func _process(delta: float) -> void:
    var random_direction = Vector3(
        randf() - 0.5,
        randf() - 0.5,
        randf() - 0.5
    ).normalized()
    var movement = random_direction * speed * delta
    translate(movement)