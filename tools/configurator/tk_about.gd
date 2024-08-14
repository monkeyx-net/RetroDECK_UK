extends Control

#var class_functions: ClassFunctions

var website_button: Button
var changelog_button: Button
var wiki_button: Button
var credits_button: Button
var donate_button: Button
var contactus_button: Button
var licenses_button: Button
#var tk_about: Dictionary
#signal signal_theme_changed

func _ready():
	#tk_about = class_functions.import_csv_data("res://tk_about.txt")
	_get_nodes()
	_connect_signals()
	

func _get_nodes() -> void:
	website_button = get_node("%website_button")
	changelog_button = get_node("%changelog_button")
	wiki_button = get_node("%wiki_button")
	credits_button = get_node("%credits_button")
	donate_button = get_node("%donate_button")
	contactus_button = get_node("%contactus_button")
	licenses_button = get_node("%licenses_button")


func _connect_signals() -> void:
	website_button.pressed.connect(_about_button_pressed.bind("rd_web"))
	changelog_button.pressed.connect(_about_button_pressed.bind("rd_changelog"))
	wiki_button.pressed.connect(_about_button_pressed.bind("rd_wiki"))
	credits_button.pressed.connect(_about_button_pressed.bind("rd_credits"))
	donate_button.pressed.connect(_about_button_pressed.bind("rd_donate"))
	contactus_button.pressed.connect(_about_button_pressed.bind("rd_contactus"))
	licenses_button.pressed.connect(_about_button_pressed.bind("rd_licenses"))
	
func _about_button_pressed(id: String) -> void:
	match id:
		"rd_web":
			OS.shell_open(%website_button.editor_description)
		"rd_changelog":
			OS.shell_open(%changelog_button.editor_description)
		"rd_wiki":
			OS.shell_open(%wiki_button.editor_description)
		"rd_credits":
			OS.shell_open(%credits_button.editor_description)
		"rd_donate":
			OS.shell_open(%donate_button.editor_description)
		"rd_contactus":
			OS.shell_open(%contactus_button.editor_description)
		"rd_licenses":
			OS.shell_open(%licenses_button.editor_description)
		_:
			print ("ID not found")
