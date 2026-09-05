extends Resource
## Presentation palette only; never imported by the rules module.
@export var plain: Color = Color("778064")
@export var wood: Color = Color("435a48")
@export var hill: Color = Color("a39a73")
@export var river: Color = Color("3d626c")
@export var bridge: Color = Color("a28b61")
@export var heaven: Color = Color("dfc991")
@export var hell: Color = Color("873e3a")

func terrain_color(terrain: String) -> Color:
	match terrain:
		"wood": return wood
		"hill": return hill
		"river": return river
		"bridge": return bridge
	return plain
