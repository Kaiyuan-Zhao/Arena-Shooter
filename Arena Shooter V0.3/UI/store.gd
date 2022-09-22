extends Control

onready var coins = $Coins
onready var tabContainer = $TabContainer
onready var levelChart = []
onready var selectedChart = []

enum tabs{
	abilities = 0,
	stats = 1
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
	
	PlayerStats.max_health = (PlayerStats.base_max_health + levelChart[1][0]*15)
	PlayerStats.MAX_SPEED = (PlayerStats.base_max_health + levelChart[1][1]*10)
	
	
