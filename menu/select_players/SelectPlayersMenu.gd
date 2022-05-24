extends Control


signal Start_game (activated_player_profiles)

const player_line = preload("res://menu/select_players/PlayerLine.tscn")

var activated_player_profiles: Dictionary
var button_focused : bool # tole setamo na false ko se odpre meni ... lahko bi tudi fokusiral na določen gumb
var main_menu_enabled : bool


var available_controller_profile_names: Array # imena za v dropdown
var player_profiles: Dictionary

onready var player_list : Node = get_node("Table/ScrollContainer/PlayerList")
#onready var player_profiles: Dictionary = Global.game_manager.available_player_profiles
#onready var available_controller_profile_names: Array = Global.game_manager.available_controller_profiles.keys() # samo za dropdown


# -----------------------------------------------------------------------------------------------------------------------


func _ready() -> void: # tole bo šlo v open

	$Table/BtnLine/ConfirmBtn.set_disabled(true)
	$Table/BtnLine/ConfirmBtn.focus_mode = Control.FOCUS_NONE

	set_process_input(false) # ugasnemo delovanje tipk
	main_menu_enabled = false
	hide()


func _input(event: InputEvent) -> void:

	# če je prižgan delete btn potem gremo ven iz delete plejer mode ...
	if Input.is_action_just_released("ui_cancel"):
#		Global.game_manager.toggle_menu()
		close()

	# fokusiraj gumb v meniju
	if Input.is_action_just_released("ui_left") && button_focused == false:
		$Table/BtnLine/QuitBtn.grab_focus()
		button_focused = true

	if Input.is_action_just_released("ui_right") && button_focused == false:
		$Table/BtnLine/ConfirmBtn.grab_focus()
		button_focused = true

	# fokusiraj gumb v meniju
	if Input.is_action_just_released("ui_up") && button_focused == false:
		$Table/BtnLine/QuitBtn.grab_focus()
		button_focused = true

	if Input.is_action_just_released("ui_down") && button_focused == false:
		$Table/BtnLine/ConfirmBtn.grab_focus()
		button_focused = true


func open():

	# povežemo Quit singal z game managerjem (tole je kar slaba praksa)
	var configure_player_menu = Global.node_creation_parent.get_node("MenuHolder/ConfigurePlayerMenu")
	self.connect("Start_game", Global.game_manager, "on_Start_game") # signal prihaja iz input lajne in gre v game managerja
	
	# povlečemo available controler in plerejer profile
	player_profiles = Global.game_manager.available_player_profiles
	available_controller_profile_names = Global.game_manager.available_controller_profiles.keys()


#	# v profil kontrolerjev dodamo ime praznega profila (če ni že bil dodan pri predhodnem odpiranju)
#	if (GameProfiles.empty_controller_name in available_controller_profile_names) == false:
#		available_controller_profile_names.push_front(GameProfiles.empty_controller_name)

	# generiramo lajne
	for player_name in player_profiles.keys(): # za vsako ime profila v slovarju profili
		var new_player_profile = player_profiles[player_name]
		add_line(new_player_profile, player_name)

	show()
	enable_main_menu()


func close():

	disable_main_menu()
	hide();

	for child in player_list.get_children():
		child.queue_free()

	Global.game_manager.toggle_pause()


func add_line(added_player_profile: Dictionary, added_player_name: String):

	var new_line = player_line.instance()
	new_line.initialize(added_player_name, available_controller_profile_names) # štartamo akcijo v sami liniji, katera poebere potrebne podatke
	new_line.connect("Player_activated", self, "_on_Player_activated", [added_player_name])
	new_line.connect("Player_deactivated", self, "_on_Player_deactivated", [added_player_name])
	new_line.connect("Controller_selected", self, "_on_Controller_selected", [added_player_name, new_line.get_node("ControllerBtn")])
	new_line.modulate = added_player_profile["player_color"]
	player_list.add_child(new_line)

	# disable controller dropdowne ker igralec je automatično neaktiven
	new_line.get_node("ControllerBtn").remove_from_group("line_btns")
	new_line.get_node("ControllerBtn").set_disabled(true)
	new_line.get_node("ControllerBtn").focus_mode = FOCUS_NONE
	print("ADDED")
	print(added_player_profile)


