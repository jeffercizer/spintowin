extends SpinnerBase


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    machine_curve = {
        "luck_cap": 7,
        "thresholds": [
            { "luck": 1,  "Win": 50.0, "Lose": 50.0, "Jackpot": 0.0, "Lose2": 50.0},
            { "luck": 3,  "Win": 65.0, "Lose": 17.5, "Jackpot": 0.0,  "Lose2": 17.5},
            { "luck": 5, "Win": 70.0, "Lose": 10.0, "Jackpot": 10.0,  "Lose2": 10.0},
            { "luck": 7, "Win": 50.0, "Lose": 0.0,  "Jackpot": 50.0,  "Lose2": 0.0}
        ]
    }
    #goodness can be used to have certain slices grow faster than their base weight would encourage
    #my idea is so we can make jackpots super super rare but become very doable
    add_slice("Win", winMaterial, 1.0, Callable(self, "default_win")) 
    add_slice("Lose", loseMaterial, 1.0, Callable(self, "default_lose"))
    add_slice("Lose2", loseMaterial, 1.0, Callable(self, "default_lose"))
    add_slice("Jackpot", jackpotMaterial, 1.0, Callable(self, "default_jackpot")) 
    super._ready()
    
    
#denominators are 1 2 3 4 5 6 10 12 15 20 30 60 for total weights to fit buckets
@export var winMaterial: ShaderMaterial
@export var loseMaterial: ShaderMaterial
@export var jackpotMaterial: ShaderMaterial

@export var winLabel: Label3D
@export var loseLabel: Label3D
@export var jackpotLabel: Label3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    super._process(delta)
    
func _physics_process(_delta: float) -> void:
    pass

func start_spin():
    super.start_spin()
    
func _on_spin_requested() -> void:
    if(want_spin):
        return #we are already spinning
    #if(Globals.get_money() < 5):
        #return
    #Globals.update_money(-5)
    emit_signal("spin_started")
    start_spin()
    
    
func add_experience(amount):
    experience += amount
    if(experience >= experience_to_level_up):
        experience -= experience_to_level_up
        level += 1
        experience_to_level_up = base_experience_to_level_up * (level * level)
        winLabel.text = "= Win " + str(int(5 * pow(1.1, level-1))) + "$"
        jackpotLabel.text = "= Win " + str(int(5000 * pow(1.1, level-1))) + "$"

#wheel specific callbacks
func default_win():
    var reward = int(5 * pow(1.1, level-1))
    Globals.update_money(reward)
    add_experience(reward)

func default_lose():
    var reward = int(-5 * pow(1.1, level-1))
    Globals.update_money(reward)
    add_experience(reward)
    
func default_jackpot():
    var reward = int(5000 * pow(1.1, level-1))
    Globals.update_money(reward)
    add_experience(reward)
    
func _on_luck_button_button_up() -> void:
    want_to_rebuild = true
