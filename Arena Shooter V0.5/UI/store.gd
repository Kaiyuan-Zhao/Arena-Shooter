extends Control

onready var coins = $Coins
onready var tabContainer = $TabContainer
onready var levelChart = []
onready var selectedChart = []
onready var player
var _UNSAVABLE_PROPERTIES = ["coins", "tabContainer", "player"]
var ability_icon = null
var unpauseOnClose = true
enum tabs{
	abilities = 0,
	stats = 1,
	weapon = 2,
}

func _ready():
	for i in tabContainer.get_child_count():
		levelChart.append([])
		selectedChart.append(-1)

func _process(_delta): # optimize: emit signal for when to check
	if Input.is_action_just_pressed("enter"):
		if visible:
			visible = false
		else:
			if get_tree().paused:
				unpauseOnClose = false
			visible = true
			
		if unpauseOnClose:
			get_tree().paused = visible
		else:
			unpauseOnClose = false
			
	coins.text = str("Coins: ",PlayerStats.coins)
	for i in tabContainer.get_child_count():
		levelChart[i] = tabContainer.get_children()[i].level
		selectedChart[i] = tabContainer.get_children()[i].selected
	
	PlayerStats.max_health = (PlayerStats.base_max_health + levelChart[tabs.stats][0]*15)
	PlayerStats.MAX_SPEED = (PlayerStats.base_max_health + levelChart[tabs.stats][1]*10)
	
	if tabContainer.get_child(tabs.abilities).selected != -1:
		PlayerStats.ability_sprite = tabContainer.get_child(tabs.abilities).selectedPanel.icon.texture
		
	tabContainer.get_child(tabs.weapon).update_weapon_display(player.weapon, player.glowLayer.itemUI.itemTextureRect.texture)
	
	
	PlayerStats.ability = selectedChart[tabs.abilities]
	PlayerStats.abilityLevel = levelChart[tabs.abilities][selectedChart[tabs.abilities]]
	
func get_save_data() -> Dictionary:
	var d := {}
	for property in get_property_list():
		if property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE:
			if not property.name in _UNSAVABLE_PROPERTIES:
				if property.type != TYPE_OBJECT:
					# ConfigFile can handle any built-in data type
					d[property.name] = get(property.name)
				else:
					# implement get_save_data() in non-node objects.
					d["Object_" + property.name] = get(property.name).get_save_data()
	return d

func load_save_data(d: Dictionary): 
	for property_name in d:
		if property_name.count("Object_") > 0:
			get(property_name).load_save_data(d[property_name])
		else:
			set(property_name, d[property_name])
	tabContainer.get_child(tabs.weapon).update_weapon_display(player.weapon, player.glowLayer.itemUI.itemTextureRect.texture)
