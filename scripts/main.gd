extends Control  

@export var CardScene: PackedScene  
@export var card_anchor_path: NodePath        # assign in Inspector  
@export var status_label_path: NodePath       # assign in Inspector  

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

	# Full set of funny/edgy questions (5 each)  
	questions = [  
		# --- Social ---  
		{"id":1, "question":"Do you like starting random conversations with strangers?", "image":"res://Assets/imagetoquestion/social1.jpg", "stat":"social", "yes_value":3, "no_value":-2},  
		{"id":2, "question":"Would you rather sit quietly all day than talk to a group of new people?", "image":"res://Assets/imagetoquestion/social2.jpg", "stat":"social", "yes_value":-3, "no_value":2},  
		{"id":3, "question":"Would you volunteer to introduce yourself first in class?", "image":"res://Assets/imagetoquestion/social3.jpg", "stat":"social", "yes_value":3, "no_value":-2},  
		{"id":4, "question":"Do you overshare personal stories without being asked?", "image":"res://Assets/imagetoquestion/social4.jpg", "stat":"social", "yes_value":4, "no_value":-2},  
		{"id":5, "question":"If left alone at a party, would you approach random people instead of hiding in the bathroom?", "image":"res://Assets/imagetoquestion/social5.jpg", "stat":"social", "yes_value":5, "no_value":-3},  

		# --- Bravery ---  
		{"id":6, "question":"Would you sing karaoke in front of your whole class if dared?", "image":"res://Assets/imagetoquestion/bravery1.jpg", "stat":"bravery", "yes_value":4, "no_value":-3},  
		{"id":7, "question":"If your teacher says something you strongly disagree with, do you speak up?", "image":"res://Assets/imagetoquestion/bravery2.jpg", "stat":"bravery", "yes_value":3, "no_value":-2},  
		{"id":8, "question":"Would you eat the spiciest pepper your friends hand you, without hesitation?", "image":"res://Assets/imagetoquestion/bravery3.jpg", "stat":"bravery", "yes_value":4, "no_value":-2},  
		{"id":9, "question":"If a random dog barked at you on the street, would you bark back?", "image":"res://Assets/imagetoquestion/bravery4.jpg", "stat":"bravery", "yes_value":3, "no_value":-1},  
		{"id":10, "question":"Would you admit a crush in front of the whole class if challenged?", "image":"res://Assets/imagetoquestion/bravery5.jpg", "stat":"bravery", "yes_value":5, "no_value":-3},  

		# --- Politics ---  
		{"id":11, "question":"Do you openly argue about politics in public even if it gets heated?", "image":"res://Assets/imagetoquestion/politics1.jpg", "stat":"politics", "yes_value":5, "no_value":-2},  
		{"id":12, "question":"Would you share a very unpopular political opinion in front of everyone?", "image":"res://Assets/imagetoquestion/politics2.jpg", "stat":"politics", "yes_value":5, "no_value":-4},  
		{"id":13, "question":"Do you ever post political memes knowing they’ll start fights?", "image":"res://Assets/imagetoquestion/politics3.jpg", "stat":"politics", "yes_value":4, "no_value":-2},  
		{"id":14, "question":"Would you argue with your family at dinner about politics just to prove a point?", "image":"res://Assets/imagetoquestion/politics4.jpg", "stat":"politics", "yes_value":3, "no_value":-2},  
		{"id":15, "question":"Do you believe debates should be won with louder volume, not logic?", "image":"res://Assets/imagetoquestion/politics5.jpg", "stat":"politics", "yes_value":2, "no_value":-3},  

		# --- Stinkiness ---  
		{"id":16, "question":"Have you ever farted in class on purpose, just to see reactions?", "image":"res://Assets/imagetoquestion/stink1.jpg", "stat":"stinkiness", "yes_value":4, "no_value":0},  
		{"id":17, "question":"Would you ever eat something smelly (like tuna or eggs) in a packed classroom?", "image":"res://Assets/imagetoquestion/stink2.jpg", "stat":"stinkiness", "yes_value":2, "no_value":0},  
		{"id":18, "question":"Do you think deodorant is optional on hot days?", "image":"res://Assets/imagetoquestion/stink3.jpg", "stat":"stinkiness", "yes_value":3, "no_value":-2},  
		{"id":19, "question":"Have you ever secretly enjoyed your own farts?", "image":"res://Assets/imagetoquestion/stink4.jpg", "stat":"stinkiness", "yes_value":4, "no_value":0},  
		{"id":20, "question":"If your shoe smells bad, would you still let your friend borrow it?", "image":"res://Assets/imagetoquestion/stink5.jpg", "stat":"stinkiness", "yes_value":3, "no_value":-2},  

		# --- Honesty ---  
		{"id":21, "question":"If you fart in class 'by accident', would you admit it was you?", "image":"res://Assets/imagetoquestion/honesty1.jpg", "stat":"honesty", "yes_value":3, "no_value":-3},  
		{"id":22, "question":"If you saw your friend cheat in an exam, would you tell the teacher?", "image":"res://Assets/imagetoquestion/honesty2.jpg", "stat":"honesty", "yes_value":4, "no_value":-2},  
		{"id":23, "question":"Would you admit to breaking something in class even if nobody saw?", "image":"res://Assets/imagetoquestion/honesty3.jpg", "stat":"honesty", "yes_value":3, "no_value":-3},  
		{"id":24, "question":"Have you ever lied to get out of doing homework?", "image":"res://Assets/imagetoquestion/honesty4.jpg", "stat":"honesty", "yes_value":-2, "no_value":3},  
		{"id":25, "question":"If you got away with copying answers, would you confess later?", "image":"res://Assets/imagetoquestion/honesty5.jpg", "stat":"honesty", "yes_value":2, "no_value":-3}  
	]  

	q_index = 0  
	stat_scores.clear()  
	stat_counts.clear()  

	spawn_card()  

