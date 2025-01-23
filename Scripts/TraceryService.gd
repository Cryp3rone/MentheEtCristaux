extends Node


enum TEXT_TYPE {INTRO, Q1, Q2, COUT, VALID}

var PATH = "res://Resources/JSONData/textData.json"
var INTRO_PATH = "res://Resources/JSONData/intro.json"
var Q1_PATH = "res://Resources/JSONData/q1.json"
var Q2_PATH = "res://Resources/JSONData/q2.json"
var COUT_PATH = "res://Resources/JSONData/cout.json"
var VALID_PATH = "res://Resources/JSONData/valid.json"

var questValues : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print_debug(generate_text(INTRO_PATH))
	print_debug(generate_text(INTRO_PATH))
	print_debug(generate_text(INTRO_PATH))
	
	print_debug(generate_text(Q1_PATH))
	print_debug(generate_text(Q1_PATH))
	print_debug(generate_text(Q1_PATH))
	
	print_debug(generate_text(Q2_PATH))
	print_debug(generate_text(Q2_PATH))
	print_debug(generate_text(Q2_PATH))
	
	print_debug(generate_text(COUT_PATH))
	print_debug(generate_text(COUT_PATH))
	print_debug(generate_text(COUT_PATH))
	
	print_debug(generate_text(VALID_PATH))
	print_debug(generate_text(VALID_PATH))
	print_debug(generate_text(VALID_PATH))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func open_dict(path : String) -> Dictionary:
	var parsed_text = null

	if !FileAccess.file_exists(path):
		push_error("file JSON doens't exist")
		return {"error": true, "errormessage": "file JSON doens't exist"}

	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	parsed_text = JSON.parse_string(text)

	if parsed_text == null || !parsed_text is Dictionary:
		return {"error": true, "errormessage": "parsed failed"}

	return parsed_text

func generate_text(path : String) -> String:
	var input = open_dict(path)

	if input.has("error") && input["error"].value:
		print_debug(input["errormessage"].value)
		return ""

	var assign_regex = RegEx.new()
	assign_regex.compile(r"\[(\w+):#(\w+)#\]")

	var final_text = input["origin"].pick_random()
	
	for match in assign_regex.search_all(final_text):
		var key = match.get_string(1)
		var value = input[match.get_string(2)].pick_random()

		questValues[key] = value

		var pos = final_text.find(match.get_string(0))
		var leng =  match.get_string(0).length()
		
		if pos > -1:
			final_text = final_text.substr(0, pos) + final_text.substr(pos + leng, final_text.length() - (pos + leng))

	return tag_recursive_generation(final_text, input)

func tag_recursive_generation(input : String, grammar_dict : Dictionary) -> String:
	var assign_regex = RegEx.new()
	assign_regex.compile(r"#([\w\.]+)#")

	for match in assign_regex.search_all(input):
		var tag = match.get_string(1)
		var modifier

		if tag.contains("."):
			var tag_split = tag.split(".")
			tag = tag_split[0]
			modifier = tag_split[1]

		var value 

		if grammar_dict.has(tag):
			value = grammar_dict[tag].pick_random()
		elif questValues.has(tag):
			value = questValues[tag]
		else:
			value = tag

		if modifier != null && modifier == "capitalize":
			value = value.substr(0, 1).to_upper() + value.substr(1, value.length() - 1)

		if assign_regex.search(value):
			value = tag_recursive_generation(value, grammar_dict)

		if modifier != null:
			input = input.replace("#" + tag + "." + modifier + "#", value)
		else:
			input = input.replace("#" + tag + "#", value)

	return input
