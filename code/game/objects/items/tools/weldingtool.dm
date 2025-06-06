#define WELDER_FUEL_BURN_INTERVAL 13
/*
 * Welding Tool
 */
/obj/item/weldingtool
	name = "\improper welding tool"
	icon = 'icons/obj/tools.dmi'
	icon_state = "welder"
	item_state = "welder"
	slot_flags = SLOT_BELT
	tool_behaviour = TOOL_WELDER

	//Amount of OUCH when it's thrown
	damage_force = 3.0
	throw_force = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL

	worth_intrinsic = 35

	//Cost to make in the autolathe
	materials_base = list(MAT_STEEL = 70, MAT_GLASS = 30)

	//R&D tech level
	origin_tech = list(TECH_ENGINEERING = 1)

	//Welding tool specific stuff
	var/welding = 0 	//Whether or not the welding tool is off(0), on(1) or currently welding(2)
	var/status = 1 		//Whether the welder is secured or unsecured (able to attach rods to it to make a flamethrower)
	var/max_fuel = 20 	//The max amount of fuel the welder can hold

	var/acti_sound = 'sound/items/welderactivate.ogg'
	var/deac_sound = 'sound/items/welderdeactivate.ogg'
	tool_sound = 'sound/items/Welder2.ogg'
	var/change_icons = TRUE
	var/flame_intensity = 2 //how powerful the emitted light is when used.
	var/flame_color = "#FF9933" // What color the welder light emits when its on.  Default is an orange-ish color.
	var/eye_safety_modifier = 0 // Increasing this will make less eye protection needed to stop eye damage.  IE at 1, sunglasses will fully protect.
	var/burned_fuel_for = 0 // Keeps track of how long the welder's been on, used to gradually empty the welder if left one, without RNG.
	var/always_process = FALSE // If true, keeps the welder on the process list even if it's off.  Used for when it needs to regenerate fuel.
	tool_speed = 1
	drop_sound = 'sound/items/drop/weldingtool.ogg'
	pickup_sound = 'sound/items/pickup/weldingtool.ogg'

/obj/item/weldingtool/Initialize(mapload)
	. = ..()
//	var/random_fuel = min(rand(10,20),max_fuel)
	var/datum/reagent_holder/R = new/datum/reagent_holder(max_fuel)
	reagents = R
	R.my_atom = src
	R.add_reagent("fuel", max_fuel)
	update_icon()
	if(always_process)
		START_PROCESSING(SSobj, src)

/obj/item/weldingtool/Destroy()
	if(welding || always_process)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weldingtool/examine(mob/user, dist)
	. = ..()
	if(max_fuel)
		. += "[icon2html(thing = src, target = world)] The [src.name] contains [get_fuel()]/[src.max_fuel] units of fuel!"

/obj/item/weldingtool/legacy_mob_melee_hook(mob/target, mob/user, clickchain_flags, list/params, mult, target_zone, intent)
	if(ishuman(target) && user.a_intent == INTENT_HELP)
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/S = H.organs_by_name[user.zone_sel.selecting]

		if(!S || S.robotic < ORGAN_ROBOT || S.open == 3)
			to_chat(user, SPAN_WARNING("That isn't a robotic limb."))
			return NONE

		if(!welding)
			to_chat(user, "<span class='warning'>You'll need to turn [src] on to patch the damage on [H]'s [S.name]!</span>")
			return NONE

		if(S.robo_repair(15, DAMAGE_TYPE_BRUTE, "some dents", src, user))
			remove_fuel(1, user)
		return NONE
	if(is_holosphere_shell(target) && user.a_intent == INTENT_HELP)
		if(!welding)
			to_chat(user, "<span class='warning'>You'll need to turn [src] on to patch the damage on [target]!</span>")
			return NONE
		var/mob/living/simple_mob/holosphere_shell/shell = target
		shell.shell_repair(10, DAMAGE_TYPE_BRUTE, "some dents", src, user)
		remove_fuel(1, user)
		return NONE

	return ..()

