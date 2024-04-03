extends PanelContainer
class_name ItemSlotPanel

@export var label_settings:LabelSettings

@onready var amount:Label = $Aspect/ItemPanel/Label
@onready var item:ItemPanel = $Aspect/ItemPanel
static var plugin_settings:ItemizingOptions = preload("res://addons/itemizing/options.tres")

var owning_data:SlotData:
	set(value):
		if owning_data: owning_data.changed.disconnect(redraw)
		owning_data = value
		if owning_data: 
			owning_data.changed.connect(redraw)
			#if owning_data.item: print('Owning data for slot changed')
		if item: redraw()

var owning_inventory:Inventory
var is_hovering:bool = false
var slot_id:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if label_settings:
		amount.label_settings = label_settings
	if owning_data: redraw()
	mouse_entered.connect(on_hover_start)
	mouse_exited.connect(on_hover_end)
	gui_input.connect(on_input)

func _process(delta: float) -> void:
	if not is_hovering: return
	item.mesh.rotation.y = item.mesh.rotation.y + delta


func on_input(input:InputEvent):
	if input is InputEventMouseButton:
		if input.double_click:
			if owning_data.item:
				if owning_data.item.on_use(owning_inventory):
					#consume item if signaled to do so
					owning_inventory.remove_from_slot(owning_data.slot_id, 1)

func on_hover_start():
	is_hovering = true
	item.viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_PARENT_VISIBLE

func on_hover_end():
	is_hovering = false
	item.mesh.rotation.y = plugin_settings.item_display_3D_mesh_base_rotation
	item.viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await get_tree().physics_frame

func redraw():
	await get_tree().process_frame
	if not owning_data or not owning_data.item:
		item.current_item = null
		amount.hide()
		tooltip_text = ''
	else : 
		#print('Redrawing slot')
		item.current_item = owning_data.item
		amount.text = str(owning_data.amount)
		if owning_data.amount > 1:
			amount.show()
		else:
			amount.hide()
		tooltip_text = str(owning_data.item.name, '\n', owning_data.item.description)
