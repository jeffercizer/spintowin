extends SpinnerBase


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    base_experience_to_level_up = 20000
    experience_to_level_up = base_experience_to_level_up
    fish1Label.text = "= Win " + str(int(100 * pow(1.1, level-1))) + "$"
    fish2Label.text = "= Win " + str(int(500 * pow(1.1, level-1))) + "$"
    fish3Label.text = "= Win " + str(int(5000 * pow(1.1, level-1))) + "$"
    fish4Label.text = "= Win " + str(int(20000 * pow(1.1, level-1))) + "$"
    junk1Label.text = "= Lose " + str(int(500 * pow(0.9, level-1))) + "$"
    junk2Label.text = "= Lose " + str(int(500 * pow(0.9, level-1))) + "$"
    machine_curve = {
        "luck_cap": 20,
        "thresholds": [
            { "luck": 1,
                "fish1": 0.5,  "fish2": 0.5,  "fish3": 0.5,  "fish4": 0.5,
                "junk1": 12.0, "junk2": 12.0, "fishinggame": 0.0 },
            { "luck": 4,
                "fish1": 0.5,  "fish2": 0.5,  "fish3": 0.5,  "fish4": 0.5,
                "junk1": 12.0, "junk2": 12.0, "fishinggame": 0.0 },
            { "luck": 6,
                "fish1": 10.0,  "fish2": 2.5,  "fish3": 1.0,  "fish4": 1.0,
                "junk1": 7.5, "junk2": 7.5, "fishinggame": 0.0 },
            { "luck": 10,
                "fish1": 12.0,  "fish2": 10.0,  "fish3": 5.5,  "fish4": 2.5,
                "junk1": 3.75,  "junk2": 3.75,  "fishinggame": 5.0 },
            { "luck": 20,
                "fish1": 5.0, "fish2": 5.0, "fish3": 12.5, "fish4": 12.5,
                "junk1": 0.0,  "junk2": 0.0,  "fishinggame": 15.0 }
        ]
    }

    #goodness can be used to have certain slices grow faster than their base weight would encourage
    #my idea is so we can make jackpots super super rare but become very doable
    add_slice("fish1", fish1Material, 1.0, Callable(self, "fish1_win")) 
    add_slice("junk1", junk1Material, 1.0, Callable(self, "junk1_lose")) 
    add_slice("fish2", fish2Material, 1.0, Callable(self, "fish2_win"))
    add_slice("junk2", junk2Material, 1.0, Callable(self, "junk2_lose"))
    add_slice("fish3", fish3Material, 1.0, Callable(self, "fish3_win")) 
    add_slice("junk1", junk1Material, 1.0, Callable(self, "junk1_lose")) 
    add_slice("fish4", fish4Material, 1.0, Callable(self, "fish4_win"))
    add_slice("junk2", junk2Material, 1.0, Callable(self, "junk2_lose"))
    add_slice("fishinggame", fishingGameMaterial, 1.0, Callable(self, "fishing_game")) 
    add_slice("fish1", fish1Material, 1.0, Callable(self, "fish1_win")) 
    add_slice("junk1", junk1Material, 1.0, Callable(self, "junk1_lose")) 
    add_slice("fish2", fish2Material, 1.0, Callable(self, "fish2_win"))
    add_slice("junk2", junk2Material, 1.0, Callable(self, "junk2_lose"))
    add_slice("fish3", fish3Material, 1.0, Callable(self, "fish3_win")) 
    add_slice("junk1", junk1Material, 1.0, Callable(self, "junk1_lose")) 
    add_slice("fish4", fish4Material, 1.0, Callable(self, "fish4_win"))
    add_slice("junk2", junk2Material, 1.0, Callable(self, "junk2_lose"))
    add_slice("fishinggame", fishingGameMaterial, 1.0, Callable(self, "fishing_game")) 
    super._ready()
    
    
#denominators are 1 2 3 4 5 6 10 12 15 20 30 60 for total weights to fit buckets
@export var fish1Material: ShaderMaterial
@export var junk1Material: ShaderMaterial
@export var fish2Material: ShaderMaterial
@export var junk2Material: ShaderMaterial
@export var fish3Material: ShaderMaterial
@export var fish4Material: ShaderMaterial
@export var fishingGameMaterial: ShaderMaterial


@export var fish1Label: Label3D
@export var fish2Label: Label3D
@export var fish3Label: Label3D
@export var fish4Label: Label3D
@export var junk1Label: Label3D
@export var junk2Label: Label3D
@export var fishingGameLabel: Label3D

@export var loseSound: AudioStream
@export var winSound: AudioStream
@export var jackpotSound: AudioStream

@export var fishing_minigame: FishingMinigameSpinner


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
    #level_up_bar.material_override.set("shader_parameter/progress", experience)
    if(experience >= experience_to_level_up):
        experience -= experience_to_level_up
        level += 1
        experience_to_level_up = base_experience_to_level_up * (level * level)
        fish1Label.text = "= Win " + str(int(100 * pow(1.1, level-1))) + "$"
        fish2Label.text = "= Win " + str(int(500 * pow(1.1, level-1))) + "$"
        fish3Label.text = "= Win " + str(int(5000 * pow(1.1, level-1))) + "$"
        fish4Label.text = "= Win " + str(int(20000 * pow(1.1, level-1))) + "$"
        junk1Label.text = "= Lose " + str(int(500 * pow(0.9, level-1))) + "$"
        junk2Label.text = "= Lose " + str(int(500 * pow(0.9, level-1))) + "$"

#wheel specific callbacks
func fish1_win():
    var reward = int(100 * pow(1.1, level-1))
    Globals.update_money(reward)
    add_experience(reward)
    wheelSound.stream = winSound
    tickerSound.stop()
    wheelSound.play()
    
func fish2_win():
    var reward = int(500 * pow(1.1, level-1))
    Globals.update_money(reward)
    add_experience(reward)
    wheelSound.stream = winSound
    tickerSound.stop()
    wheelSound.play()
    
func fish3_win():
    var reward = int(5000 * pow(1.1, level-1))
    Globals.update_money(reward)
    add_experience(reward)
    wheelSound.stream = winSound
    tickerSound.stop()
    wheelSound.play()
    
func fish4_win():
    var reward = int(20000 * pow(1.1, level-1))
    Globals.update_money(reward)
    add_experience(reward)
    wheelSound.stream = winSound
    tickerSound.stop()
    wheelSound.play()
    
func junk1_lose():
    var reward = int(-500 * pow(0.9, level-1))
    Globals.update_money(reward)
    wheelSound.stream = loseSound
    tickerSound.stop()
    wheelSound.play()
    pass
    
func junk2_lose():
    var reward = int(-500 * pow(0.9, level-1))
    Globals.update_money(reward)
    wheelSound.stream = loseSound
    tickerSound.stop()
    wheelSound.play()
    pass
    
func fishing_game():
    Globals.want_fishing_minigame = true
    tickerSound.stop()
    wheelSound.stop()
    pass
    
    
func _on_luck_button_button_up() -> void:
    want_to_rebuild = true
