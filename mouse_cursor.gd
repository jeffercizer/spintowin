extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

@export var open_hand: CompressedTexture2D
@export var closed_hand: CompressedTexture2D
@export var finger_hand: CompressedTexture2D
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    position = get_viewport().get_mouse_position()
    position.x -= 32
    position.y -= 32
    if(Globals.mouse_dragging):
        texture = closed_hand
    elif(Globals.mouse_fudging):
        texture = finger_hand
    else:
        texture = open_hand
