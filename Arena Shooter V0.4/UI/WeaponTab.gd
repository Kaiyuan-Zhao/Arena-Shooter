extends "res://UI/shopTab.gd"

onready var weapon = null

func update_weapon_display(value, texture):
	weapon = value
	if weapon != null:
		for i in panelArray:
			i.level = weapon.level
			i.visible = true
			i.icon.texture = texture
	else:
		for i in panelArray:
			i.visible = false

func upgrade(price, item_no):
	if PlayerStats.coins >= price:
		PlayerStats.coins -= price
		weapon.level += 1
		print(weapon.level)
