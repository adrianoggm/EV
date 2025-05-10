extends Node3D

@export_category("Intensidad Base")
@export var base_intensity_clear: float = 2.0    # Intensidad en reposo de la luz clara

var _lc: OmniLight3D
var _anim: AnimationPlayer

func _ready() -> void:
	# Obtén aquí tus nodos hijos
	_lc   = $luzfuegoclara
	_anim = $AnimationPlayer

	# Ajusta la intensidad base
	_lc.light_energy = base_intensity_clear

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("titilar"):
		# Reproduce la animación ‘flick’ desde cero, sin blending
		_anim.play("flick", 0.0)
