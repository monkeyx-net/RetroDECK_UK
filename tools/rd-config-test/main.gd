extends Control

# TODO
	# Manually populating emulator values etc. These could be parsed from batch files?
	# Get $rdhome $rd_logs_folder etc values etc? Detect if if in gaming mode or Desktop Mode
	# Some Godot variables there already

func _on_command_button_pressed():
	var command = "ls"
	var parameters = ["-l", "/tmp"]
	var result = execute_command(command, parameters, false)
	$Main_TabContainer/SETTINGS/ScrollContainer/DisplayRichTextLabel.text = result["output"]
	$Main_TabContainer/SETTINGS/CommandExitLabel.text = "Exit Code: " + result["exit_code"]


# Execute an OS  command with parameters.
# This should be looked at again when GoDot 4.3 ships as has new OS.execute_with_pipe
func execute_command(command: String, params: Array, blocking: bool) -> Dictionary:
	var output = []
	var exit_code = OS.execute(command, params, output, blocking)
	# Check for errors
	output = array_to_text(output)
	
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


func array_to_text(arr: Array) -> String:
	var text = ""
	for i in arr:
		text += String(i)
	return text



func _on_emulator_button_pressed():
	var something = $Main_TabContainer/SETTINGS.get_tab_title($Main_TabContainer/SETTINGS.current_tab) + " - "
	$Main_TabContainer/SETTINGS/ScrollContainer/DisplayRichTextLabel.text= something + $Main_TabContainer/SETTINGS/OptionButton.text + "!"
