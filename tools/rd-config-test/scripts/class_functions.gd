extends Control
class_name ClassFunctions

# This should be looked at again when GoDot 4.3 ships as has new OS.execute_with_pipe

func array_to_string(arr: Array) -> String:
	var text = ""
	for line in arr:
		text += line + "\n"
	return text

func execute_command(command: String, parameters: Array, console: bool) -> Dictionary:
	var result = {}
	var output = []
	var exit_code = OS.execute(command, parameters, output, console)
	result["output"] = array_to_string(output)
	result["exit_code"] = exit_code
	return result

func run_command_in_thread(command: String, paramaters: Array, _console: bool) -> Dictionary:
	var thread = Thread.new()
	thread.start(execute_command.bind(command,paramaters,false))
	while thread.is_alive():
		await get_tree().process_frame
	var result = thread.wait_to_finish()
	thread = null
	return result

func _threaded_command_execution(command: String, parameters: Array, console: bool) -> Dictionary:
	var result = execute_command(command, parameters, console)
	return result
