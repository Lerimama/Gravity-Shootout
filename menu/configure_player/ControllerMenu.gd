extends Panel


signal Controller_change_confirmed
signal Editing_canceled

var action_block : Object = preload("res://menu/configure_player/ActionBlock.tscn")
var currently_selected_actionblock : Object # s tem opredleimo kaj trenutno selectano, tako da definiramo "efekt
var menu_edit_color : Color
var actionblock_index : int # da lahko damo next po potrditvi gumba trenutno editiran (array index)
#var temp_slovar : Dictionary

var in_menu_map_of_controlls : Dictionary # prenosni slovar, ki ima tudi skenkodo
var temp_scancodes_dictionary : Dictionary


# -----------------------------------------------------------------------------------------------------------------------


func _ready() -> void:
	set_process_input(false)
	hide()
	$KeySelect.connect("Key_selected", self, "_on_Key_selected")


func _input(event: InputEvent) -> void:

	if Input.is_action_just_released("ui_cancel"):
		_on_CancelBtn_pressed()


func open(edited_player_controller_profile, edited_player_color):

	menu_edit_color = edited_player_color

	# napolnemo prenosni slovar z vrednostmi trenutnega slovarja, tako se vedno zajema vse vrednosti kontrolerja
	in_menu_map_of_controlls = edited_player_controller_profile

	# generiramo action bloke za vsako od akcij v slovarju kontrol določenih v profilu plejerja
	for controlls_key in edited_player_controller_profile.keys(): # pazi!!! tu ne uporabljamo prenosnega slovarja,ker se dogaja "cancel" error

			var current_controlls_key_scancode : int = edited_player_controller_profile[controlls_key] # scancode je v outputu samo številka
			var current_controlls_key_name : String = OS.get_scancode_string(current_controlls_key_scancode) # dodamo "ljudsko" ime

			# generacija InputKey blokov za vsako akcijo ...
			var new_action_block = action_block.instance()
			new_action_block.get_node("ActionBtn").text = current_controlls_key_name
			new_action_block.get_node("ActionName").text = controlls_key # capitalize ne dela
			new_action_block.name = controlls_key # damo ime da ob shranjevanju vemo kaj beremo
			new_action_block.connect("Action_is_edited", self, "_on_Action_is_edited") # ob kliku avatar pošlje signal sem (s podatkom o ikoni)

			$ActionMap.add_child(new_action_block)

	# focus na prvo kontrolo
	actionblock_index = 1
	$ActionMap.get_children()[actionblock_index].get_node("ActionBtn").grab_focus()

	show()
	set_process_input(true)


func _on_Action_is_edited(actionblock_in_editing : Object): # signal iz samega action bloka

	# najprej status selected dodamo trenutno izbranemu
	currently_selected_actionblock = actionblock_in_editing

	# potem za vsak karakter v mapi karakterjev pogledamo, kateri je enak izbranemu in apliciramo efekt
	for block in $ActionMap.get_children():
		if block.get_node("ActionBtn").text == actionblock_in_editing.get_node("ActionBtn").text:
			block.get_node("ActionBtn").modulate = menu_edit_color
		else:
			block.get_node("ActionBtn").modulate = GameProfiles.default_game_theme["menu_text_color"]

	# odpremo key select popup
	$KeySelect.text = "IZBERI TIPKO ZA \"%s\"" % currently_selected_actionblock.name.to_upper()
	$KeySelect.open()


func _on_Key_selected(selected_key_scancode):

	# trenuten action blok v obdelavi določen v _on_Action_is_edited ... zaporedje funkcij je pomembno
	var selected_key_name = OS.get_scancode_string(selected_key_scancode)
	currently_selected_actionblock.get_node("ActionBtn").text = selected_key_name

	# aplikacija v prenosni slovar (ne tipke, ampak skenkodo)
	var changed_action_name : String = currently_selected_actionblock.name

	temp_scancodes_dictionary[changed_action_name] = selected_key_scancode
	print("temp_scancodes_dictionary")
	print(temp_scancodes_dictionary)


	# po izbiri tipke razbarvamo vse črke
	for block in $ActionMap.get_children():
		block.get_node("ActionBtn").modulate = GameProfiles.default_game_theme["menu_text_color"]

	# premik fokusa na naslednjo črko
	if actionblock_index < ($ActionMap.get_children().size() - 1): # dolker je index manjši od števila vse akcij
		actionblock_index += 1
		$ActionMap.get_children()[actionblock_index].get_node("ActionBtn").grab_focus()
	else:
#		actionblock_index = 0
		$BtnLine/ConfirmBtn.grab_focus() # potem damo na confirm


func _on_ConfirmBtn_pressed() -> void:

	# sestavimo nov kontroler profil in ime, da ga potem zabeležimo v plejerja
	var new_controller_profile_name : String

	# za  vsak kluč v slovarju spremenjenih preverimo
	for every_key in in_menu_map_of_controlls:
		if temp_scancodes_dictionary.has(every_key):
			in_menu_map_of_controlls[every_key] = temp_scancodes_dictionary[every_key]


	# sestavimo ime za prikaz v player liniji
	for action_name_key in in_menu_map_of_controlls:
		var key_name_first_char : String = OS.get_scancode_string(in_menu_map_of_controlls[action_name_key]).substr ( 0, 2 ) # .to_upper()  # samo prva 2 karakter

		# seštejemo karakterje v string
		new_controller_profile_name += str(key_name_first_char) + "/"

	# zbrišemo zadnji znak za lepoto imena
	if new_controller_profile_name.ends_with("/"):
		new_controller_profile_name.erase(new_controller_profile_name.find_last("/"), 1) #  find_kast nam da pozicijo znaka

	# signal pošljemo player menu
	emit_signal("Controller_change_confirmed", new_controller_profile_name, in_menu_map_of_controlls)

	temp_scancodes_dictionary.clear()

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
