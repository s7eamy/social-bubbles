extends Node2D

class_name SocialBubble

@export var units_comprising: Array = []
var type: Globals.UnitTypes

func _ready() -> void:
	var units_comprising_update_timer = $UpdateUnitsComprisingTimer
	units_comprising_update_timer.connect("timeout", Callable(self, "update_units_comprising_list"))

func update_units_comprising_list():
	for unit in units_comprising:
		unit.social_bubble = self
		unit.belongs_to_social_bubble = true
	type = units_comprising[0].type

func _draw() -> void:
	draw_influence_radius()

func _process(delta: float) -> void:
	update_influence_radius()

func get_average_position() -> Vector2:
	var total_position = Vector2.ZERO
	for unit in units_comprising:
		total_position += unit.global_position
	if units_comprising.size() > 0:
		return total_position / units_comprising.size()
	else:
		return Vector2.ZERO

func update_influence_radius():
	var count: int = units_comprising.size()
	var size: int = 45 # 45px is the unit's connection range's radius. this is hardcoded because i am losing my mind

	$InfluenceRange/CollisionShape2D.shape.radius = count * size

func draw_influence_radius():
	var radius: int = $InfluenceRange/CollisionShape2D.shape.radius
	var pos: Vector2 = get_average_position()
	draw_circle(pos, radius, Color(0, 0.5, 0.5, 0.5), false)