func spawn_card() -> void:  
	# finished?  
	if q_index >= questions.size():  
		_show_results()  
		return  

	if not CardScene:  
		push_error("CardScene not set in inspector.")  
		return  

	# clean previous card if needed  
	for child in card_anchor.get_children():  
		child.queue_free()  

	# spawn next card  
	var c = CardScene.instantiate()  
	card_anchor.add_child(c)  
	c.connect("answered", Callable(self, "_on_card_answered"))  
	c.set_question_data(questions[q_index])  
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
	var top_stats: Array = []  # store tuples [stat, pct]  

	# funny titles  
	var funny_titles := {  
		"social": {"high":"Social Butterfly 🦋","low":"Silent Ninja 🥷"},  
		"bravery":{"high":"Fearless Karaoke Hero 🎤","low":"Shy Potato 🥔"},  
		"politics":{"high":"Debate Gladiator ⚔️","low":"Peaceful Observer 🕊️"},  
		"stinkiness":{"high":"Gas Lord 💨","low":"Fresh Breeze 🌸"},  
		"honesty":{"high":"Truth Teller 📢","low":"Sneaky Trickster 🕵️"}  
	}  

	# calculate stats  
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

	# sort  
	top_stats.sort_custom(func(a, b): return b[1] - a[1])  

	# dominant  
	var dominant_text = ""  
	if top_stats.size() >= 2:  
		var first = top_stats[0][0]  
		var second = top_stats[1][0]  
		dominant_text = "Dominant Class: %s + %s = %s" % [  
			first.capitalize(), second.capitalize(), _generate_combo_name(first, second)  
		]  
	elif top_stats.size() == 1:  
		dominant_text = "Dominant Class: %s" % top_stats[0][0].capitalize()  

	var final_text = "📊 Results:\n" + "\n".join(PackedStringArray(out)) + "\n\n" + dominant_text  
	if status_label:  
		status_label.text = final_text  
	else:  
		print(final_text)  

func _generate_combo_name(stat1: String, stat2: String) -> String:  
	var combos := {  
		["stinkiness","bravery"]: "Stinkingly Brave 💨⚔️",  
		["bravery","honesty"]: "Brutally Honest Hero 🎤📢",  
		["social","stinkiness"]: "Chatty Gas Cloud 🦋💨",  
		["politics","honesty"]: "Politically Honest 📢⚖️",  
		["social","bravery"]: "Party Legend 🎉⚔️",  
		["honesty","stinkiness"]: "Truthful Stinker 💨📢"  
	}  

	var key = [stat1, stat2]  
	key.sort()  

	for c in combos.keys():  
		var k = c.duplicate()  
		k.sort()  
		if k == key:  
			return combos[c]  

	return "%s + %s" % [stat1.capitalize(), stat2.capitalize()]  
