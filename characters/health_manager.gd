extends Node3D

const BLOOD_HIT_EFFECT = preload("res://effects/blood_effects/blood_hit_effect.tscn")
const BLOOD_DECAL = preload("res://effects/blood_effects/blood_decal.tscn")

@onready var blood_raycast = $BloodRaycast

@export var max_health = 100
@onready var cur_health = max_health
@export var gib_at = -10

@export var blood_splatter_count = 3
@export var blood_splatter_range = 2.0
@export var blood_splatter_size_variance = 0.5

@export var verbose = true



signal died
signal healed
signal damaged
signal gibbed
signal health_changed(cur_health, max_health)

func _ready():
	health_changed.emit(cur_health, max_health)
	if verbose:
		print("starting health: %s/%s" % [cur_health, max_health])

func hurt(damage_data: DamageData):
	spawn_blood_effects(damage_data)
	
	if cur_health <= 0:
		return
	cur_health -= damage_data.amount
	if cur_health <= gib_at:
		gibbed.emit()
	if cur_health <= 0:
		died.emit()
	else:
		damaged.emit()
	health_changed.emit(cur_health, max_health)
	if verbose:
		print("damaged for %s, health: %s/%s" % [damage_data.amount, cur_health, max_health])

func heal(amount: int):
	if cur_health <= 0:
		return
	cur_health = clamp(cur_health + amount, 0, max_health)
	healed.emit()
	health_changed.emit(cur_health, max_health)
	if verbose:
		print("healed for %s, health: %s/%s" % [amount, cur_health, max_health])

func spawn_blood_effects(damage_data: DamageData):
	var blood_hit_effect = BLOOD_HIT_EFFECT.instantiate()
	get_tree().get_root().add_child(blood_hit_effect)
	blood_hit_effect.global_position = damage_data.hit_pos
	
	blood_raycast.enabled = true
	for _i in blood_splatter_count:
		var h_angle = randf_range(0.0, PI / 2.0)
		var v_angle = randf_range(0.0, TAU)
		var dir = Vector3.DOWN.rotated(Vector3.RIGHT, h_angle)
		dir = dir.rotated(Vector3.UP, v_angle)
		var raycast_to = global_position + dir * blood_splatter_range
		blood_raycast.target_position = blood_raycast.to_local(raycast_to)
		blood_raycast.force_raycast_update()
		if !blood_raycast.is_colliding():
			continue
		
		var hit_pos = blood_raycast.get_collision_point()
		var hit_normal = blood_raycast.get_collision_normal()
		var blood_decal = BLOOD_DECAL.instantiate()
		get_tree().get_root().add_child(blood_decal)
		blood_decal.global_position = hit_pos
		var look_at_pos = hit_pos + hit_normal
		if hit_normal.is_equal_approx(Vector3.UP) or hit_normal.is_equal_approx(Vector3.DOWN):
			blood_decal.look_at(look_at_pos, Vector3.RIGHT)
		else:
			blood_decal.look_at(look_at_pos)
		
		blood_decal.rotate_object_local(Vector3.FORWARD, randf_range(0.0, TAU))
		blood_decal.scale *= 1.0 + randf_range(-blood_splatter_size_variance, blood_splatter_size_variance)
		
	blood_raycast.enabled = false
