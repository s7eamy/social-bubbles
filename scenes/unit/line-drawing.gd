extends Node

const LINE_DRAW_DURATION = 1.0

#var line: Line2D
@export var line: Line2D  # The Line2D node for drawing
var is_drawing_line: bool = false
var current_time: float = 0.0
var start_position: Vector2
var end_position: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_drawing_line:
		animate_line(delta)
	
func create_line2d():
	# Create a new Line2D node
	var line = Line2D.new()

	# Configure its appearance (optional)
	line.width = 4.0  # Set the width of the line
	line.default_color = Color(1, 0, 0)  # Set the color of the line (red in this case)

	# Add the Line2D node to the scene
	add_child(line)  # Add it as a child of the current node or another node
	
	return line
	
func start_line_animation(node_a: Node, node_b: Node):
	is_drawing_line = true
	current_time = 0.0
	start_position = node_a.position
	end_position = node_b.position
	line.clear_points()  # Clear previous line points
	line.add_point(start_position)  # Start at node_a's position
	
func animate_line(delta: float):
	current_time += delta
	var t = current_time / LINE_DRAW_DURATION  # Calculate the interpolation factor
	t = clamp(t, 0.0, 1.0)  # Ensure t is between 0 and 1

	# Interpolate the line to the end position
	var current_position = start_position.lerp(end_position, t)
	if line.get_point_count() == 1:
		line.add_point(current_position)
	else:
		line.set_point_position(1, current_position)

	# Finish the animation
	if t >= 1.0:
		is_drawing_line = false
