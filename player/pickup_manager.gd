extends Area3D

@onready var health_manager = %HealthManager
@onready var weapon_manager = %WeaponManager

func _ready():
	area_entered.connect(on_area_enter)

func on_area_enter(pickup: Area3D):
	var delete_on_pickup = true
	if pickup is Pickup:
		match pickup.pickup_type:
			Pickup.PICKUP_TYPES.HEALTH:
				if health_manager.cur_health < health_manager.max_health:
					health_manager.heal(pickup.pickup_amnt)
				else:
					delete_on_pickup = false
			Pickup.PICKUP_TYPES.WEAPON:
				var weapon : Weapon = weapon_manager.get_weapon_from_pickup_type(pickup.weapon_type)
				weapon_manager.enable_weapon(weapon)
				weapon.add_ammo(pickup.pickup_amnt)
			Pickup.PICKUP_TYPES.AMMO:
				var weapon : Weapon = weapon_manager.get_weapon_from_pickup_type(pickup.weapon_type)
				weapon.add_ammo(pickup.pickup_amnt)
	
	if delete_on_pickup:
		pickup.pickup()
