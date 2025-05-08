extends Node

# Retardo opcional entre animaciones (segundos)
@export var delay_between := 0.1

# Referencias a los AnimationPlayer dentro de OllaAnimada
#onready var olla_anim = $olla/AnimationPlayer as AnimationPlayer
@onready var tapa_anim = $tapa/AnimationPlayer     as AnimationPlayer
@onready var cuch_anim = $cucharon/AnimationPlayer  as AnimationPlayer

func _input(event):
	if event.is_action_pressed("animacion"):
		# --- Lanzamiento simultáneo de las 3 animaciones ---
		#olla_anim.play("Plot_aplicado_001Action") está vacía en el futuro tendrá las texturas moviendose para el agua
		tapa_anim.play("Quitartapa")
		cuch_anim.play("ponerquitarcucharonmoviendo")
		
		# --- O, con pequeños desfases, descomenta esta sección ---
		# -- Godot 4:
		# olla_anim.play("anim_olla")
		# await get_tree().create_timer(delay_between).timeout
		# tapa_anim.play("anim_tapa")
		# await get_tree().create_timer(delay_between).timeout
		# cuch_anim.play("anim_cucharon")
		
		# -- Godot 3.x:
		# olla_anim.play("anim_olla")
		# yield(get_tree().create_timer(delay_between), "timeout")
		# tapa_anim.play("anim_tapa")
		# yield(get_tree().create_timer(delay_between), "timeout")
		# cuch_anim.play("anim_cucharon")
