extends CharacterBody3D

@export var speed: float           = 15.0
@export var sensitivity: float     = 0.002
@export var max_step_height: float = 0.3

@onready var yaw_node   = $Yaw
@onready var pitch_node = $Yaw/Pitch
@onready var cam        = $Yaw/Pitch/Camera3D
@onready var test_node  = get_node("/root/World/Test")

# referencias para el pickup
@onready var ray           = $Yaw/Pitch/Camera3D/RayCast3D
@onready var socket_right  = $Yaw/Pitch/HeldItemSocketRight
@onready var socket_center = $Yaw/Pitch/HeldItemSocketCenter
var held_item: RigidBody3D = null
var held_original_layer: int

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var active  = true

func _ready():
	if not yaw_node or not pitch_node or not cam or not test_node:
		push_error("Revisa que existan Yaw, Pitch, Camera3D y /root/World/Test")
		return

	_activate_fpv()
	test_node.connect("camara_1", Callable(self, "_activate_fpv"))
	test_node.connect("camara_2", Callable(self, "_deactivate_fpv"))

func _activate_fpv() -> void:
	active = true
	cam.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _deactivate_fpv() -> void:
	active = false
	cam.current = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if not active:
		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		pitch_node.rotate_x(-event.relative.y * sensitivity)
		pitch_node.rotation_degrees.x = clamp(pitch_node.rotation_degrees.x, -80.0, 80.0)

	elif event.is_action_pressed("recoger"):
		_try_pickup()
	elif event.is_action_pressed("lanzar"):
		_throw_item()
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _physics_process(delta):
	if not active:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	var ix = Input.get_action_strength("fpv_derecha") - Input.get_action_strength("fpv_izquierda")
	var iz = Input.get_action_strength("fpv_delante")  - Input.get_action_strength("fpv_atras")
	var dir_input = Vector3(ix, 0, iz)

	if dir_input.length() > 0.01:
		dir_input = dir_input.normalized()
		var forward = -global_transform.basis.z
		var right   =  global_transform.basis.x
		var wish_dir = (forward * dir_input.z + right * dir_input.x).normalized()
		velocity.x = wish_dir.x * speed
		velocity.z = wish_dir.z * speed
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		velocity.z = lerp(velocity.z, 0.0, 0.1)

	floor_snap_length   = max_step_height
	floor_max_angle     = deg_to_rad(45)
	floor_stop_on_slope = true

	move_and_slide()

	# Si tenemos algo en la mano, pegamos su transform al socket derecho
	if held_item:
		held_item.global_transform = socket_right.global_transform

func _try_pickup():
	if held_item:
		return
	ray.force_raycast_update()
	if not ray.is_colliding():
		return
	var body = ray.get_collider()
	if body is RigidBody3D:
		held_item = body
		# desactiva colisión y física básica
		held_original_layer = held_item.collision_layer
		held_item.collision_layer = 0
		held_item.sleeping = true

		# quitar del padre actual antes de añadir al socket derecho
		var parent = held_item.get_parent()
		if parent:
			parent.remove_child(held_item)

		# montarlo en socket derecho y alinear
		socket_right.add_child(held_item)
		held_item.transform = Transform3D.IDENTITY

func _throw_item():
	if not held_item:
		return
	# quitar del socket derecho
	socket_right.remove_child(held_item)
	# reinsertar en la escena, en el centro
	get_tree().get_root().add_child(held_item)
	held_item.global_transform = socket_center.global_transform

	# reactivar colisión y física
	held_item.collision_layer = held_original_layer
	held_item.sleeping = false

	# aplicar impulso hacia donde mira la cámara
	var dir = -cam.global_transform.basis.z
	var strength = 20.0
	held_item.apply_impulse(Vector3.ZERO, dir * strength)

	held_item = null
