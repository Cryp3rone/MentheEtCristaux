extends CharacterBody2D

var is_chatting = false
var player_in_chat_zone = false
var player
var quest : Quest

func _ready() -> void:
	quest = QuestManager.generate_quest()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Chat"):	
		if is_chatting || !player_in_chat_zone:
			return
		
		is_chatting = true
		$Dialogue.dialogue = quest.dialogue
		$Dialogue.start_dialogue()


func _on_chat_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		player_in_chat_zone = true


func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_chat_zone = false


func _on_control_dialogue_finished() -> void:
	await get_tree().create_timer(2).timeout
	is_chatting = false
