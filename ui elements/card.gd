extends Control

@onready var question_label: Label = $Panel/cardframe/casetextholder/textholder/question
@onready var sprite: AnimatedSprite2D = $Panel/cardframe/casetextholder/Control/AnimatedSprite2D

var full_text: String = ""
var current_index: int = 0
var typing_speed: float = 0.04  # seconds per character
var typing_timer: Timer

func _ready() -> void:
	# Add a Timer dynamically for typing
	typing_timer = Timer.new()
	typing_timer.wait_time = typing_speed
	typing_timer.one_shot = false
	typing_timer.connect("timeout", Callable(self, "_on_typing_tick"))
	add_child(typing_timer)

	# Example: start a question on ready
	show_question("Do you take care when you wake up in the morning before coming to class?")

func show_question(text: String) -> void:
	full_text = text
	current_index = 0
	question_label.text = ""
	sprite.play("calm")
	typing_timer.start()

func _on_typing_tick() -> void:
	if current_index < full_text.length():
		question_label.text += full_text[current_index]
		current_index += 1
	else:
		typing_timer.stop()
		sprite.play("idle")
