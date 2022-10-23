extends "res://Items/rangedItem.gd"

var loaded = false
	
func use(): # UPDATE: SHOULD JUST MAKE PARENT YIELD UNTIL ANIMATION FINISHED, AT WHICH POINT A FUNCTION FOR/AGAINST var CANATTACk is changed, ALLOWING THIS SHIT TO BE MORE CONCISE IDK
	ready = false
	if not loaded:
		animationPlayer.play("Load")
		loaded = true
	else:
		animationPlayer.play("Attack")
		loaded = false
	
func enemyUse():
	ready = false
	if not loaded:
		animationPlayer.play("Load")
		loaded = true
	else:
		animationPlayer.play("Attack")
		loaded = false
	
