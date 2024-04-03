@tool
extends Node3D

@export var mesh:Mesh:
	set(value):
		mesh = value
		if Engine.is_editor_hint() and mesh: $Mesh.mesh = value
@export var loot_table:LootTable
@export var item_pickup_template:PackedScene
@export var respawn_time:float = 2

@onready var loot_gen:LootGenerator = $LootGenerator
@onready var mesh_instance = $Mesh
@onready var collision:Area3D = $Area3D

var mesh_collision:StaticBody3D
var harvestable:bool = true
var timer:float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh_instance.mesh = mesh
	if Engine.is_editor_hint(): return
	mesh_instance.create_trimesh_collision()
	loot_gen.rolls = loot_table
	await get_tree().process_frame
	for child in mesh_instance.get_children(true):
		if child is StaticBody3D: mesh_collision = child


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if harvestable: return
	timer -= delta
	if timer <= 0: 
		harvestable = true
		mesh_instance.mesh = mesh
		collision.monitorable = true
		mesh_collision.process_mode = Node.PROCESS_MODE_INHERIT


func on_interact(interactor:Node3D):
	if not harvestable: return
	harvestable = false
	timer = respawn_time
	mesh_instance.mesh = null
	collision.monitorable = false
	mesh_collision.process_mode = Node.PROCESS_MODE_DISABLED
	var items:Array[ItemData] = loot_gen.get_loot()
	for item in items:
		var pickup = item_pickup_template.instantiate()
		pickup.item = item
		get_tree().root.add_child(pickup)
		pickup.position = global_position
		pickup.position.y += .5
		pickup.position += Vector3(1,0,0).rotated(Vector3(0,1,0), deg_to_rad(randf_range(0,360)))

