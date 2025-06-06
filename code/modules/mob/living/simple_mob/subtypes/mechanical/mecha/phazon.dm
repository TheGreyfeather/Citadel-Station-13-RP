// Phazons are weird.

/datum/category_item/catalogue/technology/phazon
	name = "Exosuit - Phazon"
	desc = "The Phazon exosuit is the result of a heavily classified Nanotrasen research initiative. \
	Designed to serve as a reconnaissance, infiltration, and flanking mecha, the Phazon possesses an \
	array of complex and expensive phasing and cloaking systems which allow it to change its matter state \
	and move through solid materials. Although initial field tests were positive, the raw cost of manufacturing \
	the Phazon made mass production untenable. Of the few suits deployed during the Phoron War, none are known to \
	have fallen into enemy hands. In spite of this, corporate espionage has lead to various parts and components \
	becoming available on the black market. The actual circuitry and chips necessary to construct the Phazon, however, \
	remain closely guarded corporate secrets. The exosuit's hover capabilities cause it to float roughly a foot off of \
	the ground. Due to this, although the Phazon itself comes in at a moderate 9'(2.7m) in height, it effectively takes \
	up 10' to 11'(3m-3.4m) of space when in operation."
	value = CATALOGUER_REWARD_HARD

/mob/living/simple_mob/mechanical/mecha/combat/phazon
	name = "phazon"
	desc = "An extremly enigmatic exosuit."
	icon_state = "phazon"
	movement_base_speed = 10 / 5
	wreckage = /obj/structure/loot_pile/mecha/phazon
	catalogue_data = list(/datum/category_item/catalogue/technology/phazon)

	maxHealth = 200
	deflect_chance = 30
	armor_legacy_mob = list(
				"melee"		= 30,
				"bullet"	= 30,
				"laser"		= 30,
				"energy"	= 30,
				"bomb"		= 30,
				"bio"		= 100,
				"rad"		= 100
				)
	projectiletype = /obj/projectile/energy/declone

