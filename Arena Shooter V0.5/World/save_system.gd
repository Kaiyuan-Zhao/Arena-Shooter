extends Node

var save_path = "res://Save_slots/saved_config.cfg"
var dict_to_save := {}
var immediatelyLoad = false

func save():
	for node in get_tree().get_nodes_in_group("persist"):  
		dict_to_save[node.get_path()] = node.get_save_data()
	var file = File.new()
	file.open(save_path, File.WRITE)
	file.store_line(to_json(dict_to_save))
	file.close()
#	for node in get_tree().get_nodes_in_group("persist"):  
#		dict_to_save[node.get_path()] = node.get_save_data() 
#	file.set_value("Data", "dictionary", dict_to_save)
#	file.save(save_path)
	 

func loadDictionary():
	var file = File.new()
	if file.file_exists(save_path):
		file.open(save_path, File.READ)
		var text = file.get_as_text()
		dict_to_save = parse_json(text)
		file.close()
		for node_path in dict_to_save:
			if get_node(node_path) != null:
				 get_node(node_path).load_save_data(dict_to_save[node_path])
		file.close()
	else:
		return
	
