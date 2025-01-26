extends Node2D

@export var unit_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	var num_units = 50
	for i in range(num_units):
		var unit_instance = unit_scene.instantiate()
		unit_instance.position = Vector2(
			randf_range(0, get_viewport_rect().size.x),
			randf_range(0, get_viewport_rect().size.y)
		)
		add_child(unit_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
