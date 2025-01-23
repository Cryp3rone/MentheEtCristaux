class_name Dialogue extends Control

signal dialogue_finished

var dialogue = []
var dialogue_id
var d_active = false

func _ready() -> void:
	$NinePatchRect.visible = false

func _input(event: InputEvent) -> void:
	if !d_active:
		return

	if event.is_action_pressed("Chat"):
		next_script()

func start_dialogue():
	if d_active:
		return

	d_active = true
	$NinePatchRect.visible = true
	dialogue_id = -1
	next_script()

func next_script():
	dialogue_id += 1
	if dialogue_id >= dialogue.size():
		d_active = false
		$NinePatchRect.visible = false
		emit_signal("dialogue_finished")
		return

	$NinePatchRect/RichTextLabel.text = dialogue[dialogue_id]
