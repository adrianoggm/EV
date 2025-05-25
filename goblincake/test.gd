extends Node

signal camara_1
signal camara_2

func _input(event):
	if event.is_action_pressed("switch_cam1"):
		emit_signal("camara_1")
	elif event.is_action_pressed("switch_cam2"):
		emit_signal("camara_2")
