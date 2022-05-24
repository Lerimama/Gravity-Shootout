extends Control


signal saved_controllers (saved_controllers_profiles)

const controller_line = preload("res://menu/configure_controller/ControllerLine.tscn")

var controller_profiles : Dictionary
var controller_in_editing : Dictionary # prenosni
var controller_in_editing_name : String # prenosni
var line_in_editing : Node # playerline ... tako lahko posegamo na vse otroke te linije
var add_mode_active = false # change name meni ima drugo funkcijo gelde na status te variable

var button_focused : bool # tole setamo na false ko se odpre meni ... lahko bi tudi fokusiral na določen gumb
var main_menu_enabled : bool # je odveč?

onready var controller_list : Node = get_node("Table/ScrollContainer/ControllerList")


# -----------------------------------------------------------------------------------------------------------------------


func _ready() -> void: # tole bo šlo v open

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

	# pobiranje podatkov iz profilov
	controller_profiles = GameProfiles.default_controller_profiles

	#generiramo lajne
	for controller_name in controller_profiles.keys(): # za vsako ime profila v slovarju profili
		var new_controller_profile = controller_profiles[controller_name]
		add_controller_line(new_controller_profile, controller_name)

	show()
	enable_main_menu()


func close():

	disable_main_menu()
	hide();

	for child in controller_list.get_children():
		child.queue_free()

	Global.game_manager.toggle_pause()


func add_controller_line(new_controller_profile: Dictionary, controller_name: String):

	# dodaj linijo v controller_list in ji pošlji podatke
	var new_controller_line = controller_line.instance()

	new_controller_line.initialize(new_controller_profile, controller_name) # štartamo akcijo v sami liniji, katera poebere potrebne podatke
	new_controller_line.connect("ControlllerBtn_is_pressed", self, "_on_ControlllerBtn_is_pressed", [new_controller_profile, controller_name, new_controller_line])
	new_controller_line.connect("DeleteControllerBtn_is_pressed", self, "_on_DeleteControllerBtn_is_pressed", [controller_name, new_controller_line])

	if new_controller_profile["is_editable"] == false:
		new_controller_line.get_node("DeleteControllerBtn").remove_from_group("line_btns")
		new_controller_line.get_node("DeleteControllerBtn").set_disabled(true)
		new_controller_line.get_node("DeleteControllerBtn").focus_mode = FOCUS_NONE
		new_controller_line.get_node("ControllerBtn").remove_from_group("line_btns")
		new_controller_line.get_node("ControllerBtn").set_disabled(true)
		new_controller_line.get_node("ControllerBtn").focus_mode = FOCUS_NONE

	controller_list.add_child(new_controller_line)

	# če se linija generira zaradi "add controller" dobi status editirane
	if add_mode_active == true:
		line_in_editing = new_controller_line


func _on_DeleteControllerBtn_is_pressed(deleting_controller_name: String, deleting_controller_line: Node):

	# izbrišemo kontrole iz seznama kontrol
	deleting_controller_line.queue_free()
	controller_profiles.erase(deleting_controller_name)
	button_focused = false


func _on_ControlllerBtn_is_pressed(edited_controller_profile: Dictionary, edited_controller_name: String, edited_controller_line: Node):

	# setamo variable za prenašanje po filetu
	controller_in_editing = edited_controller_profile
	controller_in_editing_name = edited_controller_name
	line_in_editing = edited_controller_line
	$ControllerMenu.open(edited_controller_profile)
	disable_main_menu()


func _on_ControllerMenu_Editing_confirmed(confirmed_controller_profile: Dictionary) -> void:

	if add_mode_active == false:

		# zbrišemo stare kontrole iz slovarja kontrol
		controller_profiles.erase(controller_in_editing_name)

		print("Vsi profili po izbrisu:")
		print(controller_profiles.keys())

		# preverimo spremenjene akcije in jih prepišemo v editing slovarju
		for action in controller_in_editing:
			if confirmed_controller_profile.has(action):
				controller_in_editing[action] = confirmed_controller_profile[action]

		# sestavimo ime kontroler profila in prikaz kontrol
		var new_controller_name : String
		for action in controller_in_editing:
			if action != GameProfiles.controller_profiles_editable_key: # izločim "is_editable" ključ
				var input_key_name : String = OS.get_scancode_string(controller_in_editing[action]).substr ( 0, 2 ) # .to_upper()  # samo prva 2 karakter
				new_controller_name += str(input_key_name)

		# zapis imena in kontorol v linijo
		line_in_editing.initialize(controller_in_editing, new_controller_name)

		# zapis v slovar
		controller_profiles[new_controller_name] = controller_in_editing

	elif add_mode_active == true:

		# ustvarimo nov profil iz duplikata empty slovarja
		var new_controller_profile = GameProfiles.empty_controller_profile.duplicate()

		# spremenjene akcije prepišemo v nov profil
		for action in new_controller_profile:
			if confirmed_controller_profile.has(action):
				new_controller_profile[action] = confirmed_controller_profile[action]

		# sestavimo ime novega kontroler profila in prikaz kontrol
		var new_controller_name : String
		for action in new_controller_profile:
			if action != GameProfiles.controller_profiles_editable_key: # izločim "is_editable" ključ
				var input_key_name : String = OS.get_scancode_string(new_controller_profile[action]).substr ( 0, 2 ) # .to_upper()  # samo prva 2 karakter
				new_controller_name += str(input_key_name)

		# zapis v slovar
		controller_profiles[new_controller_name] = new_controller_profile

		# generiramo linijo
		add_controller_line(new_controller_profile, new_controller_name)

		add_mode_active = false

	enable_main_menu()


func _on_ControllerMenu_Editing_canceled() -> void:

	enable_main_menu()
	button_focused = false


func enable_main_menu():

	# vklopimo delovanje tipk menija
	set_process_input(true)

	# prižegmo glavne gumbe
	for menu_btn in get_tree().get_nodes_in_group("menu_btns"):
		menu_btn.set_disabled(false)
		menu_btn.focus_mode = FOCUS_ALL

	# pržegmo plejer-line gumbe
	for line_btn in get_tree().get_nodes_in_group("line_btns"):
		line_btn.set_disabled(false)
		line_btn.focus_mode = FOCUS_ALL
		pass

	# fejk stanje omogoči da deluejo glavni gumbi menija ... lahko bi tudi fokusiral na določen gumb
	button_focused = false


func disable_main_menu():

	# ugasnemo delovanje tipk menija
	set_process_input(false)

	# ugasnemo glavne gumbe
	for menu_btn in get_tree().get_nodes_in_group("menu_btns"):
		menu_btn.set_disabled(true)
		menu_btn.focus_mode = FOCUS_NONE

	# ugasnemo plejer-line gumbe
	for player_line_button in get_tree().get_nodes_in_group("line_btns"):
		player_line_button.set_disabled(true)
		player_line_button.focus_mode = FOCUS_NONE


func _on_AddBtn_pressed() -> void:

	$ControllerMenu.open(GameProfiles.empty_controller_profile)
	add_mode_active = true
	disable_main_menu()


func _on_QuitBtn_pressed() -> void:

	Global.game_manager.available_controller_profiles = controller_profiles # podamo vse controller profile v game manager

	print ("VSI KONTROLER PROFILI PRED IGRO")
	print (controller_profiles)

	close()


