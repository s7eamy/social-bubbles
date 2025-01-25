extends Node

var unit_list = []

func _ready() -> void:
	_initialize_unit_list_update_timer()

func _process(delta: float) -> void:
	pass

func _initialize_unit_list_update_timer():
	var unit_list_update_timer = $UpdateUnitListTimer
	unit_list_update_timer.connect("timeout", Callable(self, "_update_unit_list"))

func _update_unit_list():
	unit_list.clear()
	unit_list = get_tree().get_nodes_in_group("unit")
	print("Unit objects:", unit_list)
