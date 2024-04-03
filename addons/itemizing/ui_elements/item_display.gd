extends PanelContainer
class_name ItemPanel

enum view_mode {MODE_2D, MODE_3D}

@export var current_item:ItemData:
	set(value):
		current_item = value
		update_view()
		#if value: current_item.changed.connect(update_view)
@export var mode:view_mode
static var plugin_settings:ItemizingOptions = preload("res://addons/itemizing/options.tres")

var texture:TextureRect
var mesh:MeshInstance3D
var camera:Camera3D
var viewport:SubViewport
static var environment = load("res://addons/itemizing/item_view_environment.tres")

func _ready() -> void:
	texture = TextureRect.new()
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	add_child(texture)
	#3D Nodes
	if mode == view_mode.MODE_3D:
		viewport = SubViewport.new()
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		viewport.transparent_bg = true
		viewport.world_3d = World3D.new()
		viewport.world_3d.environment = environment
		add_child(viewport)
		camera = Camera3D.new()
		viewport.add_child(camera)
		camera.position = Vector3(0, plugin_settings.item_display_3D_camera_height, 1)
		camera.look_at(Vector3.ZERO)
		mesh = MeshInstance3D.new()
		viewport.add_child(mesh)
		texture.texture = viewport.get_texture()
		var light = DirectionalLight3D.new()
		viewport.add_child(light)
		light.rotation = Vector3(60, 180, 0)
	#await get_tree().process_frame
	update_view()


func update_view():
	if not texture: return
	if not current_item:
		texture.texture = null
		return
	#print('Updating item slot view')
	if mode == view_mode.MODE_2D:
		texture.texture = current_item.sprite
	elif mode == view_mode.MODE_3D:
		if not current_item.mesh:
			mesh.mesh = null
		else :
			texture.texture = viewport.get_texture()
			#print('Setting mesh to ', current_item.name)
			mesh.mesh = current_item.mesh
			var extents = mesh.mesh.get_aabb()
			var new_scale = 1 / maxf(maxf(extents.size.x, extents.size.y), extents.size.z)
			mesh.scale = Vector3(new_scale,new_scale,new_scale)
			extents = mesh.mesh.get_aabb()
			var center = extents.get_center() * new_scale
			mesh.position = Vector3(-center.x, -center.y, -center.z)
			mesh.rotation.y = 90
		await get_tree().process_frame
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
