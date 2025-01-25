extends Node

class_name SocialBubble

@export var units_comprising: Array = []

func _ready() -> void:
	var units_comprising_update_timer = $UpdateUnitsComprisingTimer
	units_comprising_update_timer.connect("timeout", Callable(self, "update_units_comprising_list"))

func update_units_comprising_list():
	for unit in units_comprising:
		unit.social_bubble = self
		unit.belongs_to_social_bubble = true
