/obj/structure/reagent_dispensers/coolanttank
	name = "coolant tank"
	desc = "A tank of industrial coolant"
	icon = 'icons/obj/objects.dmi'
	icon_state = "coolanttank"
	amount_per_transfer_from_this = 10

/obj/structure/reagent_dispensers/coolanttank/Initialize(mapload)
	. = ..()
	reagents.add_reagent("coolant", 1000)

/obj/structure/reagent_dispensers/coolanttank/on_bullet_act(obj/projectile/proj, impact_flags, list/bullet_act_args)
	. = ..()
	if(proj.get_structure_damage())
		if(!istype(proj ,/obj/projectile/beam/lasertag) && !istype(proj ,/obj/projectile/beam/practice) ) // TODO: make this not terrible
			explode()

/obj/structure/reagent_dispensers/coolanttank/legacy_ex_act()
	explode()

/obj/structure/reagent_dispensers/coolanttank/proc/explode()
	var/datum/effect_system/smoke_spread/S = new /datum/effect_system/smoke_spread
	S.set_up(5, 0, src.loc)

	playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
	spawn(0)
		S.start()

	var/datum/gas_mixture/env = src.loc.return_air()
	if(env)
		if (reagents.total_volume > 750)
			env.temperature = 0
		else if (reagents.total_volume > 500)
			env.temperature -= 100
		else
			env.temperature -= 50

	// NOW.
	qdel(src)
