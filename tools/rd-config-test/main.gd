extends Control

# TODO
	# Manually populating emulator values etc. These could be parsed from batch files?
	# Get $rdhome $rd_logs_folder etc values etc? Detect if if in gaming mode or Desktop Mode
	# Some Godot variables there already
	# basic log function to show what actions have been taken and what scripts run.
	# Basic thread function added. More work required. Thread pool?
@onready var image_display = $ImageDisplay
@onready var http_request = $HTTPRequest
var classFunctions: ClassFunctions

func _ready() -> void:
	$Main_TabContainer/SETTINGS.grab_focus()

	classFunctions = ClassFunctions.new()
	add_child(classFunctions)
	var file_path = "../../tools/configurator.sh"
	var command = "sed -n '/local emulator_list=(/,/)/{s/.*local emulator_list=\\(.*\\)/\\1/; /)/q; p}' "
	var emulator_list = classFunctions.get_text_file_from_system_path(file_path,command)
	print(emulator_list)

func _process(delta):
	if Input.is_action_pressed("SpaceBar"):
		print ("pressed")
		update_progress_bar()
	else: 
		$Main_TabContainer/SETTINGS/EmulatorsOptionButton/EmulatorButton/ConfirmationDialog/ProgressBar.value=0

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
	OS.shell_open("https://retrodeck.readthedocs.io/en/latest/wiki_emulator_guides/retroarch/retroarch-guide/")
	#$Main_TabContainer/SETTINGS/EmulatorsOptionButton/EmulatorButton/ConfirmationDialog.visible=true
	#var something = "\n\n" + $Main_TabContainer/SETTINGS.get_tab_title($Main_TabContainer/SETTINGS.current_tab) + " - "
	#something +=  $Main_TabContainer/SETTINGS/EmulatorsOptionButton.text + "!"
	#$Main_TabContainer/SETTINGS/EmulatorsOptionButton/EmulatorButton/ConfirmationDialog.dialog_text= something
	
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

func _on_item_list_item_selected(index) -> void:
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


func _on_confirmation_dialog_confirmed() -> void:
	OS.execute("../../tools/retrodeck_function_wrapper.sh", ["log", "i", "Configurator: " + $Main_TabContainer/SETTINGS/OptionButton.text])
	#OS.create_process("/home/tim/Applications/RetroArch-Linux-x86_64.AppImage",[])
	OS.execute("/home/tim/Applications/RetroArch-Linux-x86_64.AppImage",[])

func update_progress_bar() -> void:
	$Main_TabContainer/SETTINGS/OptionButton/EmulatorButton/ConfirmationDialog/ProgressBar.value += 1  #Button is pressed, increase the progress
	await get_tree().create_timer(1.0).timeout # wait for 1 second

func _on_http_request_request_completed(_result, _response_code, _headers, body) -> void:
	image_display.texture = classFunctions.process_url_image(body)

func _on_achieve_button_pressed() -> void:
	var url = "https://retroachievements.org/Badge/451988.png"
	http_request.request(url)
