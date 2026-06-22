extends upgrade_button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    base_cost = 15.0
    exponential = 4
    super._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    super._process(delta)
    text = "Wheel Luck
$ "+str(cost)+"
Lvl "+str(Globals.luck)


func _on_button_up() -> void:
    if(Globals.money >= cost):
        upgrade_level += 1
        Globals.luck += 1
        #pays the cost and calculates it for us, do after upgrade_level++
        super._on_button_up() 
        
