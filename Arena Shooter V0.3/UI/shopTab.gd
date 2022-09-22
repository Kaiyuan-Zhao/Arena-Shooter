extends Tabs

# -------- panels node
onready var panels = $RichTextLabel/control
onready var scrollBar = $HScrollBar
var bought = []
var level = []
var panelArray = []
export var selected = 0

func _ready():
	panelArray = panels.get_children()
	if selected != -1:
		select(selected)
	for i in panelArray:
		
		var l = i.level
		level.append(i.level)
		
		if i.selectable:
			bought.append(false)
		else:
			bought.append(true)
			
		i.connect("purchase", self, "buy")
		i.connect("upgrade", self, "upgrade")
	if selected != -1:
		bought[selected] = true 
		level[selected] = 1
	
# ------ Scroll bar

func _process(_delta):
	panels.position.x = -scrollBar.value
	

# ---------- select items
func select(no):
	for i in range(bought.size()):
		if bought[i]:
			panelArray[i].purchaseButton.text = "select"
	panelArray[no].purchaseButton.text = "selected"
	
func buy(price, item_no):
	# --------- Check if already bought
	if bought[item_no] == false:
		if PlayerStats.coins >= price: # Check if there is enough money to buy the item
			PlayerStats.coins -= price
			bought[item_no] = true
			selected = item_no
			level[item_no] = 1
			panels.get_node('Panel'+str(item_no+1)).level = level[item_no]
			panels.get_node('Panel'+str(item_no+1)).purchaseButton.text = 'Select'
	else: # ---Select the item if clicked and is already bought 
		select(item_no)
		
func upgrade(price, item_no):
	# --------- Check if already bought
	if bought[item_no] == true:
		if PlayerStats.coins >= price:
			PlayerStats.coins -= price
			level[item_no]+=1
			panels.get_node('Panel'+str(item_no+1)).level = level[item_no]

