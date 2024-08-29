#todo
# add cores as class/ Like eumlator but one level lower

extends Control

var bios_type:int
var status_code_label: Label
var log_results: Dictionary
var theme_option: OptionButton
#signal signal_theme_changed
var custom_theme: Theme = $".".theme
var log_option: OptionButton
var tab_container: TabContainer
var anim_logo: AnimatedSprite2D
var rd_logs: String
var rd_version: String
var gc_version: String
var dialogue_title: String
var dialogue_content: String
var dialogue_command: String
var dialogue_parameters: Array
var l1_button_texture: Texture2D = load("res://assets/icons/kenney_input-prompts-pixel-16/Tiles/tile_0797.png")
var r1_button_texture: Texture2D = load("res://assets/icons/kenney_input-prompts-pixel-16/Tiles/tile_0798.png")
var a_button_texture: Texture2D = load("res://assets/icons/kenney_input-prompts-pixel-16/Tiles/tile_0042.png")
var b_button_texture: Texture2D = load("res://assets/icons/kenney_input-prompts-pixel-16/Tiles/tile_0043.png")
var app_data := AppData.new()
var dialogue_mode: bool = false

func _ready():
	_get_nodes()
	_connect_signals()
	_play_main_animations()
	var args = OS.get_cmdline_args()
	for arg in range(args.size()):
		if args[arg] == "--dialogue" and arg + 1 < args.size():
			dialogue_mode = true
		elif args[arg] == "--title" and arg + 1 < args.size():
			dialogue_title = args[arg + 1]
		elif args[arg] == "--content" and arg + 1 < args.size():
			dialogue_content = args[arg + 1]
		elif args[arg] == "--command" and arg + 1 < args.size():
			dialogue_command = args[arg + 1]
		elif args[arg] == "--parameters" and arg + 1 < args.size():
			dialogue_parameters.append(args[arg + 1])
		elif args[arg] == "--fullscreen" and arg + 1 < args.size():
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
	if dialogue_mode:
		load_and_change_scene("res://components/popup_dialogue.tscn")		
	#%locale_option.selected = class_functions.map_locale_id(OS.get_locale_language())
	#app_data = data_handler.app_data
	#data_handler.add_emulator()
	#data_handler.modify_emulator_test()
	#if app_data:
		#var website_data: Link = app_data.about_links["rd_web"]
		#print (website_data.name,"-",website_data.url,"-",website_data.description,"-",website_data.url)
		##print (app_data.about_links["rd_web"]["name"])
		#var core_data: Core = app_data.cores["gambatte_libetro"]
		#print (core_data.name)
		#for property: CoreProperty in core_data.properties:
			#print("Cheevos: ", property.cheevos)
			#print("Cheevos Hardcore: ", property.cheevos_hardcore)
			#print("Quick Resume: ", property.quick_resume)
			#print("Rewind: ", property.rewind)
			#print("Borders: ", property.borders)
			#print("Widescreen: ", property.widescreen)
			#print("ABXY_button:", property.abxy_button)
		#for key in app_data.emulators.keys():
			#var emulator = app_data.emulators[key]
			## Display the properties of each emulator
			#print("System Name: ", emulator.name)
			#print("Description: ", emulator.description)
			#print("Properties:")
			#for property: EmulatorProperty in emulator.properties:
				#print("Cheevos: ", property.cheevos)
				#print("Borders: ", property.borders)
				#print("ABXY_button:", property.abxy_button)
				#print("multi_user_config_dir: ", property.multi_user_config_dir)
		#
		#for key in app_data.retroarch_cores.keys():
			#var core = app_data.retroarch_cores[key]
			#print("Core Name: ", core.name)
			#print("Description: ", core.description)
			#print("Properties:")
			#for property: CoreProperty in core.properties:
				#print("Cheevos: ", property.cheevos)
				#print("Cheevos Hardcore: ", property.cheevos_hardcore)
				#print("Quick Resume: ", property.quick_resume)
				#print("Rewind: ", property.rewind)
				#print("Borders: ", property.borders)
				#print("Widescreen: ", property.widescreen)
				#print("ABXY_button:", property.abxy_button)
	#else:
		#print ("No emulators")

	var config_file_path = "/var/config/retrodeck/retrodeck.cfg"
	var json_file_path = "/var/config/retrodeck/retrodeck.json"
	var config = data_handler.parse_config_to_json(config_file_path)
	data_handler.config_save_json(config, json_file_path)
	rd_logs = config["paths"]["logs_folder"]
	rd_version = config["version"]
	gc_version = ProjectSettings.get_setting("application/config/version")
	%rd_title.text+= "\n   " + rd_version + "\nConfigurator\n    " + gc_version
	
	#var log_file = class_functions.import_text_file(rd_logs +"/retrodeck.log")
	#for id in config.paths:
	#	var path_data = config.paths[id]
	#	print (id)

	# set current startup tab to match IDE	
	tab_container.current_tab = 0
	#add_child(class_functions) # Needed for threaded results Not need autoload?
	var children = findElements(self, "Control")
	for n: Control in children: #iterate the children
		if (n.focus_mode == FOCUS_ALL):
			n.mouse_entered.connect(_on_control_mouse_entered.bind(n)) #grab focus on mouse hover
		if (n.is_class("BaseButton") and n.disabled == true): #if button-like control and disabled
			n.self_modulate.a = 0.5 #make it half transparent
	combine_tkeys()

