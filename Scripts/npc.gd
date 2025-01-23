extends CharacterBody2D

var is_chatting = false
var player_in_chat_zone = false
var player
var quest : Quest

func _ready() -> void:
	quest = QuestManager.generate_quest()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Chat"):
		is_chatting = true

func _on_chat_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		player_in_chat_zone = true


func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_chat_zone = false
