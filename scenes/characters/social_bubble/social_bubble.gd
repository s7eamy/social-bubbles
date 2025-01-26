extends Node2D

class_name SocialBubble

const INFLUENCE_RADIUS: int = 45

@export var units_comprising: Array = []
var type: Globals.UnitTypes

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

func _on_influence_range_area_entered(area: Area2D) -> void:
	var social_bubble = area.get_parent()
	if social_bubble == self:
		return
	if social_bubble is SocialBubble:
		affect_units_comprising_media_literacy(social_bubble.units_comprising.size())
	else:
		return

func affect_units_comprising_media_literacy(size: int):
	print('affect_units_comprising_media_literacy')
	#unit_list = social_bubble.units_comprising
	#for unit in 
