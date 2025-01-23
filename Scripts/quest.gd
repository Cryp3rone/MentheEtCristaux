class_name Quest extends Node

var dialogue = []

var objectifs : Dictionary
var objectifs_status : Dictionary

var validation = []
var is_started = false
var is_complete = false

func start_quest():
	is_started = true
