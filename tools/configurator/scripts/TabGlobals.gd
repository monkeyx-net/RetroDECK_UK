extends MarginContainer

var press_time: float = 0.0
var is_state_pressed: bool = false
var PRESS_DURATION: float = 3.0
var current_button: Button = null
var current_progress: ProgressBar = null
var current_state: String = ""

func _ready():
	_connect_signals()

func _process(delta: float) -> void:
	if current_button != null:
		update_progress(delta, current_progress)

func update_progress(delta: float, progress: ProgressBar) -> void:
	if press_time >= PRESS_DURATION:
		_do_complete(current_button)
		print ("Progress Bar: %s Button: %s" % [progress.name, current_button.name])
	elif is_state_pressed and current_state == "mixed":
		press_time += delta
		progress.value = press_time / PRESS_DURATION * 100.0

func _connect_signals():
	%quick_resume_button.pressed.connect(class_functions.run_function.bind(%quick_resume_button, "quick_resume"))
	%button_swap_button.button_down.connect(_do_action.bind(%button_swap_progress, %button_swap_button))
	%button_swap_button.button_up.connect(_on_button_released.bind(%button_swap_progress))
	%button_swap_button.pressed.connect(class_functions.run_function.bind(%button_swap_button, "abxy_button_swap"))
	%ask_to_exit_button.button_down.connect(_do_action.bind(%ask_to_exit_progress, %ask_to_exit_button))
	%ask_to_exit_button.button_up.connect(_on_button_released.bind(%ask_to_exit_progress))
	%ask_to_exit_button.pressed.connect(class_functions.run_function.bind(%ask_to_exit_button, "ask_to_exit"))
	%border_button.button_down.connect(_do_action.bind(%border_progress, %border_button))
	%border_button.button_up.connect(_on_button_released.bind(%border_progress))
	%border_button.pressed.connect(class_functions.run_function.bind(%border_button, "borders"))	
	%widescreen_button.button_down.connect(_do_action.bind(%widescreen_progress, %widescreen_button))
	%widescreen_button.button_up.connect(_on_button_released.bind(%widescreen_progress))
	%widescreen_button.pressed.connect(class_functions.run_function.bind(%widescreen_button, "widescreen"))
	%quick_rewind_button.button_down.connect(_do_action.bind(%quick_rewind_progress, %quick_rewind_button))
	%quick_rewind_button.button_up.connect(_on_button_released.bind(%quick_rewind_progress))
	%quick_rewind_button.pressed.connect(class_functions.run_function.bind(%quick_rewind_button, "rewind"))
	
func _on_button_released(progress: ProgressBar) -> void:
	is_state_pressed = false
	progress.visible = false
	press_time = 0.0
	progress.value = 0.0
	current_button = null
	current_progress = null
	current_state == null
	
func _do_action(progress: ProgressBar, button: Button) -> void:
	match progress.name:
		"button_swap_progress":
			current_state = class_functions.abxy_state
		"ask_to_exit_progress":
			current_state = class_functions.ask_to_exit_state
		"quick_rewind_progress":
			current_state = class_functions.quick_rewind_state
		"widescreen_progress":
			current_state = class_functions.widescreen_state
		"border_progress":
			current_state = class_functions.border_state
	current_button = button
	current_progress = progress
	current_progress.visible = true
	is_state_pressed = true
			
func _do_complete(button: Button) ->void:
	#TODO use object for state
	if is_state_pressed and button == current_button:
		match button.name:
			"button_swap_button":
				class_functions.abxy_state = "false"
			"ask_to_exit_button":
				class_functions.ask_to_exit_state = "false"
			"border_button":
				class_functions.border_state = "false"
			"widescreen_button":
				class_functions.widescreen_state = "false"
			"quick_rewind_button":
				class_functions.quick_rewind_state = "false"
	button.toggle_mode = true
