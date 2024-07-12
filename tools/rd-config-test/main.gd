extends Control

# TODO
	# Manually populating emulator values etc. These could be parsed from batch files?
	# Get $rdhome $rd_logs_folder etc values etc? Detect if if in gaming mode or Desktop Mode
	# Some Godot variables there already
	# basic log function to show what actions have been taken and what scripts run.


func _ready():
	var file_path = "../../tools/configurator.sh"
	var emulator_list = get_emulator_list_from_system_path(file_path)
	print(emulator_list)
		
#func threads(cmd: String, params: Array):
func cmd_thread():
	#var output = []
	#var err: int = OS.execute("find", ["$HOME/", "-name", "es_systems.xml","-print"], output, false)
	#if err != 0:
	#	print("Error occurred: %d" % err)	
	#return array_to_string(output)
	var cmd = "find"
	var params = ["$HOME/", "-name", "es_systems.xml","-print"]
	print (cmd ,params)
	var result = execute_command(cmd, params, false)
	return result
	

func get_emulator_list_from_system_path(file_path: String):
	var output = []
	var command = "sed -n '/local emulator_list=(/,/)/{s/.*local emulator_list=\\(.*\\)/\\1/; /)/q; p}' " + file_path
	var exit_code = OS.execute("sh", ["-c", command], output, )
	if exit_code == 0:  
		var content = array_to_string(output)
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

func _on_command_button_pressed():
	var command = "ls"
	var parameters = ["-ltr", "/tmp"]
	#var command = "find"
	#var parameters = ["$HOME/", "-name", "es_systems.xml","-print"]
	print (command ,parameters)
	var result = execute_command(command, parameters, false)
	$Main_TabContainer/SETTINGS/ScrollContainer/DisplayRichTextLabel.text = result["output"]
	$Main_TabContainer/SETTINGS/CommandExitLabel.text = "Exit Code: " + result["exit_code"]

# Execute an OS  command with parameters.
# This should be looked at again when GoDot 4.3 ships as has new OS.execute_with_pipe
func execute_command(command: String, params: Array, console: bool) -> Dictionary:
	var output = []
	var exit_code = OS.execute(command, params, output, console)
	# Check for errors
	output = array_to_string(output)
	
	if exit_code != OK:
		exit_code = str(exit_code)
		return {
			"error": true,
			"exit_code": str(exit_code),
			"output": output
		}
	# Return a dictionary with the exit code and output
	return {
		"error": false,
		"exit_code": str(exit_code),
		"output": output
	}
	
# Select one of the pre made themes for testing(Only fonts for now)
func _on_option_button_font_item_selected(index):
	print (index)
	var custom_theme =""
	match index:
		1:
			custom_theme = preload("res://themes/pixel_theme.tres")
			$Main_TabContainer.theme = custom_theme
		2:
			custom_theme = preload("res://themes/akrobat_theme.tres")
			$Main_TabContainer.theme = custom_theme
		3:
			custom_theme = preload("res://themes/dyslexia_theme.tres")
			$Main_TabContainer.theme = custom_theme

func array_to_string(arr: Array) -> String:
	var text = ""
	for line in arr:
		text += line + "\n"
	return text

func _on_emulator_button_pressed():
	$Main_TabContainer/SETTINGS/OptionButton/EmulatorButton/ConfirmationDialog.visible=true
	var something = $Main_TabContainer/SETTINGS.get_tab_title($Main_TabContainer/SETTINGS.current_tab) + " - "
	$Main_TabContainer/SETTINGS/ScrollContainer/DisplayRichTextLabel.text= something + $Main_TabContainer/SETTINGS/OptionButton.text + "!"

func _on_thread_button_pressed():
	var command = "find"
	var parameters = ["$HOME/", "-name", "es_systems.xml","-print"]
	var thread = Thread.new()
	print ("THREAD START")
	thread.start(Callable(self, "cmd_thread"))
	#thread.start(thread.bin)
	while thread.is_alive():
		print ("tick")
		await get_tree().process_frame
	var result = thread.wait_to_finish()
	#print(result)
	print ("THREAD END")
	# add check if array/dict null
	$Main_TabContainer/SETTINGS/ScrollContainer/DisplayRichTextLabel.text = result["output"]
	$Main_TabContainer/SETTINGS/CommandExitLabel.text = "Exit Code: " + result["exit_code"]
	thread = null

