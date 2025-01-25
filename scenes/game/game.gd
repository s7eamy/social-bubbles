extends Node

# variables

var unit_list: Array = []

@export var unit_counts = {
	Globals.UnitTypes.MEDIA_ILLITERATE: 0,
	Globals.UnitTypes.MEDIA_LITERATE: 0,
	Globals.UnitTypes.MEDIA_NEUTRAL: 0
}

# constants

func _ready() -> void:
	_initialize_unit_and_social_bubble_handling_timer()

func _process(delta: float) -> void:
	pass

func _initialize_unit_and_social_bubble_handling_timer():
	var game_update_timer = $UpdateUnitListTimer
	game_update_timer.connect("timeout", Callable(self, "_update_unit_list"))
	#game_update_timer.connect("timeout", Callable(self, "_check_social_bubbles"))

func _update_unit_list():
	unit_list.clear()
	unit_list = get_tree().get_nodes_in_group("units")
	print("Unit objects:", unit_list)
	
	_update_unit_counts()

func _update_unit_counts():
	_reset_units_counts()

	for unit in unit_list:
		unit_counts[unit.Type] += 1

func _reset_units_counts():
	for key in unit_counts.keys():
		unit_counts[key] = 0

func _check_social_bubbles():
	_check_for_connected_group()

func check_for_connected_group():
	var group_connected = false
	for unit in unit_list:
		for fellow in unit.connected_fellow:
			if check_chain(unit, fellow, [unit], 0):
				group_connected = true
				return true
	group_connected = false
	return false

# Recursive function to check for a chain of exactly three connected units
func check_chain(start_unit, current_unit, visited_units, depth):
	# Avoid visiting the same unit more than once
	if visited_units.has(current_unit):
		return false
	
	# Add the current unit to the visited list
	visited_units.append(current_unit)
	
	# If we've reached depth 2 (the third unit in the chain), we have found a group
	if depth == 2:
		# Check if this unit is connected back to the start unit, completing the chain
		return true

	for next_unit in current_unit.connected_fellow:
		if check_chain(start_unit, next_unit, visited_units, depth + 1):
			return true
	
	return false

func _create_social_bubble():
	pass
