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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	update_interval = randf_range(0.1, 0.9)
	media_literacy_score = randi_range(-100, 100);
	update_color()

func set_brownian_velocity() -> void:
	current_direction = Vector2(
		randf() - 0.5,
		randf() - 0.5
	).normalized()
	velocity = current_direction * speed

func _process(delta: float) -> void:
	# Unit color
	update_color()

	# Unit movement
	time_since_last_update += delta
	if time_since_last_update >= update_interval:
		# if unit is neutral or no fellows
		set_brownian_velocity()
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

func get_type() -> Globals.UnitTypes:
	if media_literacy_score <= -10:
		return Globals.UnitTypes.MEDIA_ILLITERATE
	elif media_literacy_score >= 10:
		return Globals.UnitTypes.MEDIA_LITERATE
	else:
		return Globals.UnitTypes.MEDIA_NEUTRAL