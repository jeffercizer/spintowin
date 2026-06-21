extends StaticBody3D

class_name SpinnerBuyButton
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if(able_to_buy == false and Globals.money >= Globals.spinner_buy_costs[spinner_id-1]/2.0):
        able_to_buy = true
        buy_button_ui.visible = true
        if(Globals.max_viewable_spinner < spinner_id):
            Globals.max_viewable_spinner = spinner_id

var able_to_buy = false
@export var spinner_id : int
@export var buy_button_ui : MeshInstance3D
@export var spinner_lighting : Node3D

func attempt_buy():
    if(Globals.money >= Globals.spinner_buy_costs[spinner_id-1]):
        Globals.money -= Globals.spinner_buy_costs[spinner_id-1]
        Globals.spinner_unlocks[spinner_id-1] = true
        spinner_lighting.visible = true
        buy_button_ui.visible = false
        collision_layer = 0
        collision_mask = 0

        
