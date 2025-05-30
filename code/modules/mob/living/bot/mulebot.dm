#define MULE_IDLE 0
#define MULE_MOVING 1
#define MULE_UNLOAD 2
#define MULE_LOST 3
#define MULE_CALC_MIN 4
#define MULE_CALC_MAX 10
#define MULE_PATH_DONE 11
// IF YOU CHANGE THOSE, UPDATE THEM IN pda.tmpl TOO

/datum/category_item/catalogue/technology/bot/mulebot
	name = "Bot - Mulebot"
	desc = "Mulebots are a favorite option for logistical services in \
	Frontier space. Equipped with semi-sophisticated pathfinding systems, \
	Mulebots can work out their own routes between destination tags. Some \
	technicians can alter these routines to allow for human riders or faster \
	motion, although this does often risk overriding vital safety protocols."
	value = CATALOGUER_REWARD_TRIVIAL

/mob/living/bot/mulebot
	name = "Mulebot"
	desc = "A Multiple Utility Load Effector bot."
	icon = 'icons/obj/bots/mulebots.dmi'
	icon_state = "mulebot0"
	anchored = TRUE
	density = TRUE
	health = 150
	maxHealth = 150
	mob_bump_flag = HEAVY
	catalogue_data = list(/datum/category_item/catalogue/technology/bot/mulebot)

	min_target_dist = 0
	max_target_dist = 250
	target_speed = 3
	max_frustration = 5
	botcard_access = list(ACCESS_ENGINEERING_MAINT, ACCESS_SUPPLY_MAIN, ACCESS_SUPPLY_BAY, ACCESS_SUPPLY_MULEBOT, ACCESS_SUPPLY_QM, ACCESS_SUPPLY_MINE, ACCESS_SUPPLY_MINE_OUTPOST)

	var/atom/movable/load

	var/paused = FALSE
	var/crates_only = TRUE
	var/auto_return = TRUE
	var/safety = TRUE

	var/targetName
	var/turf/home
	var/homeName

	var/global/amount = 0

/mob/living/bot/mulebot/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(loc)
	var/obj/machinery/navbeacon/N = locate() in T
	if(N)
		home = T
		homeName = N.location
	else
		homeName = "Unset"

	suffix = num2text(++amount) // Starts from 1

	name = "Mulebot #[suffix]"

/mob/living/bot/mulebot/MouseDroppedOnLegacy(var/atom/movable/C, var/mob/user)
	if(user.stat)
		return

	if(!istype(C) || C.anchored || get_dist(user, src) > 1 || get_dist(src, C) > 1 )
		return

	load(C)

/mob/living/bot/mulebot/interact(mob/user)
	ui_interact(user)

/mob/living/bot/mulebot/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MuleBot", "Mulebot [suffix ? "([suffix])" : ""]")
		ui.open()

/mob/living/bot/mulebot/ui_data(mob/user, datum/tgui/ui)
	var/list/data = list(
		"suffix" = suffix,
		"power" = on,
		"issilicon" = issilicon(user),
		"load" = load,
		"locked" = locked,
		"auto_return" = auto_return,
		"crates_only" = crates_only,
		"hatch" = open,
		"safety" = safety,
	)
	return data

/mob/living/bot/mulebot/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return TRUE

	add_fingerprint(usr)
	switch(action)
		if("power")
			if(on)
				turn_off()
			else
				turn_on()
			visible_message("[usr] switches [on ? "on" : "off"] [src].")
			. = TRUE

		if("stop")
			obeyCommand("Stop")
			. = TRUE

		if("go")
			obeyCommand("GoTD")
			. = TRUE

		if("home")
			obeyCommand("Home")
			. = TRUE

		if("destination")
			obeyCommand("SetD")
			. = TRUE

		if("sethome")
			var/new_dest
			var/list/beaconlist = GetBeaconList()
			if(beaconlist.len)
				new_dest = input("Select new home tag", "Mulebot [suffix ? "([suffix])" : ""]", null) in null|beaconlist
			else
				alert("No destination beacons available.")
			if(new_dest)
				home = get_turf(beaconlist[new_dest])
				homeName = new_dest
			. = TRUE

		if("unload")
			unload()
			. = TRUE

		if("autoret")
			auto_return = !auto_return
			. = TRUE

		if("cargotypes")
			crates_only = !crates_only
			. = TRUE

		if("safety")
			safety = !safety
			. = TRUE

/mob/living/bot/mulebot/attackby(var/obj/item/O, var/mob/user)
	..()
	update_icons()

/mob/living/bot/mulebot/proc/obeyCommand(var/command)
	switch(command)
		if("Home")
			resetTarget()
			target = home
			targetName = "Home"
		if("SetD")
			var/new_dest
			var/list/beaconlist = GetBeaconList()
			if(beaconlist.len)
				new_dest = input("Select new destination tag", "Mulebot [suffix ? "([suffix])" : ""]") in null|beaconlist
			else
				alert("No destination beacons available.")
			if(new_dest)
				resetTarget()
				target = get_turf(beaconlist[new_dest])
				targetName = new_dest
		if("GoTD")
			paused = 0
		if("Stop")
			paused = 1

