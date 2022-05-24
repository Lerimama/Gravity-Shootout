extends Panel


signal Name_change_confirmed
signal Editing_canceled

var map_character = preload("res://menu/configure_player/MapCharacter.tscn")

var currently_selected_map_character : String # s tem opredleimo kaj trenutno selectno, tako da definiramo "efekt
var currently_edited_character : Object # s tem opredleimo kaj trenutno editiramo
var menu_edit_color : Color
var saved_profiles_names : Array

onready var map_of_characters = GameProfiles.name_menu_characters


# -----------------------------------------------------------------------------------------------------------------------


func _ready() -> void:

	set_process_input(false)
	hide()


	for character_index in map_of_characters.keys():

			var current_character = map_of_characters[character_index] # karakter, placeholderja, ki se trenutno generira dobi črko iz slovarja

			var character_on_map = map_character.instance() # placeholderji karakterja, ki jim nafilamo true karakter
			character_on_map.text = current_character # filanje true karakterja
			character_on_map.connect("Character_selected", self, "_on_Character_in_map_selected") # povežemo se s črko v mapi
			$Table/CharMap.add_child(character_on_map)

func _input(event: InputEvent) -> void:

	if Input.is_action_just_released("ui_cancel"):
		_on_CancelBtn_pressed()


func open (edited_player_name, edited_player_color, currently_saved_player_profiles_keys): # tole se zgodi ob klicu iz player menija

	menu_edit_color = edited_player_color
	saved_profiles_names = currently_saved_player_profiles_keys # za prenašanje ker se skos preverja


	# če je enako ime profila že shranjeno disebjlamo confrim gumb
	if edited_player_name in currently_saved_player_profiles_keys:
		$BtnLine/ConfirmBtn.set_disabled(true)
		$BtnLine/ConfirmBtn.focus_mode = Control.FOCUS_NONE

	# nafilamo vsebino menija ... ločimo črke ... lahko bi uporabil for loop
	var char1 : String = edited_player_name.substr ( 0, 1 )
	var char2 : String  = edited_player_name.substr ( 1, 1 )
	var char3 : String  = edited_player_name.substr ( 2, 1 )
	$Table/Name/NameCharacter1.text = char1
	$Table/Name/NameCharacter2.text = char2
	$Table/Name/NameCharacter3.text = char3

	currently_edited_character = $Table/Name/NameCharacter1 # pripravimo prvo črko, kot če bi jo prtisnu, da jo lahko potem odizberemo
	currently_edited_character.modulate = menu_edit_color

	for character in $Table/CharMap.get_children():
		if character.text == currently_edited_character.text:
			character.grab_focus()
			character.modulate = menu_edit_color
		else:
			character.modulate = GameProfiles.default_game_theme["menu_text_color"]

	show()
	set_process_input(true)


func _on_Character_in_map_selected(selected_character : Object):


	# najprej status selected dodamo trenutno izbranemu
	map_of_characters[currently_selected_map_character] = selected_character

	# potem za vsak karakter v mapi karakterjev pogledamo, kateri je enak izbranemu in apliciramo efekt
	for character in $Table/CharMap.get_children():
		if character.text == selected_character.text:
			character.modulate = menu_edit_color
		else:
			character.modulate = GameProfiles.default_game_theme["menu_text_color"]

	# zamenjamo tekst v trenutnem karakterju z izbranim in damo fokus nanj
	currently_edited_character.grab_focus()
	currently_edited_character.text = selected_character.text

	# preverjamo celotno ime, da vidim, če je legit
	var new_name_for_check : String
	new_name_for_check = ($Table/Name/NameCharacter1.text) +($Table/Name/NameCharacter2.text)  +($Table/Name/NameCharacter3.text)
	print ("")
	print ("---------------")
	print ("ČEK NAME")
	print (new_name_for_check)

	if new_name_for_check in saved_profiles_names:
		$BtnLine/ConfirmBtn.set_disabled(true)
		$BtnLine/ConfirmBtn.focus_mode = Control.FOCUS_NONE
	else:
		$BtnLine/ConfirmBtn.set_disabled(false)
		$BtnLine/ConfirmBtn.focus_mode = Control.FOCUS_ALL


func _on_NameCharacter1_pressed() -> void:

	# razbarvamo > izberemo > obarvamo
	currently_edited_character.modulate = Color.white
	currently_edited_character = $Table/Name/NameCharacter1
	currently_edited_character.modulate = menu_edit_color

	# vse karakterje razbarvamo in potem obarvamo tistega, ki se ujema
	for character in $Table/CharMap.get_children():
#		character.modulate = Color.white
		if character.text == currently_edited_character.text:
			character.grab_focus()
			character.modulate = menu_edit_color
		else:
			character.modulate = GameProfiles.default_game_theme["menu_text_color"]


func _on_NameCharacter2_pressed() -> void:

	currently_edited_character.modulate = Color.white
	currently_edited_character = $Table/Name/NameCharacter2
	currently_edited_character.modulate = menu_edit_color

	for character in $Table/CharMap.get_children():
		if character.text == currently_edited_character.text:
			character.grab_focus()
			character.modulate = menu_edit_color
		else:
			character.modulate = GameProfiles.default_game_theme["menu_text_color"]


func _on_NameCharacter3_pressed() -> void:

	currently_edited_character.modulate = Color.white
	currently_edited_character = $Table/Name/NameCharacter3
	currently_edited_character.modulate = menu_edit_color

	for character in $Table/CharMap.get_children():
		if character.text == currently_edited_character.text:
			character.grab_focus()
			character.modulate = menu_edit_color
		else:
			character.modulate = GameProfiles.default_game_theme["menu_text_color"]


func _on_ConfirmBtn_pressed() -> void:

	# sestavimo črke v besedo in jo pošljemo v plejerjev profil
	var new_name : String
	new_name = ($Table/Name/NameCharacter1.text) +($Table/Name/NameCharacter2.text)  +($Table/Name/NameCharacter3.text)
	emit_signal("Name_change_confirmed", new_name)

	hide()
	reset_current_menu()
	set_process_input(false)


func _on_CancelBtn_pressed() -> void:

	emit_signal("Editing_canceled")
	hide()
	reset_current_menu()
	set_process_input(false)



func reset_current_menu():

	# razbarvamo celotno ime
	for name_character in $Table/Name.get_children():
		name_character.modulate = GameProfiles.default_game_theme["menu_text_color"]

	# razbarvamo mapo karakterjev
	for character in $Table/Name.get_children():
		character.modulate = Color.white

