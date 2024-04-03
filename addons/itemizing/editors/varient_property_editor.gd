@tool
extends HBoxContainer

signal value_changed(param_name:String, value)

@export var name_label:Label

var param_name:String
var param_type:int
var editor
var current_value

func set_param(new_name:String, type:int, value = null):
	name_label.text = new_name.to_pascal_case()
	param_name = new_name
	param_type = type

	if value: current_value = value

	if type == 1:
		editor = CheckBox.new()
		editor.toggled.connect(checkbox_toggled)
		if value: 
			editor.button_pressed = true
	elif type == 2:
		editor = SpinBox.new()
		editor.rounded = true
		editor.allow_greater = true
		editor.allow_lesser = true
		editor.value_changed.connect(spinbox_changed)
		if value:
			editor.value = value
	elif type == 3:
		editor = SpinBox.new()
		editor.step = .1
		editor.allow_greater = true
		editor.allow_lesser = true
		editor.value_changed.connect(spinbox_changed)
		if value:
			editor.value = value
	elif type == 4:
		editor = LineEdit.new()
		editor.text_submitted.connect(text_changed)
		if value:
			editor.text = value
	else :
		editor = Label.new()
		editor.text = 'Unsupported type!'
	add_child(editor)
	editor.size_flags_horizontal = SIZE_EXPAND_FILL


func checkbox_toggled(new:bool):
	current_value = new
	value_changed.emit(param_name, new)

func spinbox_changed(new):
	current_value = new
	value_changed.emit(param_name, new)

func text_changed(new:String):
	current_value = new
	value_changed.emit(param_name, new)