extends ColorRect


signal Color_selected

func _on_ColorBtn_pressed() -> void:
	emit_signal("Color_selected", self) # ta signal gre v ColorMenu ... self kar zato, da se lahko lastnosti pobira