/obj/item/weldingtool/attackby(obj/item/W as obj, mob/living/user as mob)
	if(istype(W,/obj/item/tool/screwdriver))
		if(welding)
			to_chat(user, "<span class='danger'>Stop welding first!</span>")
			return
		status = !status
		if(status)
			to_chat(user, "<span class='notice'>You secure the welder.</span>")
		else
			to_chat(user, "<span class='notice'>The welder can now be attached and modified.</span>")
		add_fingerprint(user)
		return

	if((!status) && (istype(W,/obj/item/stack/rods)))
		var/obj/item/stack/rods/R = W
		R.use(1)
		var/obj/item/flamethrower/F = new /obj/item/flamethrower(user.drop_location())
		forceMove(F)
		F.weldtool = src
		master = F
		reset_plane_and_layer()
		add_fingerprint(user)
		return
	..()

/obj/item/weldingtool/process(delta_time)
	if(welding)
		++burned_fuel_for
		if(burned_fuel_for >= WELDER_FUEL_BURN_INTERVAL)
			remove_fuel(1)
		if(get_fuel() < 1)
			setWelding(0)
		else			//Only start fires when its on and has enough fuel to actually keep working
			var/turf/location = src.loc
			if(istype(location, /mob/living))
				var/mob/living/M = location
				if(M.is_holding(src))
					location = get_turf(M)
			if (istype(location, /turf))
				location.hotspot_expose(700, 5)

/obj/item/weldingtool/afterattack(atom/target, mob/user, clickchain_flags, list/params)
	if(!(clickchain_flags & CLICKCHAIN_HAS_PROXIMITY))
		return
	if(istype(target, /obj/structure/reagent_dispensers/fueltank) || istype(target, /obj/item/reagent_containers/portable_fuelcan) && get_dist(src,target) <= 1)
		if(!welding && max_fuel)
			target.reagents.trans_to_obj(src, max_fuel)
			to_chat(user, "<span class='notice'>You refill [src].</span>")
			playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
			return
		else if(!welding)
			to_chat(user, "<span class='notice'>[src] doesn't use fuel.</span>")
			return
		else
			message_admins("[key_name_admin(user)] triggered a fueltank explosion with a welding tool.")
			log_game("[key_name(user)] triggered a fueltank explosion with a welding tool.")
			to_chat(user, "<span class='danger'>You begin welding on the fueltank and with a moment of lucidity you realize, this might not have been the smartest thing you've ever done.</span>")
			var/obj/structure/reagent_dispensers/fueltank/tank = target
			tank.explode()
			return
	if (src.welding)
		remove_fuel(1)
		var/turf/location = get_turf(user)
		if(isliving(target))
			var/mob/living/L = target
			L.IgniteMob()
		if (istype(location, /turf))
			location.hotspot_expose(700, 50, 1)

/obj/item/weldingtool/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	setWelding(!welding, user)

//Returns the amount of fuel in the welder
/obj/item/weldingtool/proc/get_fuel()
	return reagents.get_reagent_amount(/datum/reagent/fuel)

/obj/item/weldingtool/proc/get_max_fuel()
	return max_fuel

/obj/item/weldingtool/using_as_tool(function, flags, datum/event_args/actor/clickchain/e_args, atom/target, time, cost, usage)
	. = ..()
	if(!. || function != TOOL_WELDER)
		return
	if(!isOn())
		e_args.chat_feedback(SPAN_WARNING("[src] must be on to be used to weld!"), target)
		return FALSE
	// floor
	var/computed = round(cost * time * TOOL_WELDING_FUEL_PER_DS)
	if(get_fuel() < computed)
		e_args.chat_feedback(SPAN_WARNING("[src] doesn't have enough fuel left to do that!"), target)
		return FALSE

/obj/item/weldingtool/used_as_tool(function, flags, datum/event_args/actor/clickchain/e_args, atom/target, time, cost, usage, success)
	. = ..()
	if(!.)
		return
	remove_fuel(round(cost * time * TOOL_WELDING_FUEL_PER_DS))

//Removes fuel from the welding tool. If a mob is passed, it will perform an eyecheck on the mob. This should probably be renamed to use()
/obj/item/weldingtool/proc/remove_fuel(var/amount = 1, var/mob/M = null)
	if(!welding)
		return 0
	if(amount)
		burned_fuel_for = 0 // Reset the counter since we're removing fuel.
	if(get_fuel() >= amount)
		reagents.remove_reagent("fuel", amount)
		if(M)
			eyecheck(M)
		update_icon()
		return 1
	else
		if(M)
			to_chat(M, "<span class='notice'>You need more welding fuel to complete this task.</span>")
		update_icon()
		return 0

//Returns whether or not the welding tool is currently on.
/obj/item/weldingtool/proc/isOn()
	return welding

