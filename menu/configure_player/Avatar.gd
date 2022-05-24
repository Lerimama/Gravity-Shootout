extends Button

signal Avatar_selected

func _on_Avatar_pressed() -> void:
	emit_signal("Avatar_selected", self) # ta signal gre v AvatarMenu ... self kar zato, da se lahko lastnosti pobira
