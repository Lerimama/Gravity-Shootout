extends Panel


signal Editing_confirmed
signal Editing_canceled

var action_block : Object = preload("res://menu/configure_controller/ActionBlock.tscn")
var temp_controller_profile : Dictionary # preimenuj
var actionblock_index : int # da lahko damo next po potrditvi gumba trenutno editiran (array index)


# ------------------------------------------------------------------------------------------------------------------------------------------------------------


func _ready() -> void:
	set_process_input(false)
	hide()
	$KeySelect.connect("Key_selected", self, "_on_Key_selected")


func _input(event: InputEvent) -> void:

	if Input.is_action_just_released("ui_cancel"):
		_on_CancelBtn_pressed()


func open(edited_controller_profile):

	print("")
	print("Popravljamo profil:")
	print(edited_controller_profile)
	print("temp profil")
	print(temp_controller_profile)


	$BtnLine/ConfirmBtn.set_disabled(true)
	$BtnLine/ConfirmBtn.focus_mode = Control.FOCUS_NONE

	# generiramo action bloke za vsako od akcij v slovarju kontrol določenih v profilu plejerja
	for action_key in edited_controller_profile.keys():

		if action_key != "is_editable" : # izločimo ključ "is_editable" generacije blokov

			var current_action_key_scancode : int = edited_controller_profile[action_key] # scancode je v outputu samo številka
			var current_action_key_name : String = OS.get_scancode_string(current_action_key_scancode) # dodamo "ljudsko" ime

			var new_action_block = action_block.instance()
			new_action_block.name = action_key # damo ime da ob shranjevanju vemo kaj beremo
			new_action_block.get_node("ActionBtn").text = current_action_key_name
			new_action_block.get_node("ActionName").text = action_key # capitalize ne dela
			new_action_block.connect("Action_pressed", self, "_on_Action_pressed") # ob kliku avatar pošlje signal sem (s podatkom o ikoni)
			$ActionMap.add_child(new_action_block)

	# focus na prvo kontrolo
	actionblock_index = 1
	$ActionMap.get_children()[actionblock_index].get_node("ActionBtn").grab_focus()

	# prnoesni slovar napolnemo z duplikatom, da ga ne bomo slučajno spreminjali
	# rabimo ga za preverjanje ekskluzivnosti imena
	temp_controller_profile = edited_controller_profile.duplicate()

	show()
	set_process_input(true)


func _on_Action_pressed(selected_action_block : Node): # signal iz samega action bloka

	# potem za vsak karakter v mapi karakterjev pogledamo, kateri je enak izbranemu in apliciramo efekt
	for actionblock in $ActionMap.get_children():
		if actionblock.get_node("ActionBtn").text == selected_action_block.get_node("ActionBtn").text:
			actionblock.get_node("ActionBtn").modulate = GameProfiles.default_game_theme["menu_edit_color"]
		else:
			actionblock.get_node("ActionBtn").modulate = GameProfiles.default_game_theme["menu_text_color"]

	# odpremo key select popup
	$KeySelect.open(selected_action_block)


func _on_Key_selected(selected_key_scancode, edited_actionblock):

	# skenkodo spremenimo v poljudno ime za tipko
	var selected_key_name = OS.get_scancode_string(selected_key_scancode)

	# trenuten action blok v obdelavi določen v _on_Action_is_edited ... zaporedje funkcij je pomembno
	edited_actionblock.get_node("ActionBtn").text = selected_key_name

	# v profilu prepišemo staro akcijo pod ključem istega action blocka z novo izbrano ... skenkoda!!!
	temp_controller_profile[edited_actionblock.name] = selected_key_scancode


	# po izbiri razbravamo vse tipke
	for actionblock in $ActionMap.get_children():
		actionblock.get_node("ActionBtn").modulate = GameProfiles.default_game_theme["menu_text_color"]

	# preverimo, če je ime že uporabljeno
	var controller_checking_name : String
	for action_key in temp_controller_profile:
		if action_key != GameProfiles.controller_profiles_editable_key: # izločim "is_editable" ključ
			var input_key_name : String = OS.get_scancode_string(temp_controller_profile[action_key]).substr ( 0, 2 ) # .to_upper()  # samo prva 2 karakter
			controller_checking_name += str(input_key_name)
	if owner.controller_profiles.has(controller_checking_name) or controller_checking_name == GameProfiles.empty_controller_name:
		$BtnLine/ConfirmBtn.set_disabled(true)
		$BtnLine/ConfirmBtn.focus_mode = Control.FOCUS_NONE
	else:
		$BtnLine/ConfirmBtn.set_disabled(false)
		$BtnLine/ConfirmBtn.focus_mode = Control.FOCUS_ALL

	# premik fokusa na naslednjo črko
	if actionblock_index < ($ActionMap.get_children().size() - 1): # dolker je index manjši od števila vse akcij
		actionblock_index += 1
		$ActionMap.get_children()[actionblock_index].get_node("ActionBtn").grab_focus()
	else:
		$BtnLine/ConfirmBtn.grab_focus() # potem damo na confirm

	print("")
	print("Izbrana je črka ... profil je:")
	print(temp_controller_profile)


func _on_ConfirmBtn_pressed() -> void:

	print("")
	print("Popravljen profil:")
	print(temp_controller_profile)

	# signal pošljemo glavni menu
	emit_signal("Editing_confirmed", temp_controller_profile) # te

	hide()
	reset_current_menu()
	set_process_input(false)


func _on_CancelBtn_pressed() -> void:


	emit_signal("Editing_canceled")
	hide()
	reset_current_menu()
	set_process_input(false)


func reset_current_menu():

#	actionblock_index = 1


	# actionblocke zbrišemo
	for child in $ActionMap.get_children():
		child.queue_free()