/obj/item/weldingtool/update_icon()
	..()
	cut_overlays()
	var/list/overlays_to_add = list()
	// Welding overlay.
	if(welding)
		var/image/I = image(icon, src, "[icon_state]-on")
		overlays_to_add += I
		item_state = "[initial(item_state)]1"
	else
		item_state = initial(item_state)

	// Fuel counter overlay.
	if(change_icons && get_max_fuel())
		var/ratio = get_fuel() / get_max_fuel()
		ratio = CEILING(ratio * 4, 1) * 25
		var/image/I = image(icon, src, "[icon_state][ratio]")
		overlays_to_add += I

	add_overlay(overlays_to_add)

	// Lights
	if(welding && flame_intensity)
		set_light(flame_intensity, flame_intensity, flame_color)
	else
		set_light(0)

	update_worn_icon()

//Sets the welding state of the welding tool. If you see W.welding = 1 anywhere, please change it to W.setWelding(1)
//so that the welding tool updates accordingly
/obj/item/weldingtool/proc/setWelding(var/set_welding, var/mob/M)
	if(!status)	return

	var/turf/T = get_turf(src)
	//If we're turning it on
	if(set_welding && !welding)
		if (get_fuel() > 0)
			if(M)
				to_chat(M, "<span class='notice'>You switch the [src] on.</span>")
			else if(T)
				T.visible_message("<span class='danger'>\The [src] turns on.</span>")
			playsound(loc, acti_sound, 50, 1)
			src.damage_force = 15
			src.damage_type = DAMAGE_TYPE_BURN
			src.set_weight_class(WEIGHT_CLASS_BULKY)
			src.attack_sound = 'sound/items/welder.ogg'
			welding = 1
			update_icon()
			if(!always_process)
				START_PROCESSING(SSobj, src)
		else
			if(M)
				var/msg = max_fuel ? "welding fuel" : "charge"
				to_chat(M, "<span class='notice'>You need more [msg] to complete this task.</span>")
			return
	//Otherwise
	else if(!set_welding && welding)
		if(!always_process)
			STOP_PROCESSING(SSobj, src)
		if(M)
			to_chat(M, "<span class='notice'>You switch \the [src] off.</span>")
		else if(T)
			T.visible_message("<span class='warning'>\The [src] turns off.</span>")
		playsound(loc, deac_sound, 50, 1)
		src.damage_force = 3
		src.damage_type = DAMAGE_TYPE_BRUTE
		src.set_weight_class(initial(src.w_class))
		src.welding = 0
		src.attack_sound = initial(src.attack_sound)
		update_icon()

//Decides whether or not to damage a player's eyes based on what they're wearing as protection
//Note: This should probably be moved to mob
/obj/item/weldingtool/proc/eyecheck(mob/living/carbon/user)
	if(!istype(user))
		return 1
	var/safety = user.eyecheck()
	safety = clamp( safety + eye_safety_modifier, -1,  2)
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/internal/eyes/E = H.internal_organs_by_name[O_EYES]
		if(!E)
			return
		if(H.nif && H.nif.flag_check(NIF_V_UVFILTER,NIF_FLAGS_VISION))
			return
		switch(safety)
			if(1)
				to_chat(usr, "<span class='warning'>Your eyes sting a little.</span>")
				E.damage += rand(1, 2)
				if(E.damage > 12)
					user.eye_blurry += rand(3,6)
			if(0)
				to_chat(usr, "<span class='warning'>Your eyes burn.</span>")
				E.damage += rand(2, 4)
				if(E.damage > 10)
					E.damage += rand(4,10)
			if(-1)
				to_chat(usr, "<span class='danger'>Your thermals intensify the welder's glow. Your eyes itch and burn severely.</span>")
				user.eye_blurry += rand(12,20)
				E.damage += rand(12, 16)
		if(safety<2)

			if(E.damage > 10)
				to_chat(user, "<span class='warning'>Your eyes are really starting to hurt. This can't be good for you!</span>")

			if (E.damage >= E.min_broken_damage)
				to_chat(user, "<span class='danger'>You go blind!</span>")
				user.remove_blindness_source( TRAIT_BLINDNESS_EYE_DMG)
			else if (E.damage >= E.min_bruised_damage)
				to_chat(user, "<span class='danger'>You go blind!</span>")
				user.apply_status_effect(/datum/status_effect/sight/blindness, 5 SECONDS)
				user.eye_blurry = 5
				user.disabilities |= DISABILITY_NEARSIGHTED
				spawn(100)
					user.disabilities &= ~DISABILITY_NEARSIGHTED
	return

