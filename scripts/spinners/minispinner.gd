extends SpinnerBase

class_name MiniSpinner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    base_experience_to_level_up = 20
    experience_to_level_up = base_experience_to_level_up * (level * level)
    machine_curve = {
        "luck_cap": 20,
        "thresholds": [
            { "luck": 1,  "Win": 5.0, "Lose": 15.0, "Jackpot": 0.0},
            { "luck": 12,  "Win": 5.0, "Lose": 15.0, "Jackpot": 0.0},
            { "luck": 16, "Win": 30.0, "Lose": 7.0, "Jackpot": 20.0},
            { "luck": 20, "Win": 16.0, "Lose": 0.0,  "Jackpot": 84.0}
        ]
    }
    #goodness can be used to have certain slices grow faster than their base weight would encourage
    #my idea is so we can make jackpots super super rare but become very doable
    add_slice("Win", winMaterial, 1.0, Callable(self, "default_win")) 
    add_slice("Lose", loseMaterial, 1.0, Callable(self, "default_lose"))
    add_slice("Win", winMaterial, 1.0, Callable(self, "default_win")) 
    add_slice("Win", winMaterial, 1.0, Callable(self, "default_win")) 
    add_slice("Lose", loseMaterial, 1.0, Callable(self, "default_lose"))
    add_slice("Win", winMaterial, 1.0, Callable(self, "default_win")) 
    add_slice("Lose", loseMaterial, 1.0, Callable(self, "default_lose"))
    add_slice("Jackpot", jackpotMaterial, 1.0, Callable(self, "default_jackpot")) 
    add_slice("Lose", loseMaterial, 1.0, Callable(self, "default_lose"))        
    super._ready()
    
    
#denominators are 1 2 3 4 5 6 10 12 15 20 30 60 for total weights to fit buckets
@export var winMaterial: ShaderMaterial
@export var loseMaterial: ShaderMaterial
@export var jackpotMaterial: ShaderMaterial

@export var winLabel: Label3D
@export var loseLabel: Label3D
@export var jackpotLabel: Label3D

@export var level_label: Label3D

@export var loseSound: AudioStream
@export var winSound: AudioStream
@export var jackpotSound: AudioStream

@export var wheelwheel: WheelSpinner


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    super._process(delta)
    
func _physics_process(_delta: float) -> void:
    super._physics_process(_delta)

func start_spin(spin_num_mod):
    super.start_spin(spin_num_mod)
    
func _on_spin_requested() -> void:
    if(want_spin):
        return #we are already spinning
    emit_signal("spin_started")
    start_spin((randi()%8)-4)
    
#wheel specific callbacks
func default_win():
    wheelwheel.wheel_finished(5000000000000,0) #5T
    wheelSound.stream = winSound
    wheelSound.play()

func default_lose():
    wheelwheel.wheel_finished(-5000000000000,0) #-5T
    wheelSound.stream = loseSound
    wheelSound.play()
    pass
    
func default_jackpot():
    wheelwheel.wheel_finished(50000000000000,0) #50T
    #coin_animator.play("coinfountain-lvl1")
    wheelSound.stream = jackpotSound
    wheelSound.play()
    
func _on_luck_button_button_up() -> void:
    want_to_rebuild = true
