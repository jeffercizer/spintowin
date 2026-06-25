extends Node


#misc
var total_spins = 0
var total_earnings = 0 
var debug_mode = false
var viewing_spinner = 1
var max_viewable_spinner = 1
var spinner_unlocks = [true, false, false, false]
var spinner_buy_costs = [0.0, 25000.0, 6000000.0, 1000000000.0]
    

#spinner helpers
var want_fishing_minigame = false


#upgrades and info
var money: float = 10.0
var luck = 1
var spin_friction = 1

#15 -> each level makes it 60% larger, 1 -> 1.6 -> 2.4 etc
var level_effect = 1.6


var mouse_fudging
var mouse_dragging


func get_money():
    return money
    
func update_money(value):
    money += value
    total_earnings += value
    
    
func format_number(n: float) -> String:
    var abs_n = abs(n)
    var suffixes = {
        1e3: "K",
        1e6: "M",
        1e9: "B",
        1e12: "T",
        1e15: "qT",
        1e18: "Q",
        1e21: "s",
        1e24: "o",
        1e27: "n",
        1e30: "d",
    }
    
    var chosen_suffix = ""
    var chosen_value = 1.0

    for value in suffixes.keys():
        if abs_n >= value:
            chosen_value = value
            chosen_suffix = suffixes[value]

    if chosen_suffix == "":
        return str(n)

    var short = n / chosen_value
    if(n > 0):
        return "%.2f%s" % [short, chosen_suffix]
    else:
        return "-%.2f%s" % [short, chosen_suffix]
