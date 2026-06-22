extends upgrade_button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    super._ready()
    base_cost = 15.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    text = "Cheat
$ "+str(Globals.format_number(cost))+"
Lvl -1"
var cheat_money = 10000.0
func _on_button_up() -> void:
    Globals.update_money(cheat_money)
    cheat_money *= 10.0
        
