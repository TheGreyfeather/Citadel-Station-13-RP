// Phase weapons go here

/obj/item/gun/projectile/energy/phasegun
	name = "phase carbine"
	desc = "The NT EW26 Artemis is a downsized energy weapon, specifically designed for use against wildlife."
	icon_state = "phasecarbine"
	item_state = "phasecarbine"
	wielded_item_state = "phasecarbine-wielded"
	slot_flags = SLOT_BACK|SLOT_BELT
	charge_cost = 240
	projectile_type = /obj/projectile/energy/phase
	one_handed_penalty = 15
	no_pin_required = 1

/obj/item/gun/projectile/energy/phasegun/pistol
	name = "phase pistol"
	desc = "The NT  EW15 Apollo is an energy handgun, specifically designed for self-defense against aggressive wildlife."
	icon_state = "phase"
	item_state = "taser"	//I don't have an in-hand sprite, taser will be fine
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	charge_cost = 300
	projectile_type = /obj/projectile/energy/phase/light
	one_handed_penalty = 0

/obj/item/gun/projectile/energy/phasegun/pistol/mounted
	name = "mounted phase pistol"
	self_recharge = 1
	use_external_power = 1

/obj/item/gun/projectile/energy/phasegun/pistol/mounted/cyborg
	charge_cost = 400
	recharge_time = 7

/obj/item/gun/projectile/energy/phasegun/rifle
	name = "phase rifle"
	desc = "The NT EW31 Orion is a specialist energy weapon, intended for use against hostile wildlife."
	icon_state = "phaserifle"
	item_state = "phaserifle"
	wielded_item_state = "phaserifle-wielded"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	charge_cost = 150
	projectile_type = /obj/projectile/energy/phase/heavy
	one_handed_penalty = 30

/obj/item/gun/projectile/energy/phasegun/cannon
	name = "phase cannon"
	desc = "The NT EW50 Gaia is a massive energy weapon, purpose-built for clearing land. You feel dirty just looking at it."
	icon_state = "phasecannon"
	item_state = "phasecannon"
	wielded_item_state = "phasecannon-wielded"	//TODO: New Sprites
	w_class = WEIGHT_CLASS_HUGE		// This thing is big.
	slot_flags = SLOT_BACK
	heavy = TRUE
	charge_cost = 100
	projectile_type = /obj/projectile/energy/phase/heavy/cannon
	accuracy = 70
	one_handed_penalty = 65
