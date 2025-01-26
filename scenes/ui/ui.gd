extends Node

var game_controller
var score_literate: int = 0
var score_illiterate: int = 0
@onready var score_label: Label = $Background/ScoreBar/ScoreLabel
@onready var score_bar: ProgressBar = $Background/ScoreBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_controller = find_game_node()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	calculate_score()
	
func find_game_node():
	# Start searching from the root node
	var game_node = get_tree().get_nodes_in_group("game")
	
	if game_node.size() > 0:
		return game_node[0]
	else:
		print("Node 'game' not found!")
		return null
		
func calculate_score():
	score_literate = 0
	score_illiterate = 0
	if game_controller and game_controller.unit_list:
		for unit in game_controller.unit_list:
			if unit.type == Globals.UnitTypes.MEDIA_ILLITERATE:
				score_illiterate += abs(unit.media_literacy_score)
			elif unit.type == Globals.UnitTypes.MEDIA_LITERATE:
				score_literate += unit.media_literacy_score
		score_label.text = str(round(score_literate)) + " : " + str(round(score_illiterate))
		score_bar.value = float(score_literate) / float((score_illiterate + score_literate)) * 100
