extends upgrade_button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    base_cost = 30 #adjust per button
    exponential = 3 #adjust per button
    super._ready()
    
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    super._process(delta)
    text = "Finger Friction Power
$ "+str(cost)+"
Lvl "+str(Globals.spin_friction)

func _on_button_up() -> void:
    if(Globals.money >= cost):
        upgrade_level += 1
        Globals.spin_friction += 1
        #pays the cost and calculates it for us, do after upgrade_level++
        super._on_button_up() 
        
