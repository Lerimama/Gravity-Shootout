extends HBoxContainer


signal ControlllerBtn_is_pressed
signal DeleteControllerBtn_is_pressed


func initialize(controller_profile : Dictionary, controller_name : String): # ven dal player_controller_profile


	$ControllerName.text = controller_name

	# generiram info izpis kontrol
	var new_controller_info : String = ""

	for action_key in controller_profile:
		if action_key != GameProfiles.controller_profiles_editable_key: # izločim "is_editable"
			var input_key_name : String = OS.get_scancode_string(controller_profile[action_key]).substr ( 0, 2 )
			new_controller_info += str(input_key_name) + "/"

	$ControllerBtn.text = new_controller_info


func _on_DeleteControllerBtn_pressed() -> void:
	emit_signal("DeleteControllerBtn_is_pressed")

func _on_ControllerBtn_pressed() -> void:
	emit_signal("ControlllerBtn_is_pressed")
