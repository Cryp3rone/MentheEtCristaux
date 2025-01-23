extends Node

signal score_updated(tag, val)

var quests = []

func generate_quest() -> Quest:
	var quest = Quest.new()
	var quest_data : Dictionary

	quest.dialogue.push_back(TraceryService.generate_text(TraceryService.INTRO_PATH, false, quest_data))

	quest.dialogue.push_back(TraceryService.generate_text(TraceryService.Q1_PATH, true, quest_data))

	for data in quest_data:
		quest.objectifs[data] = quest_data[data]
		Room_Generator.Instance.add_enemy_to_priority_list(data, quest_data[data])
		quest.objectifs_status[data] = 0

	quest.dialogue.push_back(TraceryService.generate_text(TraceryService.COUT_PATH, false, quest_data))
	quest.validation.push_back(TraceryService.generate_text(TraceryService.VALID_PATH, false, quest_data))

	quests.push_back(quest)
	return quest

func update_quest(tag : String):
	for quest in quests:
		if quest.objectifs.has(tag):
			quest.objectifs_status[tag] = quest.objectifs_status[tag] + 1

			for objectif in quest.objectifs:
				if objectif.value == quest.objectifs_status[objectif.key].value :
					quest.is_complete = true

			emit_signal("score_updated", tag, quest.objectifs_status[tag])
