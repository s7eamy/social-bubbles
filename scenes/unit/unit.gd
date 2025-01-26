extends CharacterBody2D

class_name Unit

# Speed of unit
var speed: float = 120.0
# Time interval to update direction
var update_interval: float

var social_bubble: SocialBubble = null
var belongs_to_social_bubble: bool = false

# colors
const COLOR_ILLITERATE = Color(214 / 255.0, 42 / 255.0, 69 / 255.0)
const COLOR_NEUTRAL_MIN = Color(214 / 255.0, 145 / 255.0, 156 / 255.0)
const COLOR_NEUTRAL = Color(214 / 255.0, 214 / 255.0, 214 / 255.0)
const COLOR_NEUTRAL_MAX = Color(140 / 255.0, 176 / 255.0, 214 / 255.0)
const COLOR_LITERATE = Color(29 / 255.0, 121 / 255.0, 214 / 255.0)

const MEDIA_LITERACY_NEUTRAL_MIN_LIMIT: int = -10
const MEDIA_LITERACY_NEUTRAL_MAX_LIMIT: int = 10
const DEFAULT_MEDIA_LITERACY_INCREMENT: float = 1

const MEDIA_LITERACY_STARTING_VALUE_MIN_LIMIT: int = -50
const MEDIA_LITERACY_STARTING_VALUE_MAX_LIMIT: int = 50
const MAX_MEDIA_LITERACY: int = 100
const MIN_MEDIA_LITERACY: int = -100

var time_since_last_update: float = 0.0
var current_direction: Vector2 = Vector2.ZERO
var media_literacy_score: float = 0.0
var connected: bool = false
var connected_fellows: Array = []
var fellow: CharacterBody2D = null

var type: Globals.UnitTypes:
	get:
		return get_type()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	update_interval = randf_range(0.1, 0.9)
	media_literacy_score = randf_range(MEDIA_LITERACY_STARTING_VALUE_MIN_LIMIT, MEDIA_LITERACY_STARTING_VALUE_MAX_LIMIT);
	update_color()

func _draw() -> void:
	draw_connection_range()
	draw_fellow_range()

func _process(delta: float) -> void:
	# Unit color
	update_color()
	move_unit(delta)

func update_color() -> void:
	var color: Color
	if media_literacy_score <= MEDIA_LITERACY_NEUTRAL_MIN_LIMIT:
		color = COLOR_ILLITERATE.lerp(COLOR_NEUTRAL_MIN, calculate_literacy_weight(false, media_literacy_score))
	elif media_literacy_score >= MEDIA_LITERACY_NEUTRAL_MAX_LIMIT:
		color = COLOR_NEUTRAL_MAX.lerp(COLOR_LITERATE, calculate_literacy_weight(true, media_literacy_score))
	else:
		color = COLOR_NEUTRAL

	$MeshInstance2D.modulate = color

func calculate_literacy_weight(positive: bool, media_literacy_score: float):
	if positive:
		return float((media_literacy_score + MEDIA_LITERACY_NEUTRAL_MIN_LIMIT)) / float((100 - MEDIA_LITERACY_NEUTRAL_MAX_LIMIT))
	else:
		return float((media_literacy_score + 100)) / float((100 - MEDIA_LITERACY_NEUTRAL_MAX_LIMIT))

func move_unit(delta):
	time_since_last_update += delta
	if time_since_last_update >= update_interval:
		if connected: # stop and influence media literacy
			current_direction = Vector2.ZERO
			influence_media_literacy_score(connected_fellows[0], DEFAULT_MEDIA_LITERACY_INCREMENT)
		elif fellow: # go towards fellow
			current_direction = global_position.direction_to(fellow.global_position)
		else: # idle
			set_brownian_direction()
		time_since_last_update = 0.0

	velocity = current_direction * speed
	move_and_slide()

func influence_media_literacy_score(target: Object, increment_value: int) -> void:
	if media_literacy_score >= MAX_MEDIA_LITERACY or media_literacy_score <= MIN_MEDIA_LITERACY:
		return
	media_literacy_score += multiplication_sign(target.type == Globals.UnitTypes.MEDIA_LITERATE) * increment_value * connected_fellows.size()

func multiplication_sign(check: bool) -> int:
	return 1 if check else -1

func set_brownian_direction() -> void:
	current_direction = Vector2(
		randf() - 0.5,
		randf() - 0.5
	).normalized()

func get_type() -> Globals.UnitTypes:
	if media_literacy_score <= MEDIA_LITERACY_NEUTRAL_MIN_LIMIT:
		return Globals.UnitTypes.MEDIA_ILLITERATE
	elif media_literacy_score >= MEDIA_LITERACY_NEUTRAL_MAX_LIMIT:
		return Globals.UnitTypes.MEDIA_LITERATE
	else:
		return Globals.UnitTypes.MEDIA_NEUTRAL

func _on_fellow_range_area_entered(area: Area2D) -> void:
	var unit = area.get_parent()
	if unit is SocialBubble:
		return
	if unit == self:
		return
	if unit == fellow:
		return
	if type != unit.get_type():
		return
	if type == Globals.UnitTypes.MEDIA_NEUTRAL:
		return

	if fellow == null or (global_position.distance_to(unit.global_position) < global_position.distance_to(fellow.global_position)):
		fellow = unit

func _on_connection_range_area_entered(area: Area2D) -> void:
	var unit = area.get_parent()
	if unit is SocialBubble:
		return
	if unit == self:
		return
	if unit in connected_fellows:
		return
	if type != unit.get_type():
		return
	if type == Globals.UnitTypes.MEDIA_NEUTRAL:
		return

	connected = true
	current_direction = Vector2.ZERO
	connected_fellows.append(unit)

func _on_connection_range_area_exited(area: Area2D) -> void:
	var unit = area.get_parent()
	if unit is SocialBubble:
		return
	if unit in connected_fellows:
		connected_fellows.erase(unit)
		if connected_fellows.size() == 0:
			connected = false

func draw_connection_range() -> void:
	var radius = $ConnectionRange/CollisionShape2D.shape.radius
	draw_circle(Vector2.ZERO, radius, Color(1, 0, 0, 0.5), false)

func draw_fellow_range() -> void:
	var radius = $FellowRange/CollisionShape2D.shape.radius
	draw_circle(Vector2.ZERO, radius, Color(0, 1, 0, 0.5), false)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# if clicked on unit and it has social bubbles, increase media literacy of all units in the social bubble
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			if social_bubble:
				print("Boosting ", social_bubble.units_comprising.size(), " units")
				# not pretty, but it works. everytime we click on a unit, it greatly boosts literally of all units in its bubble
				for unit in social_bubble.units_comprising:
					var increase = DEFAULT_MEDIA_LITERACY_INCREMENT * 50
					if unit.media_literacy_score + increase > MAX_MEDIA_LITERACY:
						increase = MAX_MEDIA_LITERACY - unit.media_literacy_score
					unit.media_literacy_score += increase
