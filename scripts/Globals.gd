extends Node


#misc
var total_spins = 0
var debug_mode = false

#upgrades and info
var money = 10
var luck = 1
var spin_percision = 1
var spin_friction = 1


var mouse_fudging
var mouse_dragging


func get_money():
    return money
    
func update_money(value):
    money += value
