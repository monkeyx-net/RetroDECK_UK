extends Control

# TODO
	# Manually populating emulator values etc. These could be parsed from batch files?
	# Get $rdhome $rd_logs_folder etc values etc? Detect if if in gaming mode or Desktop Mode
	# Some Godot variables there already
	# basic log function to show what actions have been taken and what scripts run.
	# Basic thread function added. More work required. Thread pool?
@onready var image_display = $ImageDisplay
@onready var http_request = $HTTPRequest
@onready var rekku = $AnimatedSprite2D

var classFunctions: ClassFunctions
var main_tabcontainer : TabContainer
var tab_settings: TabBar
var command_label : Label
var richtext_label :RichTextLabel
var emu_optionbutton : OptionButton
var action_optionbutton: OptionButton
var window_dialogue: Window

func _ready() -> void:
	$Main_TabContainer/SETTINGS.grab_focus()
	_get_nodes()
	_connect_signals()
	classFunctions = ClassFunctions.new()
	add_child(classFunctions)
	rekku.play("idle")
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

func _get_nodes() -> void:
	main_tabcontainer = get_node("%Main_TabContainer")
	tab_settings = get_node("%SETTINGS")
	command_label = get_node("%CommandExitLabel")
	richtext_label = get_node("%DisplayRichTextLabel")
	emu_optionbutton = get_node("%EmulatorsOptionButton")
	action_optionbutton = get_node("%ActionsOptionButton")
	window_dialogue = get_node("%Window")
	

func _connect_signals() -> void:
	window_dialogue.close_requested.connect(_on_close_window)
	#window_dialogue.connect("close_requested", _on_close_window)

func _on_command_button_pressed() -> void:
	rekku.play("chat")
	window_dialogue.visible=true
	var command = "ls" #"find"
	var parameters = ["-ltr", "/tmp"] #["$HOME/", "-name", "es_systems.xml","-print"]
	print (command ,parameters)
	var result: Dictionary = classFunctions.execute_command(command, parameters, false)
	if result != null:
		richtext_label.text = result["output"]
		
		command_label.text = "Exit Code: " + str(result["exit_code"])

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
	main_tabcontainer.theme = custom_theme

# Make into function with string etc
func _on_emulator_button_pressed() -> void:
	# Add check for confirmation dialugue true
	var selected_item_1 = emu_optionbutton.get_item_text(emu_optionbutton.selected)
	var selected_item_2 = action_optionbutton.get_item_text(action_optionbutton.selected)
	print (selected_item_1, selected_item_2)
	match selected_item_1:
		"Select Emulator":
			print ("Call pick valid option")
		"RetroArch":
			match selected_item_2:
				"Pick Action":
					print ("Call pick valid option")
				"Help":
					print ("Call Help Function")
					classFunctions.launch_help("https://retrodeck.readthedocs.io/en/latest/wiki_emulator_guides/retroarch/retroarch-guide/")
				"Launch":
					print ("Call Launch Function/Dialogue")
				"Reset":
					print ("Call Reset Function/Dialogue")
				_:
					print ("Call pick valid option")
		"MAME":
			match selected_item_2:
				"Pick Action":
					print ("Call pick valid option")
				"Help":
					print ("Call Help Function")
					classFunctions.launch_help("https://retrodeck.readthedocs.io/en/latest/wiki_emulator_guides/mame/mame-guide/")
				"Launch":
					print ("Call Launch Function/Dialogue")
				"Reset":
					print ("Call Reset Function/Dialogue")
				_:
					print ("Call pick valid option")
			
			print ("Call pick valid option")
	#dialgue todo	
	$Main_TabContainer/SETTINGS/EmulatorsOptionButton/EmulatorButton/ConfirmationDialog.visible=true
	var something = "\n\n" + tab_settings.get_tab_title(tab_settings.current_tab) + " - "
	something +=  $Main_TabContainer/SETTINGS/EmulatorsOptionButton.text + "!"
	$Main_TabContainer/SETTINGS/EmulatorsOptionButton/EmulatorButton/ConfirmationDialog.dialog_text= something
	
func _on_thread_button_pressed() -> void:
	var command = "find"
	var parameters = ["$HOME/", "-name", "es_systems.xml","-print"]
	var console=false
	await run_thread_command(command, parameters, console)

func run_thread_command(command: String, parameters: Array, console: bool) -> void:
	var result = await classFunctions.run_command_in_thread(command, parameters, console)
	if result != null:
		richtext_label.text = result["output"]
		command_label.text = "Exit Code: " + str(result["exit_code"])

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
	var command = "../../tools/retrodeck_function_wrapper.sh"
	var parameters = ["log", "i", "Configurator: " + $Main_TabContainer/SETTINGS/EmulatorsOptionButton.text]
	var result: Dictionary = classFunctions.execute_command(command, parameters, false)
	# add if not error?
	#OS.create_process("/home/tim/Applications/RetroArch-Linux-x86_64.AppImage",[])
	command = "  /home/tim/Applications/RetroArch-Linux-x86_64.AppImage"
	parameters=[]
	result = classFunctions.execute_command(command, parameters, false)

func update_progress_bar() -> void:
	$Main_TabContainer/SETTINGS/EmulatorsOptionButton/EmulatorButton/ConfirmationDialog/ProgressBar.value += 1  #Button is pressed, increase the progress
	await get_tree().create_timer(1.0).timeout # wait for 1 second

func _on_http_request_request_completed(_result, _response_code, _headers, body) -> void:
	image_display.texture = classFunctions.process_url_image(body)

func _on_achieve_button_pressed() -> void:
	var url = "https://retroachievements.org/Badge/451988.png"
	http_request.request(url)

func _on_close_window() -> void:
	window_dialogue.visible=false

