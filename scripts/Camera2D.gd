extends Camera2D

var v2a:PoolVector2Array = []
onready var linha:Node2D = get_node("../Line")

func _physics_process(delta):
	var i:int = 0
	print(get_distance(linha.points))
	
func get_distance(arr): # This function
	var arr_dist = 0
	for i in arr.size() - 1:
		arr_dist += arr[i].distance_to(arr[i + 1])
	return arr_dist
