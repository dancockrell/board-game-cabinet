class_name CabinetGameDefinition
extends Resource
## Content identity and topology, not a universal rules engine.
@export var game_id: String = "chess"
@export var display_name: String = "Chess"
@export var files: int = 8
@export var ranks: int = 8
@export_enum("cells", "intersections") var placement: String = "cells"
@export var rules_version: int = 1
