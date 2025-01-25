extends CharacterBody2D

# Speed of unit
var speed: float = 120.0
# Time interval to update direction
var update_interval: float

# colors
const COLOR_ILLITERATE = Color(214 / 255.0, 42 / 255.0, 69 / 255.0)
const COLOR_NEUTRAL_MIN = Color(214 / 255.0, 145 / 255.0, 156 / 255.0)
const COLOR_NEUTRAL = Color(214 / 255.0, 214 / 255.0, 214 / 255.0)
const COLOR_NEUTRAL_MAX = Color(140 / 255.0, 176 / 255.0, 214 / 255.0)
const COLOR_LITERATE = Color(29 / 255.0, 121 / 255.0, 214 / 255.0)

var time_since_last_update: float = 0.0
var current_direction: Vector2 = Vector2.ZERO
var media_literacy_score: int = 0
var connected: bool = false
var connected_fellows: Array = []

var type: Globals.UnitTypes:
	get:
		return get_type()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	update_interval = randf_range(0.1, 0.9)
	media_literacy_score = randi_range(-50, 50);
	update_color()

func _draw() -> void:
	draw_connection_range()

func _process(delta: float) -> void:
	# Unit color
	update_color()

	# Unit movement
	time_since_last_update += delta
	if time_since_last_update >= update_interval:
		var fellow = find_closest_like_minded_unit()
		if connected: # stop and influence media literacy
			current_direction = Vector2.ZERO
			increase_media_literacy_score()
		elif fellow: # go towards fellow
			current_direction = global_position.direction_to(fellow.global_position)
		else: # idle
			set_brownian_direction()
		time_since_last_update = 0.0
	
	velocity = current_direction * speed
	move_and_slide()

func update_color() -> void:
	var color: Color
	if media_literacy_score <= -10:
		color = COLOR_ILLITERATE.lerp(COLOR_NEUTRAL_MIN, (media_literacy_score + 100) / 90.0)
	elif media_literacy_score >= 10:
		color = COLOR_NEUTRAL_MAX.lerp(COLOR_LITERATE, (media_literacy_score - 10) / 90.0)
	else:
		color = COLOR_NEUTRAL
	
	$MeshInstance2D.modulate = color

func find_closest_like_minded_unit() -> CharacterBody2D:
	var closest_unit: CharacterBody2D = null
	var closest_distance: float = INF
	var area2d = $FellowRange
	for body in area2d.get_overlapping_bodies():
		if body.get_groups().has("units") and body != self:
			var other_unit = body as CharacterBody2D
			if (self.get_type() == other_unit.get_type() and self.get_type() != Globals.UnitTypes.MEDIA_NEUTRAL):
				var distance = global_position.distance_to(other_unit.global_position)
				if distance < closest_distance:
					closest_distance = distance
					closest_unit = other_unit
	return closest_unit

func set_brownian_direction() -> void:
	current_direction = Vector2(
		randf() - 0.5,
		randf() - 0.5
	).normalized()

func increase_media_literacy_score() -> void:
	if type == Globals.UnitTypes.MEDIA_ILLITERATE:
		media_literacy_score -= 1
	elif type == Globals.UnitTypes.MEDIA_LITERATE:
		media_literacy_score += 1

func get_type() -> Globals.UnitTypes:
	if media_literacy_score <= -10:
		return Globals.UnitTypes.MEDIA_ILLITERATE
	elif media_literacy_score >= 10:
		return Globals.UnitTypes.MEDIA_LITERATE
	else:
		return Globals.UnitTypes.MEDIA_NEUTRAL

func _on_connection_range_area_entered(area: Area2D) -> void:
	var fellow : CharacterBody2D = area.get_parent()
	if fellow == self:
		return
	if fellow in connected_fellows:
		return
	if type != fellow.get_type():
		return
	if type == Globals.UnitTypes.MEDIA_NEUTRAL:
		return

	connected = true
	current_direction = Vector2.ZERO
	connected_fellows.append(fellow)

func _on_connection_range_area_exited(area: Area2D) -> void:
	var fellow : CharacterBody2D = area.get_parent()
	if fellow in connected_fellows:
		connected_fellows.erase(fellow)
		if connected_fellows.size() == 0:
			connected = false

func draw_connection_range() -> void:
	var radius = $ConnectionRange/CollisionShape2D.shape.radius
	draw_circle(Vector2.ZERO, radius, Color(1, 0, 0, 0.5))