extends upgrade_button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    base_cost = 100.0 #adjust per button
    exponential = 4 #adjust per button
    super._ready()

    
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    super._process(delta)
    text = "Spin Power Percision
$ "+str(Globals.format_number(cost))+"
Lvl "+str(Globals.spin_percision)

func _on_button_up() -> void:
    if(Globals.money >= cost):
        upgrade_level += 1
        Globals.spin_percision += 1
        #pays the cost and calculates it for us, do after upgrade_level++
        super._on_button_up() 
        
