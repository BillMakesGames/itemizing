@tool
extends PanelContainer

signal slot_changed(slot_id:int, new_amount:int, item:ItemData)

@export var selector_btn:Button

var item_picker:EditorResourcePicker
var slot_id:int
var current_amount:int
var current_item:ItemData
var item_picker_dialogue:PackedScene = preload("res://addons/itemizing/editors/item_selector.tscn")

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	var container = $margin/hcontainer
	item_picker = EditorResourcePicker.new()
	container.add_child(item_picker)
	item_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_picker.base_type = "ItemData"
	item_picker.resource_changed.connect(on_item_changed)
	$margin/hcontainer/Amount.value_changed.connect(on_amount_changed)
	selector_btn.pressed.connect(show_item_selector)

func show_item_selector():
	var selector = item_picker_dialogue.instantiate()
	add_child(selector)
	selector.on_item_selected.connect(on_item_changed)


func on_item_changed(new:ItemData):
	current_item = new
	if new:
		$margin/hcontainer/Amount.visible = true
		if current_amount < 1: current_amount = 1
	else : 
		$margin/hcontainer/Amount.visible = false
		current_amount = 1
	slot_changed.emit(slot_id, current_amount, new)


func on_amount_changed(new:int):
	if new > current_item.max_stack:
		$margin/hcontainer/Amount.value = current_item.max_stack
		return
	current_amount = new
	slot_changed.emit(slot_id, current_amount, current_item)


func display_data(data:SlotData, id:int):
	slot_id = id
	current_amount = data.amount
	current_item = data.item
	if data.item:
		$margin/hcontainer/Amount.value = data.amount
		$margin/hcontainer/Amount.visible = true
		item_picker.show()
	else :
		$margin/hcontainer/Amount.visible = false
		#item_picker.hide()
	if data.item != item_picker.edited_resource: item_picker.edited_resource = data.item
