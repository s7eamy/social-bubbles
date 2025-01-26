extends Node2D

@export var unit_scene: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	var num_units = 250
	for i in range(num_units):
		var unit_instance = unit_scene.instantiate()
		unit_instance.position = Vector2(
			randf_range(-443, 1437),
			randf_range(-131, 949)
		)
		add_child(unit_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