func load_and_change_scene(scene_load: String):
	var popup = load(scene_load).instantiate() as Control
	if dialogue_title != "":
		popup.set_title(dialogue_title)
	if dialogue_content != "":
		popup.set_content(dialogue_content)
	if dialogue_command != "":
		popup.set_ok_command(dialogue_command)
	if dialogue_parameters != []:
		popup.set_parameters(dialogue_parameters)
	$Background.add_child(popup)

	#var scene = ResourceLoader.load(scene_load)
	#get_tree().change_scene_to_packed(scene)


func _input(event):
	if Input.is_action_pressed("quit1") and Input.is_action_pressed("quit2"):
		get_tree().quit()
	if Input.is_action_pressed("next_tab"):
		%r1_button.texture_normal = %r1_button.texture_pressed
	elif Input.is_action_pressed("previous_tab"):
		%l1_button.texture_normal = %l1_button.texture_pressed
	elif Input.is_action_pressed("back_button"):
		%b_button.texture_normal = %b_button.texture_pressed
	elif Input.is_action_pressed("action_button"):
		%a_button.texture_normal = %a_button.texture_pressed
	else:
		%r1_button.texture_normal = r1_button_texture
		%l1_button.texture_normal = l1_button_texture
		%a_button.texture_normal = a_button_texture
		%b_button.texture_normal = b_button_texture
	if event.is_action_pressed("quit"):
		_exit()

func _exit():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _get_nodes() -> void:
	status_code_label = get_node("%status_code_label")
	theme_option = get_node("%theme_optionbutton")
	tab_container = get_node("%TabContainer")
	anim_logo = get_node("%logo_animated")
	log_option = get_node("%logs_button")
	
func _connect_signals() -> void:
	#signal_theme_changed.connect(_conf_theme)
	theme_option.item_selected.connect(_conf_theme)
	#signal_theme_changed.emit(theme_option.item_selected)
	log_option.item_selected.connect(_load_log)
	%borders_button.pressed.connect(_hide_show_buttons.bind(%borders_button,%borders_gridcontainer,%decorations_gridcontainer))
	%button_layout.pressed.connect(_hide_show_buttons.bind(%button_layout,%borders_gridcontainer,%decorations_gridcontainer))
	%decorations_save.pressed.connect(_hide_show_buttons.bind(%decorations_save,%decorations_save.get_parent(),null))
	%decorations_button.pressed.connect(_hide_show_containers.bind(%decorations_button, %decorations_gridcontainer))
	%systems_button.pressed.connect(_hide_show_containers.bind(%systems_button, %systems_gridcontainer))
	%save_resume_button.pressed.connect(_hide_show_containers.bind(%decorations_button,%systems_gridcontainer))

