extends Panel


signal Avatar_change_confirmed
signal Editing_canceled

var map_avatar = preload("res://menu/configure_player/Avatar.tscn")
var currently_selected_avatar_name : String # s tem opredelimo avatar, ki je trenutno izbran
var menu_edit_color : Color


onready var avatars_to_select: Dictionary = GameProfiles.avatar_menu_selection


# -----------------------------------------------------------------------------------------------------------------------


func _ready() -> void:

	set_process_input(false)
	hide()

	# generiramo mapo avatarjev
	for avatar_texture_name in avatars_to_select:

#			var current_avatar_icon = GameProfiles.default_avatars[avatar_texture_name] # avatar, ki se trenutno generira dobi ikono iz slovarja
			var current_avatar_icon = avatars_to_select[avatar_texture_name] # avatar, ki se trenutno generira dobi ikono iz slovarja

			var avatar_on_map = map_avatar.instance()
			avatar_on_map.icon = current_avatar_icon
			avatar_on_map.name = str(avatar_texture_name) # za klicanje, ko je vse generirano
			avatar_on_map.connect("Avatar_selected", self, "_on_Avatar_in_map_selected") # ob kliku avatar pošlje signal sem (s podatkom o ikoni)
			$AvatarMap.add_child(avatar_on_map)


func _input(event: InputEvent) -> void:

	if Input.is_action_just_released("ui_cancel"):
		_on_CancelBtn_pressed()



func open(edited_player_avatar_texture, edited_player_color): # tole se zgodi ob klicu iz player menija

	menu_edit_color = edited_player_color


	# pripšemo trenutnega avatarja na velik plejsholder
	$CurrentAvatar.texture = edited_player_avatar_texture
	$CurrentAvatar.modulate = menu_edit_color

	#označimo enakega avatarja na mapi avatarjev
	for avatar in $AvatarMap.get_children():
		if avatar.icon == edited_player_avatar_texture:
			avatar.modulate = menu_edit_color # avatar ki je enak trenutnemu obarvamo
			avatars_to_select[currently_selected_avatar_name] = avatar # tole je zato, da se lahko potem deselkta
#			GameProfiles.default_avatars[currently_selected_avatar_name] = avatar # tole je zato, da se lahko potem deselkta

			# focus
			avatar.grab_focus()

	show()
	set_process_input(true)


func _on_Avatar_in_map_selected(selected_avatar : Object):


	# najprej status selected dodamo trenutno izbranemu
#	GameProfiles.default_avatars[currently_selected_avatar_name] = selected_avatar
	avatars_to_select[currently_selected_avatar_name] = selected_avatar

	# potem za vsak karakter v mapi karakterjev pogledamo, kateri je enak izbranemu in apliciramo efekt
	for avatar in $AvatarMap.get_children():
		if avatar.icon == selected_avatar.icon:
			avatar.modulate = menu_edit_color
		else:
			avatar.modulate = GameProfiles.default_game_theme["menu_text_color"]

	# podamo teksturo plejerjevemu avatarju in mu damo ime izbranega avatarja ... določeno ob generaciji v mapo avatarjev
	$CurrentAvatar.texture = selected_avatar.icon


func _on_ConfirmBtn_pressed() -> void:

	# pošljemo izbranega avatarja ki je kar current avatar v plejerjev profil
	emit_signal("Avatar_change_confirmed", $CurrentAvatar)

	hide()
	reset_current_menu()
	set_process_input(false)


func _on_CancelBtn_pressed() -> void:
	emit_signal("Editing_canceled")
	hide()
	reset_current_menu()
	set_process_input(false)


func reset_current_menu():

	for avatar in $AvatarMap.get_children():
		avatar.modulate = Color.white
