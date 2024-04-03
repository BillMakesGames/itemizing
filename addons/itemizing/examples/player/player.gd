extends CharacterBody3D
class_name ItemExamplePlayer

const SPEED = 10.0
const JUMP_VELOCITY = 10.5

@export var mesh:MeshInstance3D
@export var animation:AnimationPlayer
@export var cam_mount:Node3D

@onready var interact_sphere:Area3D = $InteractSphere
@onready var inv_panel:PanelContainer = $InventoryContainer

var gravity: float = 30
var current_health:int = 100
var current_target:Node3D
var was_mouse_pressed:bool = false
var interact_icon:Sprite3D
var was_i_pressed = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	interact_icon = Sprite3D.new()
	interact_icon.texture = preload("res://addons/itemizing/icons/down-arrow.png")
	interact_icon.hide()
	interact_icon.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	interact_icon.pixel_size = 0.005
	interact_icon.render_priority = 10
	interact_icon.fixed_size = true
	interact_icon.alpha_cut = SpriteBase3D.ALPHA_CUT_OPAQUE_PREPASS
	interact_icon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	get_tree().root.add_child.call_deferred(interact_icon)

func focus_panel_input(event:InputEvent):
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE: return
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(event.relative.x / 5 * -1))
		cam_mount.rotation.x += deg_to_rad(event.relative.y / 5)
		cam_mount.rotation.x = clamp(cam_mount.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _physics_process(delta: float) -> void:
	#InputLockEscape
	if Input.is_physical_key_pressed(KEY_ESCAPE):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	#Basic gravity
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, -gravity, delta * 30)

	if Input.is_action_just_pressed('ui_accept') and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir == Vector2.ZERO:
		if Input.is_physical_key_pressed(KEY_W) and not Input.is_physical_key_pressed(KEY_S):
			input_dir.y = -1
		elif Input.is_physical_key_pressed(KEY_S) and not Input.is_physical_key_pressed(KEY_W):
			input_dir.y = 1
		if Input.is_physical_key_pressed(KEY_A) and not Input.is_physical_key_pressed(KEY_D):
			input_dir.x = -1
		elif Input.is_physical_key_pressed(KEY_D) and not Input.is_physical_key_pressed(KEY_A):
			input_dir.x = 1
	input_dir = input_dir * -1

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		input_dir.x = -input_dir.x
		mesh.rotation.y = input_dir.angle() - deg_to_rad(90)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	#update health bar
	$HealthBar.value = current_health

	#Handle inventory toggle
	if Input.is_physical_key_pressed(KEY_I):
		if not was_i_pressed:
			if inv_panel.visible:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else :
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			was_i_pressed = true
			inv_panel.visible = not inv_panel.visible
	else :
		if was_i_pressed:
			was_i_pressed = false

	#animation
	if is_on_floor():
		if input_dir == Vector2.ZERO:
			animation.play("Idle")
		else :
			animation.play("Running")
	else :
		animation.play("Falling")

	#interaction
	update_interaction()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not was_mouse_pressed:
			was_mouse_pressed = true
			if current_target:
				current_target.on_interact(self)
	else:
		if was_mouse_pressed:
			was_mouse_pressed = false
		



func update_interaction():
	var hits = interact_sphere.get_overlapping_areas()
	var smallest_distance:float = INF
	var new:Node3D
	for hit in hits:
		hit = hit.get_parent()
		if not hit.has_method('on_interact'): continue
		var distance = hit.global_position.distance_squared_to(global_position)
		if distance > smallest_distance: continue
		smallest_distance = distance
		new = hit
		#print('New interact canidate ', new)
	if not new == current_target:
		current_target = new
		#print('------Interact target updated : ', new)
		if new: 
			interact_icon.show()
			interact_icon.global_position = new.global_position
			interact_icon.global_position.y += 2
		else :
			interact_icon.hide()
		



func adjust_health(amount:int):
	current_health = clamp(current_health + amount, 0, 100)