func _load_log(index: int) -> void:
	var log_content:String
	match index:
		1: 
			class_functions.log_parameters[2] = class_functions.log_text + "Loading RetroDeck log"
			class_functions.execute_command(class_functions.wrapper_command,class_functions.log_parameters, false)
			log_content = class_functions.import_text_file(rd_logs +"/retrodeck.log")
			load_popup("RetroDeck Log", "res://components/logs_view/logs_popup_content.tscn", log_content)
		2:
			class_functions.log_parameters[2] = class_functions.log_text + "Loading ES-DE log"
			class_functions.execute_command(class_functions.wrapper_command,class_functions.log_parameters, false)
			log_content = class_functions.import_text_file(rd_logs +"/ES-DE/es_log.txt")
			load_popup("ES-DE Log", "res://components/logs_view/logs_popup_content.tscn",log_content)
		3: 
			class_functions.log_parameters[2] = class_functions.log_text + "Loading RetroArch log"
			class_functions.execute_command(class_functions.wrapper_command,class_functions.log_parameters, false)
			log_content = class_functions.import_text_file(rd_logs +"/retroarch/logs/log.txt")
			load_popup("Retroarch Log", "res://components/logs_view/logs_popup_content.tscn",log_content)	

func _play_main_animations() -> void:
	anim_logo.play()

func _hide_show_containers(button: Button, grid_container: GridContainer) -> void:
	match button.name:
		"decorations_button", "systems_button":
			grid_container.visible = true
			if button.toggle_mode:
				button.toggle_mode=false
				grid_container.visible = false
			else:
				button.toggle_mode=true

# TODO Pass GridContainer(might need 2?) as above
# TODO load existing settings or default to enable all
func _hide_show_buttons(button: Button, buttons_gridcontainer: GridContainer, hidden_gridcontainer: GridContainer) -> void:
	match button.name:
		"borders_button", "button_layout":
			buttons_gridcontainer.visible = true
			if button.toggle_mode == false:
				for i in range(buttons_gridcontainer.get_child_count()):
					var child = buttons_gridcontainer.get_child(i)        
					child.button_pressed=true
				for i in range(hidden_gridcontainer.get_child_count()):
					var child = hidden_gridcontainer.get_child(i)        
					if child is Button and child != button:
						child.visible=false
			elif button.toggle_mode == true and %borders_gridcontainer.visible == true:
				print (button.name, "SAVE NOW? TODO") # TODO SHOW ALL AGAIN?
				buttons_gridcontainer.visible = false
				#button.toggle_mode = false
				for i in range(hidden_gridcontainer.get_child_count()):
					var child = hidden_gridcontainer.get_child(i)        
					if child is Button:
						child.visible=true
						child.toggle_mode = false
			button.toggle_mode = true

func _conf_theme(index: int) -> void: 
	match index:
		1:
			class_functions.log_parameters[2] = class_functions.log_text + "Set theme to index " + str(index)
			class_functions.execute_command(class_functions.wrapper_command,class_functions.log_parameters, false)
			custom_theme = preload("res://res/pixel_ui_theme/RetroDECKTheme.tres")
		2:
			class_functions.log_parameters[2] = class_functions.log_text + "Set theme to index " + str(index)
			class_functions.execute_command(class_functions.wrapper_command,class_functions.log_parameters, false)
			custom_theme = preload("res://assets/themes/retro_theme.tres")
		3:
			class_functions.log_parameters[2] = class_functions.log_text + "Set theme to index " + str(index)
			class_functions.execute_command(class_functions.wrapper_command,class_functions.log_parameters, false)	
			custom_theme = preload("res://assets/themes/modern_theme.tres")
		4:
			class_functions.log_parameters[2] = class_functions.log_text + "Set theme to index " + str(index)
			class_functions.execute_command(class_functions.wrapper_command,class_functions.log_parameters, false)			
			custom_theme = preload("res://assets/themes/accesible_theme.tres")
	$".".theme = custom_theme
	_play_main_animations()

