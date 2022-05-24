extends VBoxContainer


signal Action_pressed

func _ready() -> void:
	pass

func _on_ActionBtn_pressed() -> void:
	emit_signal("Action_pressed", self) # ta signal gre v ColorMenu ... self kar zato, da se lahko lastnosti pobira