/obj/item/weldingtool/is_hot()
	return isOn()

/obj/item/weldingtool/largetank
	name = "industrial welding tool"
	desc = "A slightly larger welder with a larger tank."
	icon_state = "indwelder"
	max_fuel = 40
	origin_tech = list(TECH_ENGINEERING = 2, TECH_PHORON = 2)
	materials_base = list(MAT_STEEL = 70, MAT_GLASS = 60)

/obj/item/weldingtool/largetank/cyborg
	name = "integrated welding tool"
	desc = "An advanced welder designed to be used in robotic systems."
	tool_speed = 0.5

/obj/item/weldingtool/hugetank
	name = "upgraded welding tool"
	desc = "A much larger welder with a huge tank."
	icon_state = "indwelder"
	max_fuel = 80
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = list(TECH_ENGINEERING = 3)
	materials_base = list(MAT_STEEL = 70, MAT_GLASS = 120)

/obj/item/weldingtool/mini
	name = "emergency welding tool"
	desc = "A miniature welder used during emergencies."
	icon_state = "miniwelder"
	max_fuel = 10
	w_class = WEIGHT_CLASS_SMALL
	materials_base = list(MAT_METAL = 30, MAT_GLASS = 10)
	change_icons = 0
	tool_speed = 2
	eye_safety_modifier = 1 // Safer on eyes.

/obj/item/weldingtool/bone
	name = "Elder's Bellows"
	desc = "A curious welding tool that uses an anomalous crystal and a bellows to create heat."
	icon = 'icons/obj/lavaland.dmi'
	icon_state = "ashwelder"
	max_fuel = 20
	materials_base = list(MAT_METAL = 30, MAT_BONE = 10)
	tool_speed = 3 ///It doesn't get that hot
	eye_safety_modifier = 3 // Safe for Scorians who don't have goggles.
	always_process = TRUE

//I can't currently think of a good vector for welding fuel. Plus these welders are like, magic anyways, so.
/obj/item/weldingtool/bone/process(delta_time)
	if(get_fuel() <= get_max_fuel())
		reagents.add_reagent("fuel", 1)
	..()

/obj/item/weldingtool/brass
	name = "brass welding tool"
	desc = "A brass plated welder utilizing an antiquated, yet incredibly efficient, fuel system."
	icon_state = "brasswelder"
	max_fuel = 40
	materials_base = list(MAT_STEEL = 70, "brass" = 60)
	tool_speed = 0.75

/datum/category_item/catalogue/anomalous/precursor_a/alien_welder
	name = "Precursor Alpha Object - Self Refueling Exothermic Tool"
	desc = "An unwieldly tool which somewhat resembles a weapon, due to \
	having a prominent trigger attached to the part which would presumably \
	have been held by whatever had created this object. When the trigger is \
	held down, a small but very high temperature flame shoots out from the \
	tip of the tool. The grip is able to be held by human hands, however the \
	shape makes it somewhat awkward to hold.\
	<br><br>\
	The tool appears to utilize an unknown fuel to light and maintain the \
	flame. What is more unusual, is that the fuel appears to replenish itself. \
	How it does this is not known presently, however experimental human-made \
	welders have been known to have a similar quality.\
	<br><br>\
	Interestingly, the flame is able to cut through a wide array of materials, \
	such as iron, steel, stone, lead, plasteel, and even durasteel. Yet, it is unable \
	to cut the unknown material that itself and many other objects made by this \
	precursor civilization have made. This raises questions on the properties of \
	that material, and how difficult it would have been to work with. This tool \
	does demonstrate, however, that the alien fuel cannot melt precursor beams, walls, \
	or other structual elements, making it rather limited for their \
	deconstruction purposes."
	value = CATALOGUER_REWARD_EASY

/obj/item/weldingtool/alien
	name = "alien welding tool"
	desc = "An alien welding tool. Whatever fuel it uses, it never runs out."
	catalogue_data = list(/datum/category_item/catalogue/anomalous/precursor_a/alien_welder)
	icon = 'icons/obj/abductor.dmi'
	icon_state = "welder"
	tool_speed = 0.1
	flame_color = "#6699FF" // Light bluish.
	eye_safety_modifier = 2
	change_icons = 0
	origin_tech = list(TECH_PHORON = 5 ,TECH_ENGINEERING = 5)
	always_process = TRUE

