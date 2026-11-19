# InteractableArea.gd
# Componente desacoplado para objetos interactivos del mundo (/disenador_de_niveles)
extends Area2D

@export var prompt_text: String = "Interactuar"

signal interacted()

func _ready() -> void:
	add_to_group("interactables")
	collision_layer = 4 # Capa 3 / bits de interaccion (Layer 3 en Godot = 4)
	collision_mask = 0

func interact() -> void:
	emit_signal("interacted")
