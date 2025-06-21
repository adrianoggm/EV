extends CharacterBody3D

@export var speed: float            = 15.0
@export var sensitivity: float      = 0.002
@export var max_step_height: float  = 0.3

# Parámetros de vuelo
@export var fly_speed: float        = 10.0
@export var fly_horiz_factor: float = 0.5   # la mitad de velocidad lateral
@export var fly_gravity: float      = 0.0

@onready var yaw_node   = $Yaw
@onready var pitch_node = $Yaw/Pitch
@onready var cam        = $Yaw/Pitch/Camera3D
@onready var test_node  = get_node("/root/World/Test")

# referencias para el pickup
@onready var ray           = $Yaw/Pitch/Camera3D/RayCast3D
@onready var socket_right  = $Yaw/Pitch/HeldItemSocketRight
@onready var socket_center = $Yaw/Pitch/HeldItemSocketCenter
var held_item: RigidBody3D   = null
var held_original_layer: int

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var active  = true

func _ready():
	if not yaw_node or not pitch_node or not cam or not test_node:
		push_error("Revisa Yaw, Pitch, Camera3D y /root/World/Test")
		return

	_activate_fpv()
	test_node.connect("camara_1", Callable(self, "_activate_fpv"))
	test_node.connect("camara_2", Callable(self, "_deactivate_fpv"))

func _activate_fpv():
	active = true
	cam.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _deactivate_fpv():
	active = false
	cam.current = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if not active:
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		pitch_node.rotate_x(-event.relative.y * sensitivity)
		pitch_node.rotation_degrees.x = clamp(pitch_node.rotation_degrees.x, -80, 80)
	elif event.is_action_pressed("recoger"):
		_try_pickup()
	elif event.is_action_pressed("lanzar"):
		_throw_item()
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _physics_process(delta):
	if not active:
		return

	# Solo puedes volar si sostienes el nodo llamado "bolamorada"
	var can_fly = held_item and held_item.name == "bolamorada"
	var flying  = can_fly and Input.is_action_pressed("fly")  # fly = Space en InputMap

	# Gravedad / vuelo vertical
	if flying:
		velocity.y = fly_speed
	else:
		velocity.y -= gravity * delta

	# Movimiento horizontal
	var ix = Input.get_action_strength("fpv_derecha") - Input.get_action_strength("fpv_izquierda")
	var iz = Input.get_action_strength("fpv_delante")  - Input.get_action_strength("fpv_atras")
	var dir_input = Vector3(ix, 0, iz)

	if dir_input.length() > 0.01:
		dir_input = dir_input.normalized()
		var forward = -global_transform.basis.z
		var right   =  global_transform.basis.x
		var wish_dir = (forward * dir_input.z + right * dir_input.x).normalized()
		# Reduce la velocidad lateral al volar
		var current_speed = speed * (fly_horiz_factor if flying else 1.0)
		velocity.x = wish_dir.x * current_speed
		velocity.z = wish_dir.z * current_speed
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		velocity.z = lerp(velocity.z, 0.0, 0.1)

	# Settings de step
	floor_snap_length   = max_step_height
	floor_max_angle     = deg_to_rad(45)
	floor_stop_on_slope = true

	move_and_slide()

	# Mantener objeto en mano
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
		held_original_layer = held_item.collision_layer
		held_item.collision_layer = 0
		held_item.sleeping = true
		var p = held_item.get_parent()
		if p:
			p.remove_child(held_item)
		socket_right.add_child(held_item)
		held_item.transform = Transform3D.IDENTITY

func _throw_item():
	if not held_item:
		return

	# 1) Sacar del socket
	socket_right.remove_child(held_item)
	get_tree().get_root().add_child(held_item)

	# 2) Calcular transform de salida: 
	#    toma la posición de la cámara y añade un poco adelante
	var cam_xf = cam.global_transform
	var forward = -cam_xf.basis.z.normalized()
	var launch_pos = cam_xf.origin + forward * 1.0  # 1m delante de la cámara
	held_item.global_transform.origin = launch_pos

	# 3) Reactivar colisión y física
	held_item.collision_layer = held_original_layer
	held_item.sleeping = false

	# 4) Impulso limpio hacia adelante
	var strength = 20.0
	held_item.apply_impulse(Vector3.ZERO, forward * strength)

	held_item = null
