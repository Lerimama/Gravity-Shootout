extends Button

signal Character_selected


func _on_MapCharacter_pressed() -> void:
	emit_signal("Character_selected", self) # ta signal gre v NameMenu
