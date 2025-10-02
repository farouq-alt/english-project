extends Control

@export var CardScene: PackedScene
@export var card_anchor_path: NodePath
@export var status_label_path: NodePath

var card_anchor: Node
var status_label: Label

var questions: Array = []
var q_index: int = 0

# stats tracking
var stat_scores: Dictionary = {}
var stat_counts: Dictionary = {}

func _ready() -> void:
	# find anchor + label
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

	# FULL question set (support both static images AND yes/no animations)
	questions = [
		# --- Social ---
		{"id":1, "question":"Do you start chatting with random people just for fun?",
		 "image_yes":"res://Assets/animations-for-buttons/id1/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id1/noanim.tres",
		 "stat":"social", "yes_value":3, "no_value":-2},

		{"id":2, "question":"Would you rather stay quiet all day than join a group of new people?",
		 "image_yes":"res://Assets/animations-for-buttons/id2/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id2/noanim.tres",
		 "stat":"social", "yes_value":-3, "no_value":2},

		{"id":3, "question":"Would you volunteer to introduce yourself first in class, even if embarrassed?",
		 "image_yes":"res://Assets/animations-for-buttons/id3/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id3/noanim.tres",
		 "stat":"social", "yes_value":3, "no_value":-2},

		{"id":4, "question":"If you meet your teacher outside the class would you say Hi",
		 "image_yes":"res://Assets/animations-for-buttons/id4/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id4/noanim.tres",
		 "stat":"social", "yes_value":4, "no_value":-2},

		{"id":5, "question":"If left alone at a party, would you start talking to strangers?",
		 "image_yes":"res://Assets/animations-for-buttons/id5/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id5/noanim.tres",
		 "stat":"social", "yes_value":5, "no_value":-3},

		# --- Bravery ---
		{"id":6, "question":"Would you sing karaoke in front of your whole class if dared?",
		 "image_yes":"res://Assets/animations-for-buttons/id6/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id6/noanim.tres",
		 "stat":"bravery", "yes_value":4, "no_value":-3},

		{"id":7, "question":"If someone insults your favorite team, would you argue back loudly?",
		 "image_yes":"res://Assets/animations-for-buttons/id7/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id7/noanim.tres",
		 "stat":"bravery", "yes_value":3, "no_value":-2},

		{"id":8, "question":"Would you eat the spiciest pepper a friend dares you to?",
		 "image_yes":"res://Assets/animations-for-buttons/id8/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id8/noanim.tres",
		 "stat":"bravery", "yes_value":4, "no_value":-2},

		{"id":9, "question":"If a stray dog barks at you, would you bark back or run away?",
		 "image_yes":"res://Assets/animations-for-buttons/id9/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id9/noanim.tres",
		 "stat":"bravery", "yes_value":3, "no_value":-1},

		{"id":10, "question":"Would you laugh in a psycho's face just to see them lose it?",
		 "image_yes":"res://Assets/animations-for-buttons/id10/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id10/noanim.tres",
		 "stat":"bravery", "yes_value":5, "no_value":-3},

		# --- Politics ---
		{"id":11, "question":"Do you have wierd unpopular political opinion?",
		 "image_yes":"res://Assets/animations-for-buttons/id11/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id11/noanim.tres",
		 "stat":"politics", "yes_value":5, "no_value":-2},

		{"id":12, "question":"Would you share an unpopular political opinion in front of everyone?",
		 "image_yes":"res://Assets/animations-for-buttons/id12/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id12/noanim.tres",
		 "stat":"politics", "yes_value":5, "no_value":-4},

		{"id":13, "question":"Do you post memes just to provoke your friends?",
		 "image_yes":"res://Assets/animations-for-buttons/id13/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id13/noanim.tres",
		 "stat":"politics", "yes_value":4, "no_value":-2},

		{"id":14, "question":"Do you enjoy saying the N word?",
		 "image_yes":"res://Assets/animations-for-buttons/id14/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id14/noanim.tres",
		 "stat":"politics", "yes_value":3, "no_value":-2},

		{"id":15, "question":"Do you think yelling wins debates more than logic?",
		 "image_yes":"res://Assets/animations-for-buttons/id15/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id15/noanim.tres",
		 "stat":"politics", "yes_value":2, "no_value":-3},

		# --- Stinkiness ---
		{"id":16, "question":"Would you eat a plate of beans and eggs before class, knowing you'll sit for hours?",
		 "image_yes":"res://Assets/animations-for-buttons/id16/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id16/noanim.tres",
		 "stat":"stinkiness", "yes_value":4, "no_value":0},

		{"id":17, "question":"Would you eat a smelly sardine sandwich in a crowded room?",
		 "image_yes":"res://Assets/animations-for-buttons/id17/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id17/noanim.tres",
		 "stat":"stinkiness", "yes_value":3, "no_value":0},

		{"id":18, "question":"Do you sometimes skip deodorant on hot days?",
		 "image_yes":"res://Assets/animations-for-buttons/id18/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id18/noanim.tres",
		 "stat":"stinkiness", "yes_value":2, "no_value":-1},

		{"id":19, "question":"Have you ever laughed at your own burps or farts secretly?",
		 "image_yes":"res://Assets/animations-for-buttons/id19/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id19/noanim.tres",
		 "stat":"stinkiness", "yes_value":4, "no_value":0},

		{"id":20, "question":"Would you lend your smelly shoes to a friend if they asked?",
		 "image_yes":"res://Assets/animations-for-buttons/id20/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id20/noanim.tres",
		 "stat":"stinkiness", "yes_value":3, "no_value":-2},

		# --- Honesty ---
		{"id":21, "question":"If you fart by accident, would you admit it or blame the chair?",
		 "image_yes":"res://Assets/animations-for-buttons/id21/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id21/noanim.tres",
		 "stat":"honesty", "yes_value":3, "no_value":-3},

		{"id":22, "question":"If you ate the last cookie and nobody saw, would you admit it?",
		 "image_yes":"res://Assets/animations-for-buttons/id22/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id22/noanim.tres",
		 "stat":"honesty", "yes_value":4, "no_value":-2},

		{"id":23, "question":"Would you admit breaking a vase, or just let your sibling take the blame?",
		 "image_yes":"res://Assets/animations-for-buttons/id23/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id23/noanim.tres",
		 "stat":"honesty", "yes_value":3, "no_value":-3},

		{"id":24, "question":"Have you ever pretended to be sick just to skip class?",
		 "image_yes":"res://Assets/animations-for-buttons/id24/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id24/noanim.tres",
		 "stat":"honesty", "yes_value":-2, "no_value":3},

		{"id":25, "question":"If you spilled juice on your homework, would you confess or say the dog did it?",
		 "image_yes":"res://Assets/animations-for-buttons/id25/yesanim.tres",
		 "image_no":"res://Assets/animations-for-buttons/id25/noanim.tres",
		 "stat":"honesty", "yes_value":2, "no_value":-3},
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

	# clean previous card
	for child in card_anchor.get_children():
		child.queue_free()

	# spawn next card
	var c = CardScene.instantiate()
	card_anchor.add_child(c)
	c.connect("answered", Callable(self, "_on_card_answered"))
	c.set_question_data(questions[q_index])  # your Card scene must handle either "image" or "image_yes/no"
	q_index += 1


func _on_card_answered(choice: String, data: Dictionary) -> void:
	var stat_name = data.get("stat", "general")
	var val = data.get("yes_value", 1) if choice == "yes" else data.get("no_value", -1)

	# update stats
	stat_scores[stat_name] = stat_scores.get(stat_name, 0) + val
	stat_counts[stat_name] = stat_counts.get(stat_name, 0) + 1

	# feedback
	if status_label:
		status_label.text = "Answered %s → %s" % [choice.to_upper(), data.get("question", "")]

	await get_tree().create_timer(0.2).timeout
	spawn_card()


func _show_results() -> void:
	var out: Array[String] = []
	var top_stats: Array = []   # store tuples [stat, pct]

	var funny_titles := {
		"social": {"high":"Social Butterfly 🦋","low":"Silent Ninja 🥷"},
		"bravery":{"high":"Fearless Karaoke Hero 🎤","low":"Shy Potato 🥔"},
		"politics":{"high":"Debate Gladiator ⚔️","low":"Peaceful Observer 🕊️"},
		"stinkiness":{"high":"Gas Lord 💨","low":"Fresh Breeze 🌸"},
		"honesty":{"high":"Truth Teller 📢","low":"Sneaky Trickster 🕵️"}
	}

	var result_cards := {
		"Party Legend 🎉⚔️": preload("res://Assets/result_cards/Party Legend.png"),
		"Chatterbox Diplomat 🦋⚖️": preload("res://Assets/result_cards/Chatterbox Diplomat.png"),
		"Chatty Gas Cloud 🦋💨": preload("res://Assets/result_cards/Chatty Gas Cloud.png"),
		"Blunt Socializer 🦋📢": preload("res://Assets/result_cards/Blunt Socializer.png"),
		"Fearless Debater ⚔️⚖️": preload("res://Assets/result_cards/Fearless Debater.png"),
		"Stinkingly Brave 💨⚔️": preload("res://Assets/result_cards/Stinkingly Brave.png"),
		"Brutally Honest Hero 🎤📢": preload("res://Assets/result_cards/Brutally Honest Hero.png"),
		"Toxic Politician ⚖️💨": preload("res://Assets/result_cards/Toxic Politician.png"),
		"Politically Honest 📢⚖️": preload("res://Assets/result_cards/Politically Honest.png"),
		"Truthful Stinker 💨📢": preload("res://Assets/result_cards/Truthful Stinker.png")
	}

	for stat in stat_scores.keys():
		var score = stat_scores[stat]
		var count = stat_counts.get(stat, 0)
		if count > 0:
			var pct = int(((score + count) / (2.0 * count)) * 100)
			pct = clamp(pct, 0, 100)
			top_stats.append([stat, pct])
			var title = funny_titles.get(stat, {}).get("high" if pct >= 50 else "low", stat.capitalize())
			out.append("%s: %d%% → %s" % [stat.capitalize(), pct, title])
		else:
			out.append("%s: N/A" % stat.capitalize())

	top_stats.sort_custom(func(a, b): return b[1] - a[1])

	var combo_name := ""
	if top_stats.size() >= 2:
		var first = top_stats[0][0]
		var second = top_stats[1][0]
		combo_name = _generate_combo_name(first, second)
	elif top_stats.size() == 1:
		combo_name = top_stats[0][0].capitalize()

	# clear old
	for child in card_anchor.get_children():
		child.queue_free()

	# show PNG if exists
	if result_cards.has(combo_name):
		var tex := TextureRect.new()
		tex.texture = result_cards[combo_name]
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.expand = true
		tex.custom_minimum_size = Vector2(400, 600)
		card_anchor.add_child(tex)
	else:
		print("No PNG found for combo:", combo_name)

	var final_text = "📊 Results:\n" + "\n".join(PackedStringArray(out)) + "\n\nDominant: " + combo_name
	if status_label:
		status_label.text = final_text


func _generate_combo_name(stat1: String, stat2: String) -> String:
	var combos := {
		["social","bravery"]: "Party Legend 🎉⚔️",
		["social","politics"]: "Chatterbox Diplomat 🦋⚖️",
		["social","stinkiness"]: "Chatty Gas Cloud 🦋💨",
		["social","honesty"]: "Blunt Socializer 🦋📢",
		["bravery","politics"]: "Fearless Debater ⚔️⚖️",
		["bravery","stinkiness"]: "Stinkingly Brave 💨⚔️",
		["bravery","honesty"]: "Brutally Honest Hero 🎤📢",
		["politics","stinkiness"]: "Toxic Politician ⚖️💨",
		["politics","honesty"]: "Politically Honest 📢⚖️",
		["stinkiness","honesty"]: "Truthful Stinker 💨📢"
	}

	var key = [stat1, stat2]
	key.sort()
	for c in combos.keys():
		var k = c.duplicate()
		k.sort()
		if k == key:
			return combos[c]

	return "%s + %s" % [stat1.capitalize(), stat2.capitalize()]
	
func calculate_percentages() -> String:
	var text := "RESULTS\n\n"
	for stat in stat_scores.keys():
		var total = stat_counts.get(stat, 1)
		var score = stat_scores[stat]
		var percent = int((float(score) / float(total * 3)) * 100)
		text += "%s: %d%%\n" % [stat.capitalize(), percent]
	return text