func _on_Player_activated(activated_player_name: String):
	activated_player_profiles[activated_player_name] = player_profiles[activated_player_name]
	_start_btn_manipulation()

func _on_Player_deactivated(deactivated_player_name: String):
	
	# plejerju zbrišemo kontrole, če smo mu jih že dodali (drugače se samodropdown restira)
	if activated_player_profiles[deactivated_player_name].has("player_controller"):
		activated_player_profiles[deactivated_player_name].erase("player_controller")
	
	# zbrišemo iz slovarja aktivnih igralcev
	activated_player_profiles.erase(deactivated_player_name) 

	_start_btn_manipulation()
	

func _on_Controller_selected(player_name: String, controller_btn: Node):

	var selected_controller_index: int = controller_btn.get_selected()
	var activated_player_profile = activated_player_profiles[player_name]


	if selected_controller_index != 0:
		var selected_controller_name: String = controller_btn.get_item_text(selected_controller_index)	
		# dodam kontrole v profil trenutnega igralca
		activated_player_profile["player_controller"] = selected_controller_name	
	else:
		# če je izbrana nula, potem zbrišem morebitne kontrole iz profila igralca
		activated_player_profile.erase("player_controller")		
	
	_start_btn_manipulation()
	
	
func disable_main_menu():

	# ugasnemo delovanje tipk menija
	set_process_input(false)

	# ugasnemo glavne gumbe
	$Table/BtnLine/ConfirmBtn.set_disabled(true)
	$Table/BtnLine/QuitBtn.focus_mode = FOCUS_NONE
	$Table/BtnLine/QuitBtn.set_disabled(true)
	$Table/BtnLine/QuitBtn.focus_mode = FOCUS_NONE


func enable_main_menu():

	# vklopimo delovanje tipk menija
	set_process_input(true)

	# naštimamo glavne gumbe
	$Table/BtnLine/ConfirmBtn.set_disabled(true)
	$Table/BtnLine/ConfirmBtn.focus_mode = FOCUS_NONE
	$Table/BtnLine/QuitBtn.set_disabled(false)
	$Table/BtnLine/QuitBtn.focus_mode = FOCUS_ALL

	button_focused = false


func _start_btn_manipulation():
	
	# če je slovar aktivnih igralcev prazen ... disable start btn
	if activated_player_profiles.empty():
		$Table/BtnLine/ConfirmBtn.set_disabled(true)
		$Table/BtnLine/ConfirmBtn.focus_mode = Control.FOCUS_NONE
		print("PRAZN")
	
	# če slovar aktivnih igralcev NI prazen ... preverjaj, če so setane vse kontroledisable start btn
	else:
		print("POLN")
		for profile in activated_player_profiles.keys():
			print(activated_player_profiles[profile])
			
			if activated_player_profiles[profile].has("player_controller") == false:
				print("NIMA")
				# disable start
				$Table/BtnLine/ConfirmBtn.set_disabled(true)
				$Table/BtnLine/ConfirmBtn.focus_mode = FOCUS_NONE
				break
			else:
				print("MA")
				# enable start btn
				$Table/BtnLine/ConfirmBtn.set_disabled(false)
				$Table/BtnLine/ConfirmBtn.focus_mode = FOCUS_ALL
	

func _on_ConfirmBtn_pressed() -> void:
	emit_signal("Start_game", activated_player_profiles) # v GM se pošljejo profili igralcev s pripisanimi imeni kontrol
	close()
	
	print ("KATIVIRANI PROFILI")
	print (activated_player_profiles)


func _on_QuitBtn_pressed() -> void:
	close()

