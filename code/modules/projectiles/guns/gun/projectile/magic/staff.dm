/obj/item/gun/projectile/magic/staff
	slot_flags = SLOT_BACK
	accuracy = 95

/* //These two need to be fixed at the projectile level.
/obj/item/gun/projectile/magic/staff/change
	name = "staff of change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/change
	icon_state = "staffofchange"
	item_state = "staffofchange"

/obj/item/gun/projectile/magic/staff/animate
	name = "staff of animation"
	desc = "An artefact that spits bolts of life-force which causes objects which are hit by it to animate and come to life! This magic doesn't affect machines."
	fire_sound = 'sound/magic/staff_animation.ogg'
	ammo_type = /obj/item/ammo_casing/magic/animate
	icon_state = "staffofanimation"
	item_state = "staffofanimation"
*/
/obj/item/gun/projectile/magic/staff/healing
	name = "staff of healing"
	desc = "An artefact that spits bolts of restoring magic which can remove ailments of all kinds and even raise the dead."
	fire_sound = 'sound/magic/staff_healing.ogg'
	projectile_type = /obj/projectile/magic/resurrection
	icon_state = "staffofhealing"
	item_state = "staffofhealing"

/*
/obj/item/gun/projectile/magic/staff/chaos
	name = "staff of chaos"
	desc = "An artefact that spits bolts of chaotic magic that can potentially do anything."
	fire_sound = 'sound/magic/staff_chaos.ogg'
	ammo_type = /obj/item/ammo_casing/magic/chaos
	icon_state = "staffofchaos"
	item_state = "staffofchaos"
	max_charges = 10
	recharge_rate = 2
	no_den_usage = 1
	var/allowed_projectile_types = list(/obj/projectile/magic/resurrection, /obj/projectile/magic/death, /obj/projectile/magic/teleport,
		/obj/projectile/magic/door, /obj/projectile/magic/aoe/fireball,	/obj/projectile/magic/spellblade, /obj/projectile/magic/arcane_barrage,
		/obj/projectile/magic/locker)	//These two are commented out until they work in RP code: /obj/projectile/magic/change, /obj/projectile/magic/animate,

/obj/item/gun/projectile/magic/staff/chaos/proc/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0, stam_cost = 0)
	projectile_type = pick(allowed_projectile_types)
	. = ..()
*/

/obj/item/gun/projectile/magic/staff/door
	name = "staff of door creation"
	desc = "An artefact that spits bolts of transformative magic that can create doors in walls."
	fire_sound = 'sound/magic/staff_door.ogg'
	projectile_type = /obj/projectile/magic/door
	icon_state = "staffofdoor"
	item_state = "staffofdoor"
	max_charges = 10
	recharge_rate = 2
	no_den_usage = 1

/obj/item/gun/projectile/magic/staff/honk
	name = "staff of the honkmother"
	desc = "Honk."
	fire_sound = 'sound/items/airhorn.ogg'
	projectile_type = /obj/projectile/bullet/honker/lethal/heavy
	icon_state = "honker"
	item_state = "honker"
	max_charges = 4
	recharge_rate = 8

//Commenting the Spellblade out until it can also be fixed. Might need to be moved to Melee?
/*
/obj/item/gun/projectile/magic/staff/spellblade
	name = "spellblade"
	desc = "A deadly combination of laziness and boodlust, this blade allows the user to dismember their enemies without all the hard work of actually swinging the sword."
	fire_sound = 'sound/magic/fireball.ogg'
	ammo_type = /obj/item/ammo_casing/magic/spellblade
	icon_state = "spellblade"
	item_state = "spellblade"
	attack_sound = 'sound/weapons/rapierhit.ogg'
	damage_force = 20
	armour_penetration = 75
	block_chance = 50
	sharpness = SHARP_EDGED
	max_charges = 4

/obj/item/gun/projectile/magic/staff/spellblade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 15, 125, 0, attack_sound)

/obj/item/gun/projectile/magic/staff/spellblade/run_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	// Do not block projectiles.
	if(attack_type & ATTACK_TYPE_PROJECTILE)
		return BLOCK_NONE
	return ..()
*/

// /obj/item/gun/projectile/magic/staff/locker
// 	name = "staff of the locker"
// 	desc = "An artefact that expells encapsulating bolts, for incapacitating thy enemy."
// 	fire_sound = 'sound/magic/staff_change.ogg'
// 	ammo_type = /obj/item/ammo_casing/magic/locker
// 	icon_state = "locker"
// 	item_state = "locker"
// 	max_charges = 6
// 	recharge_rate = 4
