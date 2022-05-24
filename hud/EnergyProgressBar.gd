extends HBoxContainer


# hud colors
var def_icon_color : Color = GameProfiles.default_game_theme["icon_color"]
var def_label_color : Color = GameProfiles.default_game_theme["label_color"]
var minus_color : Color = GameProfiles.default_game_theme["minus_color"]
var plus_color : Color = GameProfiles.default_game_theme["plus_color"]

# values
var def_energy : int
var current_energy : int # = maximum_value


func _ready() -> void:

	$TextureProgress.max_value = def_energy
	$Tween.interpolate_property($TextureProgress, "value", 0, def_energy, 0.3, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()

func _on_hud_energija_changed(new_energy):

	animate_bar_value(current_energy, new_energy)
	current_energy = new_energy	# pomembno zaporedje


func animate_bar_value(start, end):

	$Tween.interpolate_property($TextureProgress, "value", start, end, 0.6, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start()

	if end < start:
#		$Tween.reset()
		$Tween.interpolate_property($TextureProgress, "modulate", minus_color, def_icon_color, 0.7, Tween.CONNECT_ONESHOT, Tween.EASE_OUT)
#		$Tween.start()
	else:
#		$Tween.reset()
		$Tween.interpolate_property($TextureProgress, "modulate", plus_color, def_icon_color, 2, Tween.CONNECT_ONESHOT, Tween.EASE_OUT)
#		$Tween.start()

#func _on_Tween_tween_all_completed() -> void:
#
#	$Tween.interpolate_property($TextureProgress, "tint_progress", Color.purple, Color.white, 1.6, Tween.CONNECT_ONESHOT, Tween.EASE_OUT)
#	$TextureProgress.tint_progress = Color.white