/obj/item/weldingtool/alien/process(delta_time)
	if(get_fuel() <= get_max_fuel())
		reagents.add_reagent("fuel", 1)
	..()

/obj/item/weldingtool/experimental
	name = "experimental welding tool"
	desc = "An experimental welder capable of synthesizing its own fuel from waste compounds. It can output a flame hotter than regular welders."
	icon_state = "exwelder"
	max_fuel = 40
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = list(TECH_ENGINEERING = 4, TECH_PHORON = 3)
	materials_base = list(MAT_STEEL = 70, MAT_GLASS = 120)
	tool_speed = 0.5
	change_icons = 0
	flame_intensity = 3
	always_process = TRUE
	var/nextrefueltick = 0

/obj/item/weldingtool/experimental/process(delta_time)
	..()
	if(get_fuel() < get_max_fuel() && nextrefueltick < world.time)
		nextrefueltick = world.time + 10
		reagents.add_reagent("fuel", 1)

/obj/item/weldingtool/experimental/brass
	name = "replica clockwork welding tool"
	desc = "A re-engineered experimental welder. It sports anti-corrosive brass fittings, and a further refined fuel system."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwelder"
	max_fuel = 50
	tool_speed = 0.4
	flame_color = "#990000" // deep red, as the sprite shows
	change_icons = 0

/obj/item/weldingtool/experimental/clockwork
	name = "clockwork welding tool"
	desc = "An antique welding tool, adorned with brass, and a brilliant red gem as the fuel tank. It neither runs out of fuel, nor harms the unprotected eye."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwelder"
	max_fuel = 100
	eye_safety_modifier = 2
	tool_sound = 'sound/machines/clockcult/steam_whoosh.ogg'
	tool_speed = 0.1
	flame_color = "#990000" // deep red, as above, so below
	change_icons = 0

/obj/item/weldingtool/experimental/clockwork/examine(mob/user, dist)
	. = ..()
	. += SPAN_NEZBERE("Sometimes, the best masterworks are lessons in rediscovering simplicity. Thousands upon thousands of these passed through the Great Forgeworks, and out into the void. Treasure this find, friend.")

/obj/item/weldingtool/experimental/hybrid
	name = "strange welding tool"
	desc = "An experimental welder capable of synthesizing its own fuel from spatial waveforms. It's like welding with a star!"
	icon_state = "hybwelder"
	max_fuel = 80
	eye_safety_modifier = -2	// Brighter than the sun. Literally, you can look at the sun with a welding mask of proper grade, this will burn through that.
	weight = ITEM_WEIGHT_HYBRID_TOOLS
	tool_speed = 0.25
	w_class = WEIGHT_CLASS_BULKY
	flame_intensity = 5
	origin_tech = list(TECH_ENGINEERING = 5, TECH_PHORON = 4, TECH_PRECURSOR = 1)
	reach = 2

/*
 * Backpack Welder.
 */

/obj/item/weldingtool/tubefed
	name = "tube-fed welding tool"
	desc = "A bulky, cooler-burning welding tool that draws from a worn welding tank."
	icon_state = "tubewelder"
	max_fuel = 10
	w_class = WEIGHT_CLASS_HUGE
	materials_base = null
	tool_speed = 1.25
	change_icons = 0
	flame_intensity = 1
	eye_safety_modifier = 1
	always_process = TRUE
	var/obj/item/weldpack/mounted_pack = null

/obj/item/weldingtool/tubefed/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/item/weldpack))
		var/obj/item/weldpack/holder = loc
		mounted_pack = holder
	else
		qdel(src)

/obj/item/weldingtool/tubefed/Destroy()
	mounted_pack.nozzle = null
	mounted_pack = null
	return ..()

/obj/item/weldingtool/tubefed/process(delta_time)
	if(mounted_pack)
		if(!istype(mounted_pack.loc,/mob/living/carbon/human))
			mounted_pack.return_nozzle()
		else
			var/mob/living/carbon/human/H = mounted_pack.loc
			if(H.back != mounted_pack)
				mounted_pack.return_nozzle()

	if(mounted_pack.loc != src.loc && src.loc != mounted_pack)
		mounted_pack.return_nozzle()
		visible_message("<span class='notice'>\The [src] retracts to its fueltank.</span>")

	if(get_fuel() <= get_max_fuel())
		mounted_pack.reagents.trans_to_obj(src, 1)

	..()

