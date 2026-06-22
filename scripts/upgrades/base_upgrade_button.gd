extends Button

class_name upgrade_button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    cost = base_cost 

@export var base_cost = 15.0
var cost: float = 0.0
var upgrade_level: float = 1.0
@export var exponential = 4
@export var max_level = 40
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    disabled = Globals.money < cost or upgrade_level >= max_level
    if(!visible):
        visible = Globals.get_money() >= cost / 2

func _on_button_up() -> void:
    if(Globals.money >= cost):
        Globals.update_money(-cost)
        cost = base_cost * pow(upgrade_level,upgrade_level)


@export var money_box: Control
@export var floating_text: PackedScene 
        
func add_money(value):
    Globals.update_money(value)
    var text := floating_text.instantiate()
    money_box.add_child(text)

    text.position = Vector2(0, 0)
    text.show_value(value)
