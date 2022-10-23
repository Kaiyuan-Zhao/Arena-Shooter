extends Panel

export(int) var basePrice = 1
export(int) var maxLevel = 1
export(int) var levelUpIncrease = 1
export(bool) var selectable = true
export(int) var baseLevel = 0
export(float) var exponential = 1.0
export(float) var upgradeTimeCap = 0.1

onready var level = baseLevel setget changeLevel
onready var price = basePrice setget changePrice
onready var priceLabel = $Price
onready var levelLabel = $Level
onready var purchaseButton = $Button
onready var icon = $TextureRect2
onready var timer = $Timer

var buttonDown = false
var _UNSAVABLE_PROPERTIES = ["priceLabel", "levelLabel", "purchaseButton", "icon", "timer"]
var upgradeBaseWaitTime = 0.3
var upgradeTimes = 0

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
	if level != 0:
		self.level = level
	self.price = price

func _process(_delta):
	if timer.is_stopped() and buttonDown:
		#print(upgradeBaseWaitTime*(1.0-min(0.075*upgradeTimes, (1-upgradeTimeCap))))
		timer.start(upgradeBaseWaitTime*(1.0-min(0.075*upgradeTimes, (1-upgradeTimeCap))))
		
func changeLevel(value):
	if value == null:
		level = 0
	else:
		level = value
	if level > 0:
		self.price = ceil(levelUpIncrease * (level) * pow(exponential, level))
	else:
		self.price = basePrice
		
	if level < maxLevel:
		levelLabel.text = str("LVL: ", value)
	else:
		levelLabel.text = str("LVL: MAX")
		priceLabel.text = str("Can't Be Upgraded")
		
func changePrice(value):
	price = value
	if price == 0:
		priceLabel.text = "FREE"
	else:
		priceLabel.text = str("Price: ", price)

func _on_Button_pressed():
	emit_signal("purchase", price, int(name.replace("Panel", ""))-1)

func upgrade():
	if level < maxLevel:
		emit_signal("upgrade", price, int(name.replace("Panel", ""))-1)
		upgradeTimes+=1


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
	d["level"] = level
	d["price"] = price
	return d

func load_save_data(d: Dictionary): 
	for property_name in d:
		if property_name.count("Object_") > 0:
			get(property_name).load_save_data(d[property_name])
		else:
			set(property_name, d[property_name])

func _on_Upgrade_button_up():
	timer.stop()
	upgradeTimes = 0
	buttonDown = false


func _on_Timer_timeout():
	upgrade()


func _on_Upgrade_button_down():
	_on_Timer_timeout()
	buttonDown = true
