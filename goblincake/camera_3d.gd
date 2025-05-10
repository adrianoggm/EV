extends Camera3D

# Variables para configurar la cámara orbital
var target: Node3D = null  # Nodo padre como objetivo
var distance: float = 60.0  # Distancia fija al target
var azimuth: float = 0.0  # Ángulo horizontal (en grados)
var elevation: float = 20.0  # Ángulo vertical (en grados)
var rotation_speed: float = 60.0  # Velocidad de rotación en grados por segundo

func _ready() -> void:
	# Asigna el nodo padre como target si es un Node3D
	if get_parent() is Node3D:
		target = get_parent()
	else:
		push_error("El nodo padre no es un Node3D, la cámara no podrá orbitar correctamente.")

func _process(delta: float) -> void:
	if target == null:
		return

	# Control de la cámara con las teclas WASD:
	if Input.is_action_pressed("arriba"):
		elevation = clamp(elevation + rotation_speed * delta, -80, 80)
	if Input.is_action_pressed("abajo"):
		elevation = clamp(elevation - rotation_speed * delta, -80, 80)
	if Input.is_action_pressed("izquierda"):
		azimuth += rotation_speed * delta
	if Input.is_action_pressed("derecha"):
		azimuth -= rotation_speed * delta
		

	# Convertir los ángulos a radianes para los cálculos trigonométricos
	var rad_azimuth = deg_to_rad(azimuth)
	var rad_elevation = deg_to_rad(elevation)

	# Calcular la posición de la cámara usando coordenadas esféricas
	var cam_x = distance * cos(rad_elevation) * cos(rad_azimuth)
	var cam_y = distance * sin(rad_elevation)
	var cam_z = distance * cos(rad_elevation) * sin(rad_azimuth)
	
	# Actualizar la posición global de la cámara y hacer que mire al target
	global_transform.origin = target.global_transform.origin + Vector3(cam_x, cam_y, cam_z)
	look_at(target.global_transform.origin, Vector3.UP)
