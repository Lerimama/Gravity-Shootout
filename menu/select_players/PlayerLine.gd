extends HBoxContainer

#
signal Player_activated
signal Player_deactivated
signal Controller_selected

var player_activated: bool = false


func initialize(player_name : String, available_controller_profiles: Array):


	$PlayerName.text = player_name

	$ControllerBtn.text = "select controller"
#	$ControllerBtn.set_disabled(true)
#	$ControllerBtn.focus_mode = FOCUS_NONE
	
	# dodam "empty" linijo
	$ControllerBtn.add_item("brez kontrol")
	
	# dodam imena vseh controller profilov
	for controller_profile_name in available_controller_profiles:
		$ControllerBtn.add_item(controller_profile_name)
	
	# predizberem "empty" linijo
	$ControllerBtn.select(0)

	$ActivateBtn.text = "ZUN"


func _on_ActivateBtn_pressed() -> void:

	player_activated = !player_activated
	if player_activated == true:
		$ActivateBtn.text = "NOT"
		$ControllerBtn.set_disabled(false)
		$ControllerBtn.focus_mode = FOCUS_ALL
		emit_signal("Player_activated")

	# restiramo gumb za kontrole (ni najbolj prijazno, je pa Laži)
	elif player_activated == false:
		$ActivateBtn.text = "ZUN"
		$ControllerBtn.select(0)
		$ControllerBtn.set_disabled(true)
		$ControllerBtn.focus_mode = FOCUS_NONE
		emit_signal("Player_deactivated")


func _on_ControllerBtn_item_selected(index: int) -> void:
	emit_signal("Controller_selected")
#	var ctrlpopup = $ControllerBtn.get_popup()
#	ctrlpopup.get_z_index()
#	print(ctrlpopup.get_z_index())

func _on_ControllerBtn_pressed() -> void:

#	var ctrlpopup = $ControllerBtn.get_popup()
#	ctrlpopup.get_z_index()
#	print(ctrlpopup.get_z_index())
#	ctrlpopup.get_canvas_item()
#
#	var canvas_rid = RID(ctrlpopup.get_id())
##	var canvas_rid = $ControllerBtn.get_popup()
#	# You may need to adjust these values
#	VisualServer.canvas_item_set_draw_index(canvas_rid, 100)
#	VisualServer.canvas_item_set_z_index(canvas_rid, 100)
#	print ($ControllerBtn.get_popup())
#	print (canvas_rid)
#	print (ctrlpopup)
#
	pass
