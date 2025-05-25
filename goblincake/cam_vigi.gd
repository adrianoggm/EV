extends Node3D

@export var min_y_deg: float = -90.0
@export var max_y_deg: float = 0.0
@export var rotation_sensitivity: float = 0.4  # grados por píxel de ratón
@export var min_fov: float = 20.0
@export var max_fov: float = 70.0
@export var zoom_sensitivity: float = 5.0  # grados de FOV por acción de zoom

@onready var cam       = $Camera3D
@onready var test_node = get_node("/root/World/Test")

var active: bool = false

func _ready():
	# Apuntar inicialmente a -180° en el eje Y
	rotation_degrees.y = 0
	cam.current = false
	test_node.connect("camara_2", Callable(self, "_on_activate"))
	test_node.connect("camara_1", Callable(self, "_on_deactivate"))

func _on_activate():
	cam.current = true
	active = true

func _on_deactivate():
	cam.current = false
	active = false

func _input(event):
	if not active:
		return

	# Rotación horizontal basada en movimiento de ratón
	if event is InputEventMouseMotion:
		var new_y = rotation_degrees.y - event.relative.x * rotation_sensitivity
		rotation_degrees.y = clamp(new_y, min_y_deg, max_y_deg)

	# Zoom mediante acciones definidas en Input Map: "zoom_in" y "zoom_out"
	elif event.is_action_pressed("zoom_in"):
		cam.fov = clamp(cam.fov - zoom_sensitivity, min_fov, max_fov)
	elif event.is_action_pressed("zoom_out"):
		cam.fov = clamp(cam.fov + zoom_sensitivity, min_fov, max_fov)
