extends Panel

export(int) var basePrice = 1
export(int) var maxLevel = 1

export(bool) var selectable = true

var level = 0 setget changeLevel

onready var price = basePrice setget changePrice
onready var priceLabel = $Price
onready var levelLabel = $Level
onready var purchaseButton = $Button

signal purchase(price, name)
signal upgrade(price, name)


func _ready():
	if not selectable:
		purchaseButton.disabled = true
		purchaseButton.visible = false
	if price == 0:
		priceLabel.text = "FREE"
		self.level = 1
	else:
		priceLabel.text = str("Price: ", price)

func changeLevel(value):
	level = value
	self.price = basePrice * (level+1)
	if level < maxLevel:
		levelLabel.text = str("LVL: ", value)
	else:
		levelLabel.text = str("LVL: MAX")
func changePrice(value):
	price = value
	if price == 0:
		priceLabel.text = "FREE"
	else:
		priceLabel.text = str("Price: ", price)

func _on_Button_pressed():
	emit_signal("purchase", price, int(name.replace("Panel", ""))-1)

func _on_Upgrade_pressed():
	if level < maxLevel:
		emit_signal("upgrade", price, int(name.replace("Panel", ""))-1)
