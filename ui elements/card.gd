# res://scripts/Card.gd
extends Control
class_name myCard

signal answered(choice: String, data: Dictionary)

@onready var question_label := $Panel/cardframe/casetextholder/textholder/question
@onready var sprite := $Panel/cardframe/casetextholder/Control/AnimatedSprite2D
@onready var image_rect := $Panel/cardframe/caseimgholder/noframe/image
@onready var image_rect2 := $Panel/cardframe/caseimgholder/yesframe/image
@onready var lbutton := $Panel/cardframe2/buttoncontainer/lbutton
@onready var rbutton := $Panel/cardframe2/buttoncontainer/rbutton

# tweakable
@export var typing_speed: float = 0.035

var typing_timer: Timer
var full_text: String = ""
var current_index: int = 0
var current_data: Dictionary = {}



func _ready() -> void:
	# create typing timer
	typing_timer = Timer.new()
	typing_timer.wait_time = typing_speed
	typing_timer.one_shot = false
	typing_timer.connect("timeout", Callable(self, "_on_typing_tick"))
	add_child(typing_timer)

	# connect buttons
	lbutton.connect("pressed", Callable(self, "_on_lbutton_pressed"))
	rbutton.connect("pressed", Callable(self, "_on_rbutton_pressed"))

	# clear initially
	question_label.text = ""

func set_question_data(data: Dictionary) -> void:
	current_data = data.duplicate(true)

	# reset text typing
	if not typing_timer.is_stopped():
		typing_timer.stop()
	full_text = current_data.get("question", "")
	current_index = 0
	question_label.text = ""

	# load "no" image
	var no_img = current_data.get("image_no", "")
	if no_img != "" and ResourceLoader.exists(no_img):
		image_rect.texture = load(no_img)
		image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# load "yes" image
	var yes_img = current_data.get("image_yes", "")
	if yes_img != "" and ResourceLoader.exists(yes_img):
		image_rect2.texture = load(yes_img)
		image_rect2.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# play sprite animation + start typing
	if sprite:
		sprite.play("calm")
	typing_timer.start()


func _on_typing_tick() -> void:
	if current_index < full_text.length():
		# append one character
		question_label.text += full_text[current_index]
		current_index += 1
	else:
		typing_timer.stop()
		if sprite:
			sprite.play("idle")

func _finish_typing() -> void:
	# stops timer and writes the full text immediately
	if typing_timer and typing_timer.is_stopped() == false:
		typing_timer.stop()
		question_label.text = full_text
		if sprite:
			sprite.play("idle")

func _on_lbutton_pressed() -> void:
	_finish_typing()
	emit_signal("answered", "no", current_data)
	queue_free()

func _on_rbutton_pressed() -> void:
	_finish_typing()
	emit_signal("answered", "yes", current_data)
	queue_free()