/obj/item/weldingtool/tubefed/dropped(mob/user, flags, atom/newLoc)
	..()
	if(src.loc != user)
		mounted_pack.return_nozzle()
		to_chat(user, "<span class='notice'>\The [src] retracts to its fueltank.</span>")

/obj/item/weldingtool/tubefed/survival
	name = "tube-fed emergency welding tool"
	desc = "A bulky, cooler-burning welding tool that draws from a worn welding tank."
	icon_state = "tubewelder"
	max_fuel = 5
	tool_speed = 1.75
	eye_safety_modifier = 2

//Welder Spear
/obj/item/weldingtool/welder_spear
	name = "welder spear"
	desc = "A miniature welder attached to a spear, providing more reach. Typically used by Tyrmalin workers."
	icon_state = "welderspear"
	max_fuel = 10
	w_class = WEIGHT_CLASS_NORMAL
	materials_base = list(MAT_METAL = 50, MAT_GLASS = 10)
	tool_speed = 1.5
	eye_safety_modifier = 1 // Safer on eyes.
	reach = 2

/obj/item/weldingtool/welder_spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/jousting)

/*
 * Electric/Arc Welder
 */

/obj/item/weldingtool/electric	//AND HIS WELDING WAS ELECTRIC
	name = "electric welding tool"
	desc = "A welder which runs off of electricity."
	icon_state = "arcwelder"
	max_fuel = 0	//We'll handle the consumption later.
	item_state = "ewelder"
	worth_intrinsic = 70
	var/obj/item/cell/power_supply //What type of power cell this uses
	var/charge_cost = 24	//The rough equivalent of 1 unit of fuel, based on us wanting 10 welds per battery
	var/cell_type = /obj/item/cell/device
	var/use_external_power = 0	//If in a borg or hardsuit, this needs to = 1
	flame_color = "#00CCFF"  // Blue-ish, to set it apart from the gas flames.
	acti_sound = /datum/soundbyte/sparks
	deac_sound = /datum/soundbyte/sparks

/obj/item/weldingtool/electric/unloaded
	cell_type = null

/obj/item/weldingtool/electric/Initialize(mapload)
	. = ..()
	if(cell_type == null)
		update_icon()
	else if(cell_type)
		power_supply = new cell_type(src)
	else
		power_supply = new /obj/item/cell/device(src)
	update_icon()

/obj/item/weldingtool/electric/get_cell(inducer)
	return power_supply

/obj/item/weldingtool/electric/examine(mob/user, dist)
	. = ..()
	if(get_dist(src, user) > 1)
		return
	else					// The << need to stay, for some reason no they dont
		if(power_supply)
			. += "[icon2html(thing = src, target = world)] The [src] has [get_fuel()] charge left."
		else
			. += "[icon2html(thing = src, target = world)] The [src] has no power cell!"

/obj/item/weldingtool/electric/get_fuel()
	if(use_external_power)
		var/obj/item/cell/external = get_external_power_supply()
		if(external)
			return external.charge
	else if(power_supply)
		return power_supply.charge
	else
		return 0

/obj/item/weldingtool/electric/get_max_fuel()
	if(use_external_power)
		var/obj/item/cell/external = get_external_power_supply()
		if(external)
			return external.maxcharge
	else if(power_supply)
		return power_supply.maxcharge
	return 0

/obj/item/weldingtool/electric/remove_fuel(var/amount = 1, var/mob/M = null)
	if(!welding)
		return 0
	if(get_fuel() >= amount)
		power_supply.checked_use(charge_cost)
		if(use_external_power)
			var/obj/item/cell/external = get_external_power_supply()
			if(!external || !external.use(charge_cost)) //Take power from the borg...
				power_supply.give(charge_cost)	//Give it back to the cell.
		if(M)
			eyecheck(M)
		update_icon()
		return 1
	else
		if(M)
			to_chat(M, "<span class='notice'>You need more energy to complete this task.</span>")
		update_icon()
		return 0

/obj/item/weldingtool/electric/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(user.get_inactive_held_item() == src)
		if(power_supply)
			power_supply.update_icon()
			user.put_in_hands(power_supply)
			power_supply = null
			to_chat(user, "<span class='notice'>You remove the cell from the [src].</span>")
			setWelding(0)
			update_icon()
			return
		..()
	else
		return ..()

