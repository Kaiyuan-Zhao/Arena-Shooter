extends Control

onready var coins = $Coins
onready var tabContainer = $TabContainer
onready var levelChart = []
onready var selectedChart = []
onready var player

var ability_icon = null
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