/mob/living/bot/mulebot/emag_act(var/remaining_charges, var/user)
	locked = !locked
	to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the mulebot's controls!</span>")
	flick("mulebot-emagged", src)
	playsound(loc, /datum/soundbyte/sparks, 100, 0)
	return 1

/mob/living/bot/mulebot/update_icons()
	if(open)
		icon_state = "mulebot-hatch"
		return
	if(target_path.len && !paused)
		icon_state = "mulebot1"
		return
	icon_state = "mulebot0"

/mob/living/bot/mulebot/handleRegular()
	if(!safety && prob(1))
		flick("mulebot-emagged", src)
	update_icons()

/mob/living/bot/mulebot/handleFrustrated()
	custom_emote(2, "makes a sighing buzz.")
	playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
	..()

/mob/living/bot/mulebot/handleAdjacentTarget()
	if(target == src.loc)
		custom_emote(2, "makes a chiming sound.")
		playsound(loc, 'sound/machines/chime.ogg', 50, 0)
		UnarmedAttack(target)
		resetTarget()
		if(auto_return && home && (loc != home))
			target = home
			targetName = "Home"

/mob/living/bot/mulebot/confirmTarget()
	return 1

/mob/living/bot/mulebot/calcTargetPath()
	..()
	if(!target_path.len && target != home) // I presume that target is not null
		resetTarget()
		target = home
		targetName = "Home"

/mob/living/bot/mulebot/stepToTarget()
	if(paused)
		return
	..()

/mob/living/bot/mulebot/UnarmedAttack(var/turf/T)
	if(T == src.loc)
		unload(dir)

/mob/living/bot/mulebot/Bump(var/mob/living/M)
	if(!safety && istype(M))
		visible_message("<span class='warning'>[src] knocks over [M]!</span>")
		M.afflict_paralyze(1 SECONDS)
		M.afflict_knockdown(2 SECONDS)
	..()

/mob/living/bot/mulebot/proc/runOver(var/mob/living/M)
	if(istype(M)) // At this point, MULEBot has somehow crossed over onto your tile with you still on it. CRRRNCH.
		visible_message("<span class='warning'>[src] drives over [M]!</span>")
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)

		var/damage = rand(5, 7)
		M.apply_damage(2 * damage, DAMAGE_TYPE_BRUTE, BP_HEAD)
		M.apply_damage(2 * damage, DAMAGE_TYPE_BRUTE, BP_TORSO)
		M.apply_damage(0.5 * damage, DAMAGE_TYPE_BRUTE, BP_L_LEG)
		M.apply_damage(0.5 * damage, DAMAGE_TYPE_BRUTE, BP_R_LEG)
		M.apply_damage(0.5 * damage, DAMAGE_TYPE_BRUTE, BP_L_ARM)
		M.apply_damage(0.5 * damage, DAMAGE_TYPE_BRUTE, BP_R_ARM)

		var/datum/blood_mixture/to_use
		if(iscarbon(M))
			var/mob/living/carbon/carbon = M
			to_use = carbon.get_blood_mixture()
		blood_splatter_legacy(get_turf(M), to_use, TRUE)

/mob/living/bot/mulebot/relaymove(var/mob/user, var/direction)
	if(load == user)
		unload(direction)

/mob/living/bot/mulebot/explode()
	unload(pick(0, 1, 2, 4, 8))

	visible_message("<span class='danger'>[src] blows apart!</span>")

	var/turf/Tsec = get_turf(src)
	new /obj/item/assembly/prox_sensor(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/cable_coil/cut(Tsec)

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/debris/cleanable/blood/oil(Tsec)
	..()

/mob/living/bot/mulebot/proc/GetBeaconList()
	var/list/beaconlist = list()
	for(var/obj/machinery/navbeacon/N in navbeacons)
		if(!N.codes["delivery"])
			continue
		beaconlist.Add(N.location)
		beaconlist[N.location] = N
	return beaconlist

/mob/living/bot/mulebot/proc/load(var/atom/movable/C)
	if(busy || load || get_dist(C, src) > 1 || !isturf(C.loc))
		return

	for(var/obj/structure/plasticflaps/P in src.loc)//Takes flaps into account
		if(!CanPass(C,P))
			return

	if(crates_only && !istype(C,/obj/structure/closet/crate))
		custom_emote(2, "makes a sighing buzz.")
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return

	var/obj/structure/closet/crate/crate = C
	if(istype(crate))
		crate.close()

	busy = 1

	C.forceMove(loc)
	sleep(2)
	if(C.loc != loc) //To prevent you from going onto more than one bot.
		return
	C.forceMove(src)
	load = C

	C.pixel_y += 9
	if(C.layer < layer)
		C.layer = layer + 0.1
	add_overlay(C)

	busy = 0

/mob/living/bot/mulebot/proc/unload(var/dirn = 0)
	if(!load || busy)
		return

	busy = 1
	cut_overlays()

	load.forceMove(loc)
	load.pixel_y -= 9
	load.layer = initial(load.layer)

	if(dirn)
		step(load, dirn)

	load = null

	for(var/atom/movable/AM in src)
		if(AM == botcard || AM == access_scanner)
			continue

		AM.forceMove(loc)
		AM.layer = initial(AM.layer)
		AM.pixel_y = initial(AM.pixel_y)
	busy = 0
