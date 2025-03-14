// -- Datums -- //

/obj/overmap/entity/visitable/sector/alienship
	name = "Unknown Vessel"
	desc = "An unknown vessel detected by sensors."
	start_x = 12
	start_y = 12
	icon_state = "ship"
	color = "#ff00ff" //Sandy
	initial_generic_waypoints = list("tether_excursion_alienship")

// -- Objs -- //

/obj/away_mission_init/alienship
	name = "away mission initializer - alienship"
	icon = 'icons/map_assets/level/alienship.dmi'
	icon_state = null
	mouse_opacity = 0
	invisibility = 101

	//Shared!
	var/static/mission_mode
	var/static/list/teleport_friends
	var/static/area/shuttle/excursion/away_alienship/area_friend

	//Unique!
	var/door_on_mode
	var/teleport_on_mode

/obj/away_mission_init/alienship/Initialize(mapload)
	. = ..()

	if(!mission_mode) //WE ARE NUMBER ONE
		mission_mode = pick("n2s","s2n","e2w","w2e")
		area_friend = locate(/area/shuttle/excursion/away_alienship)
		teleport_friends = list()
		area_friend.teleport_to = teleport_friends

	//I'm supposed to place a door and remove a wall
	if(mission_mode == door_on_mode)
		var/turf/T = get_turf(src)
		for(var/obj/O in loc)
			qdel(O)
		T.ChangeTurf(/turf/simulated/shuttle/floor/alienplating)
		new /obj/machinery/door/airlock/alien/public(T)

	//I'm supposed to stick around and be a teleport target
	if(mission_mode == teleport_on_mode)
		teleport_friends += src

	else //You are dismissed
		return INITIALIZE_HINT_QDEL

/obj/machinery/porta_turret/alien/ion
	name = "interior anti-boarding turret"
	desc = "A very tough looking turret made by alien hands."
	installation = /obj/item/gun/projectile/energy/ionrifle/weak
	enabled = TRUE
	lethal = TRUE
	ailock = TRUE
	check_all = TRUE
	integrity = 250
	integrity_max = 250

/obj/away_mission_init/alienship/door_n2s
	icon_state = "n2s"
	door_on_mode = "n2s"

/obj/away_mission_init/alienship/door_s2n
	icon_state = "s2n"
	door_on_mode = "s2n"

/obj/away_mission_init/alienship/door_e2w
	icon_state = "e2w"
	door_on_mode = "e2w"

/obj/away_mission_init/alienship/door_w2e
	icon_state = "w2e"
	door_on_mode = "w2e"

/obj/away_mission_init/alienship/start_n2s
	icon_state = "n2s"
	teleport_on_mode = "n2s"

/obj/away_mission_init/alienship/start_s2n
	icon_state = "s2n"
	teleport_on_mode = "s2n"

/obj/away_mission_init/alienship/start_e2w
	icon_state = "e2w"
	teleport_on_mode = "e2w"

/obj/away_mission_init/alienship/start_w2e
	icon_state = "w2e"
	teleport_on_mode = "w2e"

/obj/item/reagent_containers/hypospray/autoinjector/alien
	name = "alien injector(?)"
	desc = "It appears to contain some sort of liquid and has a needle for injecting."
	icon = 'icons/map_assets/level/alienship.dmi'
	icon_state = "alien_injector"
	item_state = "autoinjector"
	filled_reagents = list("rezadone" = 4, "corophizine" = 1)


// -- Areas -- //

/area/shuttle/excursion/away_alienship
	name = "\improper Excursion Shuttle - Alien Ship"
	var/did_entry = FALSE
	var/list/teleport_to
	var/area/dump_area
	var/obj/shuttle_connector/shuttle_friend

/area/shuttle/excursion/away_alienship/Initialize(mapload)
	. = ..()
	dump_area = locate(/area/tether_away/alienship/equip_dump)

// /area/shuttle/excursion/away_alienship/shuttle_arrived()
// 	. = ..()
// 	spawn(20)
// 		if(did_entry)
// 			return

// 		//No talky!
// 		for(var/obj/machinery/telecomms/relay/R in contents)
// 			R.toggled = FALSE
// 			R.update_power()

// 		//Teleport time!
// 		for(var/mob in GLOB.player_list) //This is extreme, but it's very hard to find people hiding in things, and this is pretty cheap.
// 			try
// 				if(isliving(mob) && get_area(mob) == src)
// 					abduct(mob)
// 			catch
// 				log_debug(SPAN_DEBUG("Problem doing [mob] for Alienship arrival teleport!"))

// 		did_entry = TRUE

// /area/shuttle/excursion/away_alienship/proc/abduct(var/mob/living/mob)
// 	if(isliving(mob))
// 		var/mob/living/L = mob

// 		//Situations to get the mob out of
// 		if(L.buckled)
// 			L.buckled.unbuckle_mob()
// 		if(istype(L.loc,/obj/vehicle/sealed/mecha))
// 			var/obj/vehicle/sealed/mecha/M = L.loc
// 			M.go_out()
// 		else if(istype(L.loc,/obj/machinery/sleeper))
// 			var/obj/machinery/sleeper/SL = L.loc
// 			SL.go_out()
// 		else if(istype(L.loc,/obj/machinery/recharge_station))
// 			var/obj/machinery/recharge_station/RS = L.loc
// 			RS.go_out()

// 		L.forceMove(pick(get_area_turfs(dump_area)))
// 		if(!issilicon(L)) //Don't drop borg modules...
// 			for(var/obj/item/I in L.get_equipped_items(TRUE, TRUE))
// 				if(istype(I,/obj/item/holder))
// 					var/obj/item/holder/H = I
// 					var/mob/living/M = H.held_mob
// 					H.forceMove(get_turf(L))
// 					abduct(M)
// 					continue
// 				L.drop_item_to_ground(I, INV_OP_FORCE)
// 			// second pass - NO HIDING, M*CROS
// 			for(var/obj/item/holder/H in L.get_all_contents())
// 				H.forceMove(get_turf(L))
// 				abduct(H)
// 		L.afflict_unconscious(20 * 10)
// 		L.forceMove(get_turf(pick(teleport_to)))
// 		L << 'sound/effects/bamf.ogg'
// 		to_chat(L,"<span class='warning'>You're starting to come to. You feel like you've been out for a few minutes, at least...</span>")

/area/tether_away/alienship
	name = "\improper Away Mission - Unknown Vessel"
	icon_state = "away"
	requires_power = FALSE

/area/tether_away/alienship/equip_dump
