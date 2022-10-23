extends Tabs

# -------- panels node

export(int) var selected = 0 setget select
onready var panels = $RichTextLabel/control
onready var scrollBar = $HScrollBar
var _UNSAVABLE_PROPERTIES = ["panels", "scrollBar", "selectedPanel"]
var bought = []
var level = [] setget set_level
var panelArray = []
var selectedPanel
var ready = false

func _ready():
	panelArray = panels.get_children()
	if selected != -1:
		select(selected)
	for i in panelArray:
		level.append(i.level)
		
		if i.selectable and i.baseLevel <= 0:
			bought.append(false)
		else:
			bought.append(true)
			
		i.connect("purchase", self, "buy")
		i.connect("upgrade", self, "upgrade")
	if selected != -1:
		selectedPanel = panelArray[selected]
		bought[selected] = true 
		level[selected] = 1
		select(selected)
	ready = true
# ------ Scroll bar

func _process(_delta):
	if selected != -1:
		selectedPanel = panelArray[selected]
	panels.position.x = -scrollBar.value
	
func set_level(value):
	level = value
	for i in range(panels.get_child_count()):
		panelArray[i].level = level[i]

# ---------- select items
func select(no):
	if no != -1:
		for i in range(bought.size()):
			if bought[i]:
				panelArray[i].purchaseButton.text = "select"
			else:
				panelArray[i].purchaseButton.text = "buy"
		panelArray[no].purchaseButton.text = "selected"
	selected = no

func buy(price, item_no):
	# --------- Check if already bought
	if bought[item_no] == false:
		if PlayerStats.coins >= price: # Check if there is enough money to buy the item
			PlayerStats.coins -= price
			bought[item_no] = true
			level[item_no] = 1
			panelArray[item_no].level = level[item_no]
			panelArray[item_no].purchaseButton.text = 'Select'
	else: # ---Select the item if clicked and is already bought 
		select(item_no)
		
func upgrade(price, item_no):
	# --------- Check if already bought
	if bought[item_no] == true:
		if PlayerStats.coins >= price:
			PlayerStats.coins -= price
			level[item_no]+=1
			panelArray[item_no].level = level[item_no]
			
func get_save_data() -> Dictionary:
	var d := {}
	d["bought"] = bought.duplicate()
	d["level"] = level.duplicate()
	d["selected"] = selected
	return d

func load_save_data(d: Dictionary): 
	bought = d["bought"].duplicate()
	level = d["level"].duplicate()
	self.selected = d["selected"]
	panelArray = panels.get_children()
	for	i in range(panelArray.size()):
		panelArray[i].level = level[i];

