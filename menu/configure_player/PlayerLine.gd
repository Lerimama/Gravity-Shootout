extends HBoxContainer


signal Name_btn_pressed
signal Controlller_btn_pressed
signal Avatar_btn_pressed
signal Color_btn_pressed
signal Delete_btn_pressed


#func initialize(player_name, player_controller_profile_name, player_avatar, player_color): # ven dal player_controller_profile
func initialize(player_name, player_avatar, player_color): # ven dal player_controller_profile

	# vse gumbe v liniji damo v grupo
#	for button in get_children():
#		button.add_to_group("line_btns")
	# sem kar ročno naredil

	# napolnemo propse s podatki iz profilov v plejer meniju
	$PlayerNameBtn.text = str(player_name)
#	$PlayerControllerBtn.text = str(player_controller_profile_name)
	$PlayerAvatarBtn.icon = player_avatar
	$PlayerAvatarBtn.modulate = player_color
	$PlayerColorIndicator.color = Color.white # ker moduliramo celo liniujo, barvni kvadrat resetiram, da pride venm prava barva


func _on_PlayerNameBtn_pressed() -> void:
	emit_signal("Name_btn_pressed")


func _on_PlayerControllerBtn_pressed() -> void:
	emit_signal("Controlller_btn_pressed")


func _on_PlayerAvatarBtn_pressed() -> void:
	emit_signal("Avatar_btn_pressed")


func _on_PlayerColorBtn_pressed() -> void:
	emit_signal("Color_btn_pressed")


func _on_DeletePlayerBtn_pressed() -> void:
	emit_signal("Delete_btn_pressed")
	queue_free()