func findElements(node: Node, className: String, result: Array = []) -> Array:
	if node.is_class(className):
		result.push_back(node)
	for child in node.get_children():
		result = findElements(child, className, result)
	return result

func _on_control_mouse_entered(control: Node):
	control.grab_focus()

func load_popup(title:String, content_path:String, display_text: String):
	var popup = load("res://components/popup.tscn").instantiate() as Control
	popup.set_title(title)
	popup.set_content(content_path)
	popup.set_display_text(display_text)
	$Background.add_child(popup)

func _on_quickresume_advanced_pressed():
	load_popup("Quick Resume Advanced", "res://components/popups_content/popup_content_test.tscn","")

func _on_bios_button_pressed():
	_play_main_animations()
	bios_type = 0
	class_functions.log_parameters[2] = class_functions.log_text + "Bios_Check"
	log_results = class_functions.execute_command(class_functions.wrapper_command, class_functions.log_parameters, false)
	load_popup("BIOS File Check", "res://components/bios_check/bios_popup_content.tscn","")
	status_code_label.text = str(log_results["exit_code"])

func _on_bios_button_expert_pressed():
	_play_main_animations()
	bios_type = 1
	class_functions.log_parameters[2] = class_functions.log_text + "Advanced_Bios_Check"
	log_results = class_functions.execute_command(class_functions.wrapper_command, class_functions.log_parameters, false)
	load_popup("BIOS File Check", "res://components/bios_check/bios_popup_content.tscn","")
	status_code_label.text = str(log_results["exit_code"])

func _on_exit_button_pressed():
	_play_main_animations()
	class_functions.log_parameters[2] = class_functions.log_text + "Exited"
	log_results = class_functions.execute_command(class_functions.wrapper_command, class_functions.log_parameters, false)
	class_functions._exit()

func _on_locale_selected(index):
	match index:
		0:
			TranslationServer.set_locale("en")
		_:
			TranslationServer.set_locale("en")
	combine_tkeys()

"""			
		1:
			TranslationServer.set_locale("it")
		2:
			TranslationServer.set_locale("de")
		3:
			TranslationServer.set_locale("sv")
		4:
			TranslationServer.set_locale("ua")
		5:
			TranslationServer.set_locale("ja")
		6:
			TranslationServer.set_locale("zh")
"""

	
func combine_tkeys(): #More as a test
	%cheats.text = tr("TK_CHEATS") + " " + tr("TK_SOON") # switched to access as a unique name as easier to refactor
	#$Background/MarginContainer/TabContainer/TK_SYSTEM/ScrollContainer/VBoxContainer/HBoxContainer/GridContainer/cheats.text = tr("TK_CHEATS") + " " + tr("TK_SOON")
	#%tate_mode.text = tr("TK_TATE") + " " + tr("TK_SOON")
	#%hotkey_sound.text = tr("TK_HOTKEYSOUND") + " " + tr("TK_SOON")
	#$Background/MarginContainer/TabContainer/TK_NETWORK/ScrollContainer/VBoxContainer/cheevos_container/cheevos_advanced_container/cheevos_hardcore.text = tr("TK_CHEEVOSHARDCORE") + " " + tr("TK_SOON")
	#$Background/MarginContainer/TabContainer/TK_NETWORK/ScrollContainer/VBoxContainer/data_mng_container/saves_sync.text = tr("TK_SAVESSYNC") + " " + tr("TK_SOON")
	#$Background/MarginContainer/TabContainer/TK_CONFIGURATOR/ScrollContainer/VBoxContainer/system_container/easter_eggs.text = tr("TK_EASTEREGGS") + " " + tr("TK_SOON")
