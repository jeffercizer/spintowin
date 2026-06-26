extends upgrade_button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    base_cost = 1000.0 #adjust per button
    exponential = 4 #adjust per button
    super._ready()

    
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    super._process(delta)
    text = "Max Combo 
(Current Max:"+str(Globals.max_combo)+")
$ "+str(Globals.format_number(cost))+"
Lvl "+str(upgrade_level)

func _on_button_up() -> void:
    if(Globals.money >= cost):
        upgrade_level += 1
        Globals.max_combo *= 2
        #pays the cost and calculates it for us, do after upgrade_level++
        super._on_button_up() 
        
