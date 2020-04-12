extends Node2D

func _ready():
	# atribuo objetos do grupo em questão a nodes
	var nodes = _get_all_nodes_from_group("player")
	# itero nodes e conecto todos os objs ao respectivo Node
	for player in nodes:
		player.connect("color_effect_points", $Line, "_on_change_point_color")
	
func _get_all_nodes_from_group(group) -> Array:
	"""
	função para retornar um 
	array com objetos que estão
	em um determinado grupo
	"""
	var obj_in_group:Array = []
	for child in get_children():
		if child.is_in_group(group):
			obj_in_group.append(child)
	return obj_in_group
