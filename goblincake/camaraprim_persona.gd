extends Node3D

@export var speed: float = 15.0
@export var sensibility: float = 50.0

@onready var yaw_node   = $Yaw
@onready var pitch_node = $Yaw/Pitch
@onready var cam        = $Yaw/Pitch/Camera3D
@onready var test_node  = get_node("/root/World/Test")

func _ready():
	# Al empezar, la cámara FPV está activa
	cam.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Conectar señales para controlar activación
	test_node.connect("camara_1", Callable(self, "_on_activate"))
	test_node.connect("camara_2", Callable(self, "_on_deactivate"))

func _on_activate():
	cam.current = true

func _on_deactivate():
	cam.current = false

func _input(event):
	if not cam.is_current():
		return

	if event is InputEventMouseMotion:
		# Rotación yaw (horizontal)
		yaw_node.rotate_y(deg_to_rad(-event.relative.x / sensibility))
		# Rotación pitch (vertical) con límites
		var new_pitch = pitch_node.rotation.x - deg_to_rad(event.relative.y / sensibility)
		pitch_node.rotation.x = clamp(new_pitch, deg_to_rad(-80), deg_to_rad(80))
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _physics_process(delta):
	if not cam.is_current():
		return

	# Movimiento en XZ relativo a yaw
	var x_dir = Input.get_action_strength("fpv_derecha") - Input.get_action_strength("fpv_izquierda")
	var z_dir = Input.get_action_strength("fpv_delante") - Input.get_action_strength("fpv_atras")
	var input_dir = Vector3(x_dir, 0, z_dir)
	if input_dir == Vector3.ZERO:
		return
	input_dir = input_dir.normalized()

	var forward = -yaw_node.global_transform.basis.z
	var right   = yaw_node.global_transform.basis.x
	var movement = (forward * input_dir.z + right * input_dir.x) * speed * delta
	yaw_node.global_translate(movement)
