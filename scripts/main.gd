extends Control

@export var CardScene: PackedScene
@export var card_anchor_path: NodePath          # set in inspector to your CenterContainer node
@export var status_label_path: NodePath         # set in inspector to your top label for short feedback

var card_anchor: Node
var status_label: Label

var questions: Array = []
var q_index: int = 0

# stats
var stat_scores: Dictionary = {}
var stat_counts: Dictionary = {}

func _ready() -> void:
	# find anchor and label
	if card_anchor_path != NodePath(""):
		card_anchor = get_node(card_anchor_path)
	else:
		card_anchor = find_child("CenterContainer", true, false)

	if status_label_path != NodePath(""):
		status_label = get_node(status_label_path)
	else:
		status_label = find_child("TopLabel", true, false)

	if not card_anchor:
		push_error("Card anchor not found. Set card_anchor_path in the inspector.")
		return

	# Example questions
	questions = [
		{"id":1, "question":"Do you take care when you wake up before coming to class?", "image":"res://Assets/imagetoquestion/id1.jpg", "stat":"selfcare", "yes_value":1, "no_value":-1},
		{"id":2, "question":"Do you leave home early to arrive in time?", "image":"res://Assets/imagetoquestion/id2.webp", "stat":"punctuality", "yes_value":1, "no_value":-1},
		{"id":3, "question":"Do you leave your work until the last minute?","image": "res://Assets/imagetoquestion/id3.jpg", "stat":"procrastination", "yes_value":1, "no_value":-1},
		{"id":4, "question":"Do you enjoy social gatherings?", "image":"res://Assets/imagetoquestion/id4.jpeg", "stat":"social", "yes_value":1, "no_value":-1}
	]

	q_index = 0
	stat_scores.clear()
	stat_counts.clear()

	spawn_card()

func spawn_card() -> void:
	if q_index >= questions.size():
		_show_results()
		return

	if not CardScene:
		push_error("CardScene not set in inspector.")
		return

	var c = CardScene.instantiate()
	card_anchor.add_child(c)
	c.connect("answered", Callable(self, "_on_card_answered"))
	c.set_question_data(questions[q_index])
	q_index += 1

func _on_card_answered(choice: String, data: Dictionary) -> void:
	var stat_name = data.get("stat", "general")
	var val = data.get("yes_value", 1) if choice == "yes" else data.get("no_value", -1)
	stat_scores[stat_name] = stat_scores.get(stat_name, 0) + val
	stat_counts[stat_name] = stat_counts.get(stat_name, 0) + 1

	if status_label:
		status_label.text = "Answered: %s — %s" % [choice.to_upper(), data.get("question", "")]

	await get_tree().create_timer(0.18).timeout
	spawn_card()

func _show_results() -> void:
	var out: Array[String] = []
	for stat in stat_scores.keys():
		var score = stat_scores[stat]
		var count = stat_counts.get(stat, 0)
		var pct = 50
		if count > 0:
			pct = int(((score + count) / (2.0 * count)) * 100)
		out.append("%s: %d%%" % [stat.capitalize(), pct])

	var final_text = "Results:\n" + ",".join(PackedStringArray(out))
	if status_label:
		status_label.text = final_text
	else:
		print(final_text)
