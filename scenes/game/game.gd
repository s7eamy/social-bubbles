extends Node

# variables

@export var social_bubble_scene: PackedScene

var unit_list: Array = []
var unit_not_in_social_bubble_list: Array = []
var unit_in_social_bubble_list: Array = []

var connected_unit_groups: Array = []
var units_visited_by_search: Array = []

@export var unit_counts = {
	Globals.UnitTypes.MEDIA_ILLITERATE: 0,
	Globals.UnitTypes.MEDIA_LITERATE: 0,
	Globals.UnitTypes.MEDIA_NEUTRAL: 0
}

# constants

func _ready() -> void:
	initialize_unit_and_social_bubble_handling_timer()

func initialize_unit_and_social_bubble_handling_timer():
	var game_update_timer = $UpdateUnitListTimer
	game_update_timer.connect("timeout", Callable(self, "update_unit_list"))
	game_update_timer.connect("timeout", Callable(self, "check_social_bubbles"))

func update_unit_list():
	unit_list = get_tree().get_nodes_in_group("units")

	reset_units_counts()	

	for unit in unit_list:
		unit_counts[unit.type] += 1
		update_unit_belonging_to_social_bubbles(unit)

func update_unit_belonging_to_social_bubbles(unit):
	if unit.belongs_to_social_bubble:
		unit_in_social_bubble_list.append(unit)
	else:
		unit_not_in_social_bubble_list.append(unit)

func reset_units_counts():
	unit_not_in_social_bubble_list = []
	unit_in_social_bubble_list = []

	for key in unit_counts.keys():
		unit_counts[key] = 0

func check_social_bubbles():
	find_connected_unit_groups()
	check_new_social_bubbles()

func find_connected_unit_groups():
	connected_unit_groups = []
	units_visited_by_search = []

	for unit in unit_not_in_social_bubble_list:
		if not units_visited_by_search.has(unit):
			var chain: Array = []
			depth_first_search(unit, chain)
			connected_unit_groups.append(chain)

func depth_first_search(unit: Node, chain: Array):
	units_visited_by_search.append(unit)
	chain.append(unit)

	for fellow in unit.connected_fellows:
		if not units_visited_by_search.has(fellow):
			depth_first_search(fellow, chain)

func check_new_social_bubbles():
	for chain in connected_unit_groups:
		if chain.size() >= Globals.MINIMUM_UNITS_TO_FORM_SOCIAL_BUBBLES:
			if social_bubble_connected_to_chain(chain):
				add_new_unit_to_social_bubble(unit_in_chain_not_belonging_to_social_bubble(chain), social_bubble_connected_to_chain(chain))
			else:
				create_social_bubble(chain)

func social_bubble_connected_to_chain(chain):
	for unit in chain:
		if unit.belongs_to_social_bubble:
			return unit.social_bubble
	return null

func add_new_unit_to_social_bubble(unit, social_bubble):
	unit.social_bubble = social_bubble
	unit.belongs_to_social_bubble = true
	social_bubble.units_comprising.append(unit)

func unit_in_chain_not_belonging_to_social_bubble(chain):
	for unit in chain:
		if not unit.belongs_to_social_bubble:
			return unit
	return null

func create_social_bubble(chain):
	var social_bubble = social_bubble_scene.instantiate()
	social_bubble.units_comprising = chain
	get_parent().add_child(social_bubble)
