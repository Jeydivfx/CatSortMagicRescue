
extends RefCounted
const L=preload("res://scripts/localization.gd")

static func name_prompt(g: Node, preview: bool=false) -> void:
    preload("res://scripts/name_entry.gd").show(g,preview)

static func show(g: Node) -> void:
    preload("res://scripts/rankings_menu.gd").build(g)
