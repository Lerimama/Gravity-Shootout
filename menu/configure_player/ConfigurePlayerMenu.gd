extends Control


signal Quit_configure_player (player_profiles)

const player_line = preload("res://menu/configure_player/PlayerLine.tscn")

var controller_profiles : Dictionary
var def_new_player_profile : Dictionary
var def_controller_new_player_profile : Dictionary

# in editing
var profile_in_editing : Dictionary # vsebina slovarja
var profile_in_editing_name : String # ime ... ne vsebina!!!
var profile_in_editing_line : Node # playerline ... tako lahko posegamo na vse otroke te linije
var prop_in_editing : Node

var add_player_mode_active = false # change name meni ima drugo funkcijo glede na status te variable
var button_focused : bool # tole setamo na false ko se odpre meni ... lahko bi tudi fokusiral na določen gumb
var main_menu_enabled : bool # je to odveč?

onready var player_list : Node = get_node("Table/ScrollContainer/PlayerList")
onready var player_profiles : Dictionary = Global.game_manager.available_player_profiles


# -----------------------------------------------------------------------------------------------------------------------


func _ready() -> void: # tile bo šlo v open

	set_process_input(false)
	main_menu_enabled = false
	hide()


func _input(event: InputEvent) -> void:

	# če je prižgan delete btn potem gremo ven iz delete plejer mode ...
	if Input.is_action_just_released("ui_cancel"):
		_on_QuitBtn_pressed()

	# fokusiraj gumb v meniju
	if Input.is_action_just_released("ui_left") && button_focused == false:
		$Table/BtnLine/QuitBtn.grab_focus()
		button_focused = true

	if Input.is_action_just_released("ui_right") && button_focused == false:
		$Table/BtnLine/AddBtn.grab_focus()
		button_focused = true

	# fokusiraj gumb v meniju
	if Input.is_action_just_released("ui_up") && button_focused == false:
		$Table/BtnLine/QuitBtn.grab_focus()
		button_focused = true

	if Input.is_action_just_released("ui_down") && button_focused == false:
		$Table/BtnLine/AddBtn.grab_focus()
		button_focused = true


func open():

	# povežemo Quit singal z game managerjem
	var configure_player_menu = Global.node_creation_parent.get_node("MenuHolder/ConfigurePlayerMenu")
	self.connect("Quit_configure_player", Global.game_manager, "on_Quit_configure_player") # signal prihaja iz input lajne

	def_new_player_profile = GameProfiles.default_new_player_profile
	def_controller_new_player_profile  = GameProfiles.empty_controller_profile

	#generiramo lajne
	for player_profile_name in player_profiles.keys(): # za vsako ime profila v slovarju profili
		var current_player_profile = player_profiles[player_profile_name]
		add_player_line(current_player_profile)

	show()
	enable_main_menu()


func close():

	disable_main_menu()
	hide();

	for child in player_list.get_children():
		child.queue_free()

	Global.game_manager.toggle_pause()


func add_player_line(player_profile: Dictionary):

	# ime profila povlečemo iz plejerjevega imena v profilu
	var player_profile_name : String = player_profile["player_name"] # randomize

	# dodaj linijo v player_list in ji pošlji podatke
	var player_profile_line = player_line.instance()

	player_profile_line.name = str(player_profile_name) # na koncu mogoče sploh ne rabim ... rabim za ime
	player_profile_line.initialize(player_profile_name, player_profile["player_avatar"], player_profile["player_color"]) # štartamo akcijo v sami liniji, katera poebere potrebne podatke

	# signali za odpiranje menijev .... pošljemo: lastnost, ki jo spreminjamo, ime profila, ki ga spreminjamo in vsebino linije profila
	player_profile_line.connect("Name_btn_pressed", self, "_on_Name_btn_pressed", [player_profile_name, player_profile_line])
	player_profile_line.connect("Avatar_btn_pressed", self, "_on_Avatar_btn_pressed", [player_profile["player_avatar"], player_profile_name, player_profile_line])
	player_profile_line.connect("Color_btn_pressed", self, "_on_Color_btn_pressed", [player_profile["player_color"], player_profile_name, player_profile_line])
	player_profile_line.connect("Delete_btn_pressed", self, "_on_Delete_btn_pressed", [player_profile_name, player_profile_line])

	if player_profile["player_editable"] == false:

		player_profile_line.get_node("DeletePlayerBtn").remove_from_group("line_btns")
		player_profile_line.get_node("DeletePlayerBtn").set_disabled(true)
		player_profile_line.get_node("DeletePlayerBtn").focus_mode = FOCUS_NONE
		# gumb skrijemo z theme_overideom direktno na delet gumbu

	#gumbe v liniji obarvamo v barvi plejerja
	for player_line_btn in player_profile_line.get_children():
		player_line_btn.modulate = player_profile["player_color"]

	player_list.add_child(player_profile_line)


