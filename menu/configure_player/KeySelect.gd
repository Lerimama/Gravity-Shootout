extends Label


signal Key_selected(scancode)


var actionblock_in_editing : Node

func _ready():


	set_process_input(false) # tako pusti pri miru tipke, dokler se ne odpre
	hide()

func _input(event): # ob pritisku beležimo akcijo

	# miš ven
	if event is InputEventKey and Input.is_action_just_pressed("ui_cancel") != true:
		emit_signal("Key_selected", event.scancode, actionblock_in_editing) # signal gre v controller meni in pošlje akcijož
		close()

#	# esc za exit
#	elif Input.is_action_just_pressed("ui_cancel"): # ugasnemo na ESC
#		close()
#		print("cancel")
#		return

func open(selected_action_block): # zbrisal edited_action_name : String ... debugger

	actionblock_in_editing = selected_action_block
	text = "IZBERI TIPKO ZA \"%s\"" % selected_action_block.name.to_upper()
	show()
	set_process_input(true)  # štartamo precesiranje inputa v sceni

func close():
	hide()
	set_process_input(false) # ustavimo preocesiranje inputa v sceni
