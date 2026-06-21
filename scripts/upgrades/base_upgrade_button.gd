extends Button

class_name upgrade_button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    cost = base_cost 

@export var base_cost = 15
var cost = 0
var upgrade_level = 1
@export var exponential = 4
@export var max_level = 40
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    disabled = Globals.money < cost or upgrade_level >= max_level

func _on_button_up() -> void:
    if(Globals.money >= cost):
        Globals.update_money(-cost)
        cost = int(base_cost * pow(upgrade_level,exponential))