func _on_Name_btn_pressed(player_profile_name: String, player_profile_line: Node): # odpremo NameMenu

	# tole je preddefinirano, da se prenaša po funnkcijah
	profile_in_editing_name = player_profile_name
	profile_in_editing_line = player_profile_line # rabim za refreš
	prop_in_editing = player_profile_line.get_node("PlayerNameBtn")
	profile_in_editing = player_profiles[player_profile_name]

	$NameMenu/Title.text = "CHANGE PLAYER NAME"
	$NameMenu.open(profile_in_editing["player_name"], profile_in_editing["player_color"], player_profiles.keys())

	disable_main_menu()


func _on_Name_change_confirmed (new_name: String):

	# če samo spreminjamo ime
	if add_player_mode_active != true:

		# opredelimo profil, ki ga obdelujemo ... pred spremembo
		var edited_player_profile = player_profiles[profile_in_editing_name]

		# zbrišemo vsak profil, če je njegovo ime enako kot ime trenutno editiranega ... zato ker spremenimo ime, moramo spremeniti tudi ime oz. ključ samega profila
		for profile in player_profiles.keys():
			if profile == profile_in_editing_name:
				player_profiles.erase(profile_in_editing_name)

		# apliciramo novo ime v profil v editiranju
		edited_player_profile["player_name"] = str(new_name)

		# potem zgradimo nov profil z novim ključem
		var new_edited_player_profile = edited_player_profile

		# in ga dodamo v slovar vseh profilov
		player_profiles[str(new_name)] = new_edited_player_profile

		# pred generacijo linje zbrišemo staro linijo in potem dodamo ta novo
		profile_in_editing_line.queue_free()
		add_player_line(new_edited_player_profile)

	# če dodajamo novega igralca
	else:

		# defolt new plejer profil podamo v slovar vseh profilov pod novim imenom igralca (duplikat je zato, da original ostane nedotaknjen)
		player_profiles[str(new_name)] = def_new_player_profile.duplicate()

		# potem v novem plejer profilu, ki ima zaenkrat def vrednosti ...
		# spremenimo ime v novo plejerjevo ime
		var added_player_profile = player_profiles[str(new_name)]
		added_player_profile["player_name"] = new_name

		# in v profile vseh kontrol dodam duplikat def kontrol pod imenom "nekaj v stilu spremeni", ta je od tega plejerja profil
		controller_profiles[GameProfiles.empty_controller_name] = def_controller_new_player_profile.duplicate()

		add_player_line(player_profiles[str(new_name)])

		add_player_mode_active = false

	enable_main_menu()


func _on_Delete_btn_pressed(player_profile_name: String, player_profile_line):

	# izbrišemo plejerjeve kontrole iz seznama kontrol
	var deleted_player_profile = player_profiles[player_profile_name]

	# izbrišem plejerjev profil iz seznama plejer profilov
	for profile in player_profiles.keys():
		player_profiles.erase(player_profile_name)

	button_focused = false


func _on_Avatar_btn_pressed(edited_player_avatar_texture, player_profile_name: String, player_profile_line: Node):

	# tole je preddefinirano na vrhu, da se prenaša po funkcijah
	profile_in_editing_name = player_profile_name
	prop_in_editing = player_profile_line.get_node("PlayerAvatarBtn")
	profile_in_editing = player_profiles[player_profile_name]

	edited_player_avatar_texture = profile_in_editing["player_avatar"]

	$AvatarMenu.open(edited_player_avatar_texture, profile_in_editing["player_color"])

	disable_main_menu()


func _on_Avatar_change_confirmed(new_avatar: Object):

	# opredelimo profil, ki ga obdelujemo
	var edited_player_profile = player_profiles[profile_in_editing_name]

	# apliciramo nove vrednosti v opredeljeni profil (slovar)
	edited_player_profile["player_avatar"] = new_avatar.texture

	# spremenimo ikono v lajni
	prop_in_editing.icon = edited_player_profile["player_avatar"]

	enable_main_menu()


