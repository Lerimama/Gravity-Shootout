extends Panel


signal Editing_confirmed
signal Editing_canceled

var action_block : Object = preload("res://menu/configure_controller/ActionBlock.tscn")
var new_controller_profile : Dictionary # preimenuj
var actionblock_index : int # da lahko damo next po potrditvi gumba trenutno editiran (array index)







#var temp_scancodes_dictionary : Dictionary # preimenuj
#var in_menu_map_of_controlls : Dictionary # prenosni slovar, ki ima tudi skenkodo
#var currently_selected_actionblock : Object # s tem opredleimo kaj trenutno selectano, tako da definiramo "efekt
#var temp_slovar : Dictionary

onready var menu_edit_color : Color = GameProfiles.default_game_theme["menu_edit_color"]


# ------------------------------------------------------------------------------------------------------------------------------------------------------------


func _ready() -> void:
	set_process_input(false)
	hide()
	$KeySelect.connect("Key_selected", self, "_on_Key_selected")


func _input(event: InputEvent) -> void:

	if Input.is_action_just_released("ui_cancel"):
#		_on_CancelBtn_pressed()
		pass


func open(edited_controller_name, edited_controller_profile):

	print("POPRAVLJAMO PROFIL:")
	print(edited_controller_profile)
#	menu_edit_color = edited_player_color

	# nov slovar napolnimo z vsemi akcijami, ki ji potem spreminjamo
	new_controller_profile = edited_controller_profile
#	duplikat?



	# napolnemo prenosni slovar z vrednostmi trenutnega slovarja, tako se vedno zajema vse vrednosti kontrolerja
#	in_menu_map_of_controlls = edited_controller_profile

	# generiramo action bloke za vsako od akcij v slovarju kontrol določenih v profilu plejerja
	for action_key in new_controller_profile.keys(): # pazi!!! tu ne uporabljamo prenosnega slovarja,ker se dogaja "cancel" error

		if action_key != "is_editable" :
			var current_action_key_scancode : int = new_controller_profile[action_key] # scancode je v outputu samo številka
			var current_action_key_name : String = OS.get_scancode_string(current_action_key_scancode) # dodamo "ljudsko" ime

			# generacija InputKey blokov za vsako akcijo ...
			var new_action_block = action_block.instance()
			new_action_block.get_node("ActionBtn").text = current_action_key_name
			new_action_block.get_node("ActionName").text = action_key # capitalize ne dela
			new_action_block.name = action_key # damo ime da ob shranjevanju vemo kaj beremo

			new_action_block.connect("Action_pressed", self, "_on_Action_pressed") # ob kliku avatar pošlje signal sem (s podatkom o ikoni)

			$ActionMap.add_child(new_action_block)

	# focus na prvo kontrolo
#	actionblock_index = 1
#	$ActionMap.get_children()[actionblock_index].get_node("ActionBtn").grab_focus()




	show()
	set_process_input(true)



#	print("POPRAVLJAMO PROFIL:")
#	print(edited_controller_profile)
##	menu_edit_color = edited_player_color
#
#	# napolnemo prenosni slovar z vrednostmi trenutnega slovarja, tako se vedno zajema vse vrednosti kontrolerja
##	in_menu_map_of_controlls = edited_controller_profile
#
#	# generiramo action bloke za vsako od akcij v slovarju kontrol določenih v profilu plejerja
#	for action_key in edited_controller_profile.keys(): # pazi!!! tu ne uporabljamo prenosnega slovarja,ker se dogaja "cancel" error
#
#		if action_key != "is_editable" :
#			var current_action_key_scancode : int = edited_controller_profile[action_key] # scancode je v outputu samo številka
#			var current_action_key_name : String = OS.get_scancode_string(current_action_key_scancode) # dodamo "ljudsko" ime
#
#			# generacija InputKey blokov za vsako akcijo ...
#			var new_action_block = action_block.instance()
#			new_action_block.get_node("ActionBtn").text = current_action_key_name
#			new_action_block.get_node("ActionName").text = action_key # capitalize ne dela
#			new_action_block.name = action_key # damo ime da ob shranjevanju vemo kaj beremo
#
#			new_action_block.connect("Action_pressed", self, "_on_Action_pressed") # ob kliku avatar pošlje signal sem (s podatkom o ikoni)
#
#			$ActionMap.add_child(new_action_block)
#
#	# focus na prvo kontrolo
##	actionblock_index = 1
##	$ActionMap.get_children()[actionblock_index].get_node("ActionBtn").grab_focus()
#
#	# nov slovar napolnimo z vsemi akcijami, ki ji potem spreminjamo
#	new_controller_profile = edited_controller_profile.duplicate()
##	duplikat?
#
#
#	show()
#	set_process_input(true)


