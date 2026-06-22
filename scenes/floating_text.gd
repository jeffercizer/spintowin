extends Control



@export var float_distance = 40.0
@export var duration = 0.8
@export var label : Label
func show_value(amount: float) -> void:
    if(amount > 0):
        label.text = "+%.2f" % amount #MONEY FUNC REPALCE
        label.modulate = Color(0, 1, 0, 1)
    elif(amount < 0):
        label.text = "-%.2f" % amount #MONEY FUNC REPALCE
        label.modulate = Color(1, 0, 0, 1)
    else:
        label.text + "+0"
        label.modulate = Color(0.7,0.7,0.7)

    modulate.a = 1.0
    position.y = 0

    var tween = create_tween()
    tween.tween_property(self, "position:y", -float_distance, duration).set_trans(Tween.TRANS_SINE)
    tween.parallel().tween_property(self, "modulate:a", 0.0, duration)

    tween.finished.connect(queue_free)
