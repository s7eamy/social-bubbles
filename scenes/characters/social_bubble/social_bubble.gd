extends Node2D

class_name SocialBubble

const INFLUENCE_RADIUS: int = 45

@export var units_comprising: Array = []
#@export var units_comprising_count: int = 0
var type: Globals.UnitTypes

var affected: bool = false
var affected_by_social_bubbles: Array = []

var time_since_last_update: float = 0.0
var current_direction: Vector2 = Vector2.ZERO
var update_interval: float = 0.4
var speed: float = 100.0

func _ready() -> void:
	var update_units_comprising_timer = $UpdateUnitsComprisingTimer
	update_units_comprising_timer.connect("timeout", Callable(self, "update_units_comprising_list"))

	var update_influence_radius_timer = $UpdateInfluenceRadiusTimer
	update_influence_radius_timer.connect("timeout", Callable(self, "update_influence_radius"))

func update_units_comprising_list():
	for unit in units_comprising:
		unit.social_bubble = self
		unit.belongs_to_social_bubble = true
	if units_comprising.size() > 0:
		type = units_comprising[0].type

func update_influence_radius():
	var count: int = units_comprising.size()

	$InfluenceRange/CollisionShape2D.shape.radius = count * INFLUENCE_RADIUS
	#draw_influence_radius
#
#func draw_influence_radius():
	#var radius: int = $InfluenceRange/CollisionShape2D.shape.radius
	#var pos: Vector2 = get_average_position()
	#draw_circle(pos, radius, Color(0, 0.5, 0.5, 0.5), false)

func get_average_position() -> Vector2:
	var total_position = Vector2.ZERO
	for unit in units_comprising:
		total_position += unit.global_position
	if units_comprising.size() > 0:
		return total_position / units_comprising.size()
	else:
		return Vector2.ZERO

func _draw() -> void:
	var pos: Vector2 = position
	draw_circle(pos, 5, Color(0, 0, 0, 1), true)

func _process(delta: float) -> void:
	time_since_last_update += delta
	affect_units_comprising_media_literacy()
	position = get_average_position()
	current_direction = brownian_motion()
	if time_since_last_update >= update_interval:
		for unit in units_comprising:
			# i am not entirely sure how this part works
			unit.current_direction = current_direction
		time_since_last_update = 0.0


func brownian_motion() -> Vector2:
	var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	current_direction = direction.normalized()
	return current_direction

func affect_units_comprising_media_literacy():
	if affected == false: return

	var increment_size: float = 0.0
	for social_bubble in affected_by_social_bubbles:
		increment_size += multiplication_sign(social_bubble.type == Globals.UnitTypes.MEDIA_LITERATE) * social_bubble.units_comprising.size()
	increment_size /= self.units_comprising.size()

	for unit in self.units_comprising:
		unit.influence_media_literacy_score(self, increment_size)

func multiplication_sign(check: bool) -> int:
	return 1 if check else -1

func _on_influence_range_area_entered(area: Area2D) -> void:
	var social_bubble = area.get_parent()
	if social_bubble == self:
		return
	if social_bubble is SocialBubble:
		affected_by_social_bubbles.append(social_bubble)
		affected = true
	else:
		return

func _on_influence_range_area_exited(area: Area2D) -> void:
	var social_bubble = area.get_parent()
	if social_bubble is SocialBubble:
		if affected_by_social_bubbles.has(social_bubble):
			affected_by_social_bubbles.erase(social_bubble)
			if affected_by_social_bubbles.size() == 0:
				affected = false
	else:
		return
