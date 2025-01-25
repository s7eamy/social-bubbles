extends Node

func _ready() -> void:
	_initialize_score_handling_timer()

func _process(delta: float) -> void:
	pass

func _initialize_score_handling_timer():
	var score_update_timer = $UpdateScoreTimer
	score_update_timer.connect("timeout", Callable(self, "_update_score"))
