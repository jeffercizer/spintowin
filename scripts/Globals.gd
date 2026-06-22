extends Node


#misc
var total_spins = 0
var total_earnings = 0 
var debug_mode = false
var viewing_spinner = 1
var max_viewable_spinner = 1
var spinner_unlocks = [true, false, false, false]
var spinner_buy_costs = [0, 25000, 6000000, 1000000000]


#spinner helpers
var want_fishing_minigame = false


#upgrades and info
var money: float = 10.0
var luck = 1
var spin_percision = 1
var spin_friction = 1


var mouse_fudging
var mouse_dragging


func get_money():
    return money
    
func update_money(value):
    money += value
