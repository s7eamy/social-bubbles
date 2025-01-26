extends Node

var game_controller
var score_literate: int = 0
var score_illiterate: int = 0
var count_literate: int = 0
var count_illiterate: int = 0
var influence_points: float = 0
var count_literate_social_bubbles: int = 0
var count_illiterate_social_bubbles: int = 0
@onready var score_label: Label = $Background/ScoreBar/ScoreLabel
@onready var score_bar: ProgressBar = $Background/ScoreBar
@onready var literates_label: Label = $Background/LiteratesPanel/LiteratesLabel
@onready var illiterates_label: Label = $Background/IlliteratesPanel/IlliteratesLabel
@onready var literates_bubbles_label: Label = $Background/LiteratesBubblesPanel/LiteratesBubblesLabel
@onready var illiterates_bubbles_label: Label = $Background/IlliteratesBubblesPanel/IlliteratesBubblesLabel
@onready var influence_points_label: Label = $Background/InfluencePointsPanel/InfluencePointsLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_controller = find_game_node()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	calculate_score()
	calculate_unit_counts()
	calculate_social_bubble_counts()
	calculate_influence_points()
	
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
		
func calculate_unit_counts():
	count_literate = 0
	count_illiterate = 0
	if game_controller and game_controller.unit_list:
		for unit in game_controller.unit_list:
			if unit.type == Globals.UnitTypes.MEDIA_ILLITERATE:
				count_illiterate += 1
			elif unit.type == Globals.UnitTypes.MEDIA_LITERATE:
				count_literate += 1
		literates_label.text = str(count_literate)
		illiterates_label.text = str(count_illiterate)
		
func calculate_social_bubble_counts():
	count_literate_social_bubbles = 0
	count_illiterate_social_bubbles = 0
	if game_controller and game_controller.social_bubble_list:
		for social_bubble in game_controller.social_bubble_list:
			if social_bubble.type == Globals.UnitTypes.MEDIA_ILLITERATE:
				count_illiterate_social_bubbles += 1
			elif social_bubble.type == Globals.UnitTypes.MEDIA_LITERATE:
				count_literate_social_bubbles += 1
		literates_bubbles_label.text = str(count_literate_social_bubbles)
		illiterates_bubbles_label.text = str(count_illiterate_social_bubbles)
		
func calculate_influence_points():
	influence_points += 0.1
	influence_points_label.text = str(round(influence_points))
	
