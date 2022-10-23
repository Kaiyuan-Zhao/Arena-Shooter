extends YSort

func get_save_data() -> Dictionary:
	var items = get_children()
	var d := {}
	d["Object_children"] = []
	for	i in items:
		d["Object_children"].append(i.get_save_data())
	return d
	
func load_save_data(d: Dictionary):
	for i in get_children():
		i.queue_free()
	for property_name in d:
		if property_name == "Object_children":
			for child in d[property_name]:
				var i = load(child["path"])
				var item = i.instance()
				add_child(item)
				item.load_save_data(child)
		else:
			set(property_name, d[property_name])
