@tool
extends Area3D

@export var item:ItemData:
	set(value):
		item = value
		set_item(value)

@export var mesh_size:float = .5

@onready var mesh = $Mesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Account for the item being set in the editor, instead of programaticly
	if item:
		set_item(item)
	#Bind the touch event for pickup
	body_entered.connect(on_touch)


func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	rotation.y += delta


func set_item(new_item:ItemData):
	if not new_item == item: item = new_item
	if not mesh: return
	mesh.mesh = item.mesh
	#Scale the mesh so the item appears a consistent size regardless of source mesh size
	var extents = mesh.mesh.get_aabb()
	var new_scale = mesh_size / maxf(maxf(extents.size.x, extents.size.y), extents.size.z)
	mesh.scale = Vector3(new_scale,new_scale,new_scale)


func on_touch(body:Node3D):
	#Try to find an inventory component for the touching body
	var inv:Inventory = null
	for child in body.get_children():
		if child is Inventory: inv = child
	#If the touching body doesn't have an inventory child, then exit
	if not inv: return
	#Add the item to the inventory we found and then remove ourselves
	var remaining = inv.add_item(item, 1)
	if remaining == 0 : queue_free()
