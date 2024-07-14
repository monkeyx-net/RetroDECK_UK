extends Control

# TODO
	# Manually populating emulator values etc. These could be parsed from batch files?
	# Get $rdhome $rd_logs_folder etc values etc? Detect if if in gaming mode or Desktop Mode
	# Some Godot variables there already
	# basic log function to show what actions have been taken and what scripts run.
	# Basic thread function added. More work required. Thread pool?

var classFunctions: ClassFunctions

func _ready() -> void:
	classFunctions = ClassFunctions.new()
	add_child(classFunctions)
	var file_path = "../../tools/configurator.sh"
	var emulator_list = get_emulator_list_from_system_path(file_path)
	print(emulator_list)

func get_emulator_list_from_system_path(file_path: String) -> Dictionary:
	var output = []
	var command = "sed -n '/local emulator_list=(/,/)/{s/.*local emulator_list=\\(.*\\)/\\1/; /)/q; p}' " + file_path
	var exit_code = OS.execute("sh", ["-c", command], output, )
	if exit_code == 0:  
		var content = classFunctions.array_to_string(output)
		return parse_emulator_list(content)
	else:
		print("Error reading file: ", exit_code)
		return {}

func parse_emulator_list(content: String) -> Dictionary:
	var emulator_dict = {}
	var regex = RegEx.new()
	regex.compile(r'"([^"]+)"\s*"([^"]+)"')
	var matches = regex.search_all(content)
	
	for match in matches:
		var name = match.get_string(1)
		var description = match.get_string(2)
		emulator_dict[name] = description
	return emulator_dict

func _on_command_button_pressed() -> void:
	var command = "ls" #"find"
	var parameters = ["-ltr", "/tmp"] #["$HOME/", "-name", "es_systems.xml","-print"]
	print (command ,parameters)
	var result: Dictionary = classFunctions.execute_command(command, parameters, false)
	if result != null:
		$Main_TabContainer/SETTINGS/ScrollContainer/DisplayRichTextLabel.text = result["output"]
		$Main_TabContainer/SETTINGS/CommandExitLabel.text = "Exit Code: " + str(result["exit_code"])

# Select one of the pre made themes for testing(Only fonts for now)
func _on_option_button_font_item_selected(index) -> void:
	#print (index)
	var custom_theme =""
	match index:
		1:
			custom_theme = preload("res://themes/pixel_theme.tres")
		2:
			custom_theme = preload("res://themes/akrobat_theme.tres")
		3:
			custom_theme = preload("res://themes/dyslexia_theme.tres")
	$Main_TabContainer.theme = custom_theme

# Make into function with string etc
func _on_emulator_button_pressed() -> void:
	$Main_TabContainer/SETTINGS/OptionButton/EmulatorButton/ConfirmationDialog.visible=true
	var something = $Main_TabContainer/SETTINGS.get_tab_title($Main_TabContainer/SETTINGS.current_tab) + " - "
	something += $Main_TabContainer/SETTINGS/ScrollContainer/DisplayRichTextLabel.text + $Main_TabContainer/SETTINGS/OptionButton.text + "!\n"
	$Main_TabContainer/SETTINGS/OptionButton/EmulatorButton/ConfirmationDialog.dialog_text= something + "\nBeware ye 'all that ENTER HERE!\nReplace with csv text"

func _on_thread_button_pressed() -> void:
	var command = "find"
	var parameters = ["$HOME/", "-name", "es_systems.xml","-print"]
	var console=false
	await run_thread_command(command, parameters, console)

func run_thread_command(command: String, parameters: Array, console: bool) -> void:
	var result = await classFunctions.run_command_in_thread(command, parameters, console)
	if result != null:
		$Main_TabContainer/SETTINGS/ScrollContainer/DisplayRichTextLabel.text = result["output"]
		$Main_TabContainer/SETTINGS/CommandExitLabel.text = "Exit Code: " + str(result["exit_code"])

func _on_item_list_item_selected(index):
	match $"Main_TabContainer/TEST TAB/ScrollContainer/VBoxContainer/ItemList".get_item_text(index):
		"OPEN EMULATOR", "RetroDECK: ABOUT":
			$"Main_TabContainer/TEST TAB/VBoxContainer".visible=false
			$"Main_TabContainer/TEST TAB/LIne1OptionButton".visible=false
			print(index)	
		"THEME":
			$"Main_TabContainer/TEST TAB/LIne1OptionButton".visible=false
			$"Main_TabContainer/TEST TAB/VBoxContainer".visible=true
		"PRESETS &  SETTINGS":
			$"Main_TabContainer/TEST TAB/VBoxContainer".visible=false
			$"Main_TabContainer/TEST TAB/LIne1OptionButton".visible=true
