extends VBoxContainer


signal Action_is_edited


func _on_ActionBtn_pressed() -> void:
	emit_signal("Action_is_edited", self) # ta signal gre v ColorMenu ... self kar zato, da se lahko lastnosti pobira