func _on_Action_pressed(selected_action_block : Node): # signal iz samega action bloka
#	print ("PRESSED")


	# najprej status selected dodamo trenutno izbranemu
#	currently_selected_actionblock = actionblock_in_editing

	# potem za vsak karakter v mapi karakterjev pogledamo, kateri je enak izbranemu in apliciramo efekt
	for actionblock in $ActionMap.get_children():
		if actionblock.get_node("ActionBtn").text == selected_action_block.get_node("ActionBtn").text:
			actionblock.get_node("ActionBtn").modulate = menu_edit_color
		else:
			actionblock.get_node("ActionBtn").modulate = GameProfiles.default_game_theme["menu_text_color"]

	# odpremo key select popup
#	$KeySelect.text = "IZBERI TIPKO ZA \"%s\"" % selected_action_block.name.to_upper()
	$KeySelect.open(selected_action_block)


func _on_Key_selected(selected_key_scancode, edited_actionblock):

	# skenkodo spremenimo v poljudno ime za tipko
	var selected_key_name = OS.get_scancode_string(selected_key_scancode)

	# trenuten action blok v obdelavi določen v _on_Action_is_edited ... zaporedje funkcij je pomembno
	edited_actionblock.get_node("ActionBtn").text = selected_key_name

	# v profilu prepišemo staro akcijo pod ključem action blocka z novo izbrano ... skenkoda!!!
	new_controller_profile[edited_actionblock.name] = selected_key_scancode

#	temp_scancodes_dictionary[currently_selected_actionblock.name] = selected_key_scancode
#	print("temp_scancodes_dictionary")
#	print(temp_scancodes_dictionary)

	# po izbiri tipke razbarvamo vse črke
	for actionblock in $ActionMap.get_children():
		actionblock.get_node("ActionBtn").modulate = GameProfiles.default_game_theme["menu_text_color"]

	# premik fokusa na naslednjo črko
	if actionblock_index < ($ActionMap.get_children().size() - 1): # dolker je index manjši od števila vse akcij
		actionblock_index += 1
		$ActionMap.get_children()[actionblock_index].get_node("ActionBtn").grab_focus()
	else:
#		actionblock_index = 0
		$BtnLine/ConfirmBtn.grab_focus() # potem damo na confirm


func _on_ConfirmBtn_pressed() -> void:
	print("new_controller_profile")
	print(new_controller_profile)

#	var new_controller_profile_name : String
#
#	# sestavimo nov kontroler profil in ime, da ga potem zabeležimo v plejerja
#	# za  vsak kluč v slovarju spremenjenih preverimo
#
#	for action in new_controller_profile:
#		new_controller_profile
#
#
#		if temp_scancodes_dictionary.has(every_key):
#			in_menu_map_of_controlls[every_key] = temp_scancodes_dictionary[every_key]
##
#
##	# sestavimo ime za prikaz v player liniji
#	for action in new_controller_profile:
#		var input_key_name : String = OS.get_scancode_string(new_controller_profile[action]).substr ( 0, 2 ) # .to_upper()  # samo prva 2 karakter
#
#		# seštejemo karakterje v string
#		new_controller_profile_name += str(key_name_firts_char) + "/"
#
#	# zbrišemo zadnji znak za lepoto imena
#	if new_controller_profile_name.ends_with("/"):
#		new_controller_profile_name.erase(new_controller_profile_name.find_last("/"), 1) #  find_kast nam da pozicijo znaka

	# signal pošljemo glavni menu
	emit_signal("Editing_confirmed", new_controller_profile)

#	new_controller_profile.clear()

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
