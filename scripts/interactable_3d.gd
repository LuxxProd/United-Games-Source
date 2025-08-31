class_name Interactable3D extends Area3D

signal interacted_with


func _init() -> void:
	monitoring = false


func interact() -> void:
	interacted_with.emit()
