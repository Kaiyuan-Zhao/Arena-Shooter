extends TileMap

onready var spike = preload("res://World/Spike.tscn")
onready var spikes = get_node("../Spikes")
func _ready():
	var spikesArray = get_used_cells_by_id(0)
	add_objects(spikesArray)
	
func add_objects(array):
	var pos
	for i in range(0, array.size()):
		pos = map_to_world(array[i])
		var s = spike.instance()
		s.set_position(pos)
		spikes.add_child(s)
		
