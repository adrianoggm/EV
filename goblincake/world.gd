extends Node3D

@onready var cocina       = $Cocina
@onready var torreon      = $torreon/Salonreal
@onready var area_to_cocina  = $AreaToCocina 
@onready var area_to_torreon  = $AreaToTorreon
var current_room := "Cocina"  # estado inicial

func _ready():
	area_to_torreon.connect("body_entered", Callable(self, "_on_enter_torreon"))
	area_to_cocina.connect("body_entered", Callable(self, "_on_enter_cocina"))
	# Asegúrate de que Cocina está visible y Torreón oculto
	cocina.visible = true
	cocina.set_physics_process(true)
	torreon.visible = false
	torreon.set_physics_process(false)

func _on_enter_torreon(body):
	if body is CharacterBody3D and current_room == "Cocina":
		_switch_to("Torreon")

func _on_enter_cocina(body):
	if body is CharacterBody3D and current_room == "Torreon":
		_switch_to("Cocina")

func _switch_to(target: String):
	match target:
		"Cocina":
			cocina.visible = true
			cocina.set_physics_process(true)
			torreon.visible = false
			torreon.set_physics_process(false)
		"Torreon":
			torreon.visible = true
			torreon.set_physics_process(true)
			cocina.visible = false
			cocina.set_physics_process(false)
	current_room = target
