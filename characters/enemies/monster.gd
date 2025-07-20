class_name Monster extends CharacterBody3D

@onready var health_manager = $HealthManager
@export var animation_player : AnimationPlayer
@onready var vision_manager = $VisionManager
@onready var nearby_monsters_alert_area: Area3D = $NearbyMonstersAlertArea

enum STATES {IDLE, ATTACK, DEAD}
var cur_state = STATES.IDLE

func _ready():
	var hitboxes = find_children("*", "HitBox")
	for hitbox in hitboxes:
		hitbox.on_hurt.connect(health_manager.hurt)
	health_manager.died.connect(set_state.bind(STATES.DEAD))
	set_state(STATES.IDLE)

func hurt(damage_data: DamageData):
	health_manager.hurt(damage_data)

func alert():
	if  cur_state == STATES.IDLE:
		set_state(STATES.ATTACK)
		alert_nearby_monsters()

func alert_nearby_monsters():
	for b in nearby_monsters_alert_area.get_overlapping_bodies():
		if b is Monster:
			b.alert()

func set_state(state: STATES):
	if cur_state == STATES.DEAD:
		return
	cur_state = state
	match cur_state:
		STATES.ATTACK:
			print("ATTACK STATE SET")
		STATES.IDLE:
			animation_player.play("idle")
		STATES.DEAD:
			animation_player.play("die")
			collision_layer = 0
			collision_mask = 0

func _process(delta):
	match cur_state:
		STATES.IDLE:
			process_idle_state(delta)
		STATES.ATTACK:
			process_attack_state(delta)

func process_idle_state(delta):
	if vision_manager.can_see_player():
		alert()
	
func process_attack_state(delta):
	pass