/obj/item/weldingtool/electric/attackby(obj/item/W, mob/user as mob)
	if(istype(W, /obj/item/cell))
		if(istype(W, /obj/item/cell/device))
			if(!power_supply)
				if(!user.attempt_insert_item_for_installation(W, src))
					return
				power_supply = W
				to_chat(user, "<span class='notice'>You install a cell in \the [src].</span>")
				update_icon()
			else
				to_chat(user, "<span class='notice'>\The [src] already has a cell.</span>")
		else
			to_chat(user, "<span class='notice'>\The [src] cannot use that type of cell.</span>")
	else
		..()

/obj/item/weldingtool/electric/proc/get_external_power_supply()
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		return R.cell
	if(istype(src.loc, /obj/item/hardsuit_module))
		var/obj/item/hardsuit_module/module = src.loc
		if(module.holder && module.holder.wearer)
			var/mob/living/carbon/human/H = module.holder.wearer
			if(istype(H) && H.back)
				var/obj/item/hardsuit/suit = H.back
				if(istype(suit))
					return suit.cell
	return null

/obj/item/weldingtool/electric/mounted
	use_external_power = 1

/obj/item/weldingtool/electric/mounted/cyborg
	tool_speed = 0.5


/obj/item/weldingtool/electric/mounted/RIGset
	name = "arc welder"
	tool_speed = 0.7 // Let's see if this works with RIGs
	desc = "If you're seeing this, someone did a dum-dum."

/obj/item/weldingtool/electric/mounted/exosuit
	var/obj/item/vehicle_module/equip_mount = null
	flame_intensity = 1
	eye_safety_modifier = 2
	always_process = TRUE

/obj/item/weldingtool/electric/mounted/exosuit/Initialize(mapload)
	. = ..()

	if(istype(loc, /obj/item/vehicle_module))
		equip_mount = loc

/obj/item/weldingtool/electric/mounted/exosuit/process()
	..()

	if(equip_mount && equip_mount.chassis)
		var/obj/vehicle/sealed/mecha/M = equip_mount.chassis
		if(M.selected == equip_mount && get_fuel())
			setWelding(TRUE, M.occupant_legacy)
		else
			setWelding(FALSE, M.occupant_legacy)

#undef WELDER_FUEL_BURN_INTERVAL

/obj/item/weldingtool/electric/crystal
	name = "crystalline arc welder"
	desc = "A crystalline welding tool of an alien make."
	icon_state = "crystal_welder"
	item_state = "crystal_tool"
	icon = 'icons/obj/crystal_tools.dmi'
	materials_base = list(MATERIAL_CRYSTAL = 1250)
	cell_type = null
	charge_cost = null
	tool_speed = 0.2
	use_external_power = 1

/obj/item/weldingtool/electric/crystal/attackby(var/obj/item/W, var/mob/user)
	return

/obj/item/weldingtool/electric/crystal/update_icon()
	. = ..()
	icon_state = welding ? "crystal_welder_on" : "crystal_welder"
	item_state = welding ? "crystal_tool_lit"  : "crystal_tool"
	update_worn_icon()

/obj/item/weldingtool/electric/crystal/attack_self(mob/user, datum/event_args/actor/actor)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return
	if(H.species.name == SPECIES_ADHERENT)
		if(user.nutrition >= 40)
			setWelding(!welding, user)
		else
			to_chat(user, "<span class='notice'>You need more charge to activate your arc welder.</span>")
	else
		to_chat(user, "<span class='notice'>This tool is beyond your understanding.</span>")

/obj/item/weldingtool/electric/crystal/get_fuel()
	if(ishuman(src.loc))
		var/mob/living/carbon/human/R = src.loc
		if(R.species.name == SPECIES_ADHERENT)
			return R.nutrition
		else
			return

/obj/item/weldingtool/electric/crystal/get_external_power_supply()
	return get_fuel()

/obj/item/weldingtool/electric/crystal/get_max_fuel()
	return get_fuel()

/obj/item/weldingtool/electric/crystal/remove_fuel(var/amount = 1, var/mob/M = null)
	if(ishuman(src.loc))
		var/mob/living/carbon/human/R = src.loc
		if(R.species.name == SPECIES_ADHERENT)
			if(R.nutrition >= amount)
				R.nutrition = R.nutrition - amount
				return 1
			else
				if(M)
					to_chat(M, "<span class='notice'>You need more energy to complete this task.</span>")
				update_icon()
				return 0
