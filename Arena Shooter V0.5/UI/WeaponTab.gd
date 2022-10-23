extends "res://UI/shopTab.gd"

onready var weapon = null

func update_weapon_display(value, texture):
	weapon = value
	if weapon != null:
		panelArray[0].level = weapon.level
		set_visibility(panelArray[0], texture, true)
		
		if weapon.ranged:
			panelArray[1].level = weapon.projectileCount - 1
			panelArray[1].maxLevel = weapon.maxProjectileCount - 1
			set_visibility(panelArray[1],null, true)
			
			if weapon.maxPiercing:
				panelArray[2].maxLevel = 1
			else:
				panelArray[2].maxLevel = 0
				
			if weapon.piercing:
				panelArray[2].level = 1
			else:
				panelArray[2].level = 0
				
			set_visibility(panelArray[2], null, true)
			
		else:
			set_visibility(panelArray[1], null, false)
			set_visibility(panelArray[2], null, false)
			
		
	else:
		for i in panelArray:
			i.visible = false
			
func set_visibility(panel, texture, value):
	panel.visible = value
	if texture != null:
		panel.icon.texture = texture

func upgrade(price, item_no):
	if PlayerStats.coins >= price:
		PlayerStats.coins -= price
		if item_no == 0:
			weapon.level += 1
		elif item_no == 1:
			weapon.projectileCount += 1
		elif item_no == 2:
			weapon.piercing = true

