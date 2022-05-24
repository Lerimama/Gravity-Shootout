extends Panel


signal Color_change_confirmed
signal Editing_canceled

var map_color_sq : Object = preload("res://menu/configure_player/ColorSq.tscn")

var currently_selected_color_name : String # s tem opredleimo kaj trenutno selectano, tako da definiramo "efekt

onready var colors_to_select: Dictionary = GameProfiles.color_menu_selection


# -----------------------------------------------------------------------------------------------------------------------


func _ready() -> void:
	set_process_input(false)
	hide()

	# generiramo mapo avatarjev
	for color_key in colors_to_select.keys():

			var current_color : Color = colors_to_select[color_key] # barva, ki se aplicira na generiran ColorSq dobi barvo iz slovarja

			# generacija colorSq
			var colorsq_on_map = map_color_sq.instance()
			colorsq_on_map.color = current_color
			colorsq_on_map.name = str(color_key) # za klicanje, ko je vse generirano
			colorsq_on_map.connect("Color_selected", self, "_on_Color_in_map_selected") # ob kliku avatar pošlje signal sem (s podatkom o ikoni)
			$ColorMap.add_child(colorsq_on_map)

func _input(event: InputEvent) -> void:

	if Input.is_action_just_released("ui_cancel"):
		_on_CancelBtn_pressed()


func open(edited_player_current_color : Color): # tole se zgodi ob klicu iz player menija


	# obarvamo velik color rect
	$CurrentColor.color = edited_player_current_color

	for colorsq in $ColorMap.get_children():
		if colorsq.color == edited_player_current_color:
			colorsq.get_node("ColorBtn").pressed = true
#			ColorSq.rect_min_size = GameProfiles.default_game_theme["menu_colorsq_select_size"]
			colors_to_select[currently_selected_color_name] = colorsq # tole je zato, da se lahko potem deselekta

			# focus
			colorsq.get_node("ColorBtn").grab_focus()

	show()
	set_process_input(true)


func _on_Color_in_map_selected(selected_colorsq : Object):

	# najprej status selected dodamo trenutno izbranemu
	colors_to_select[currently_selected_color_name] = selected_colorsq

	# potem za vsak karakter v mapi karakterjev pogledamo, kateri je enak izbranemu in apliciramo efekt
	for colorsq in $ColorMap.get_children():
		if colorsq.color == selected_colorsq.color:
			colorsq.get_node("ColorBtn").pressed = true
#			colorsq.rect_min_size = GameProfiles.default_game_theme["menu_colorsq_select_size"]
		else:
			colorsq.get_node("ColorBtn").pressed = false
#			colorsq.rect_min_size = GameProfiles.default_game_theme["menu_colorsq_size"]

	# podamo novo barvo plejerjev barvi
	$CurrentColor.color = selected_colorsq.color


func _on_ConfirmBtn_pressed() -> void:

	# pošljemo izbrani barvni rectangle v meni za v plejerjev profil
	emit_signal("Color_change_confirmed", $CurrentColor)

	hide()
	reset_current_menu()
	set_process_input(false)


func _on_CancelBtn_pressed() -> void:
	emit_signal("Editing_canceled")
	hide()
	reset_current_menu()
	set_process_input(false)


func reset_current_menu():

	for ColorSq in $ColorMap.get_children():
		ColorSq.rect_min_size = GameProfiles.default_game_theme["menu_colorsq_size"]