func _on_Color_btn_pressed(edited_player_color, player_profile_name: String, player_profile_line: Node):

	# tole je preddefinirano na vrhu, da se prenaša po funkcijah
	profile_in_editing_name = player_profile_name
	profile_in_editing_line = player_profile_line
	prop_in_editing = profile_in_editing_line.get_node("PlayerColorIndicator")
	profile_in_editing = player_profiles[player_profile_name]

	edited_player_color = profile_in_editing["player_color"]

	$ColorMenu.open(edited_player_color) # kličemo akcijo v meniju in pošljemo ime barve

	disable_main_menu()


func _on_Color_change_confirmed(new_colorsq: Object):

	# opredelimo profil, ki ga obdelujemo
	var edited_player_profile = player_profiles[profile_in_editing_name]

	# apliciramo nove vrednosti v opredeljeni profil (slovar)
	edited_player_profile["player_color"] = new_colorsq.color

	# spremenimo barvo ostalih objektov v liniji
	for player_line_btn in profile_in_editing_line.get_children():
		player_line_btn.modulate = edited_player_profile["player_color"]

	enable_main_menu()


func _on_Controller_btn_pressed(edited_player_controller_profile_name: String, player_profile_name: String, player_profile_line: Node):

	# tole je preddefinirano na vrhu, da se prenaša po funkcijah
	profile_in_editing_name = player_profile_name
	profile_in_editing_line = player_profile_line
	prop_in_editing = profile_in_editing_line.get_node("PlayerControllerBtn")
	profile_in_editing = player_profiles[player_profile_name]

	edited_player_controller_profile_name = profile_in_editing["player_controller"]

	$ControllerMenu.open(controller_profiles[edited_player_controller_profile_name], profile_in_editing["player_color"])

	disable_main_menu()


func _on_Controller_change_confirmed(new_controller_profile_name: String, new_controller_profile_scancodes: Dictionary):

	# poberemo ime kontrolerja na igralcu (pred spremembo)
	var edited_player_profile = player_profiles[profile_in_editing_name]

	# SLOVAR PROFILOV nafilamo (novega, z novim imenom, umestimo namesto izbrisanega)
	controller_profiles[new_controller_profile_name] = new_controller_profile_scancodes

	# SLOVAR PLAYER PROFILA dodamo ime controllerja
	# apliciramo ime trenutnega controller profila v ime kontrolerja v profilu igralca
	edited_player_profile["player_controller"] = new_controller_profile_name

	# zapišemo ime controller profila v menu v lajni
	prop_in_editing.text = new_controller_profile_name

	enable_main_menu()


func _on_Editing_canceled() -> void:

	enable_main_menu()
	button_focused = false


func disable_main_menu():

	# ugasnemo delovanje tipk menija
	set_process_input(false)

	# ugasnemo glavne gumbe
	for menu_btn in get_tree().get_nodes_in_group("menu_btns"):
		menu_btn.set_disabled(true)
		menu_btn.focus_mode = FOCUS_NONE

	# ugasnemo plejer-line gumbe
	for line_btn in get_tree().get_nodes_in_group("line_btns"):
		line_btn.set_disabled(true)
		line_btn.focus_mode = FOCUS_NONE


func enable_main_menu():

	# vklopimo delovanje tipk menija
	set_process_input(true)

	# pržegmo glavne gumbe
	for menu_btn in get_tree().get_nodes_in_group("menu_btns"):
		menu_btn.set_disabled(false)
		menu_btn.focus_mode = FOCUS_ALL

	# pržegmo plejer-line gumbe
	for line_btn in get_tree().get_nodes_in_group("line_btns"):
		line_btn.set_disabled(false)
		line_btn.focus_mode = FOCUS_ALL

	# fejk stanje omogoči da deluejo glavni gumbi menija ... lahko bi tudi fokusiral na določen gumb
	button_focused = false


func _on_AddBtn_pressed() -> void:

	add_player_mode_active = true # zato da lahko pri potrditvi imena ločimo akcijo od spreminjanja imena že obstojčega igralca

	var added_player_profile = GameProfiles.default_new_player_profile # profil povlečemo iz game profiles
	var added_player_name : String = added_player_profile["player_name"]
	var added_player_color : Color = added_player_profile["player_color"]

	$NameMenu/Title.text = "NEW PLAYER NAME"
	$NameMenu.open(added_player_name, added_player_color, player_profiles.keys())

	disable_main_menu()


func _on_QuitBtn_pressed() -> void:

	Global.game_manager.available_player_profiles = player_profiles # podamo vse profile v game manager

	print ("VSI PLEJER PROFILI PRED IGRO")
	print (player_profiles)

	close()
