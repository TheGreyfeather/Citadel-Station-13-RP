/**
 *! ## Machines in the world, such as computers, pipes, and airlocks.
 *
 *? Overview:
 *-     Used to create objects that need a per step proc call.  Default definition of 'Initialize()'
 *-     stores a reference to src machine in global 'machines list'.  Default definition
 *-     of 'Destroy' removes reference to src machine in global 'machines list'.
 *
 *
 *! ## Class Variables:
 *
 *? use_power (num)
 *-     Current state of auto power use.
 *-     Possible Values:
 *-         NO_POWER_USE --- //? Machine will not use power automatically.
 *-         IDLE_POWER_USE - //? Machine is using power at its idle power level.
 *-         ACTIVE_POWER_USE //? Machine is using power at its active power level.
 *
 *? active_power_usage (num)
 *-     Value for the amount of power to use when in active power mode.
 *
 *? idle_power_usage (num)
 *-     Value for the amount of power to use when in idle power mode.
 *
 *? power_channel (num)
 *-     What channel to draw from when drawing power for power mode
 *-     Possible Values:
 *-         EQUIP:0 - //? Equipment Channel.
 *-         LIGHT:2 - //? Lighting Channel.
 *-         ENVIRON:3 //? Environment Channel.
 *
 *? component_parts (list)
 *-     A list of component parts of machine used by frame based machines.
 *
 *? panel_open (num)
 *-     Whether the panel is open.
 *
 *? uid (num)
 *-     Unique id of machine across all machines.
 *
 *? gl_uid (global num)
 *-     Next uid value in sequence.
 *
 *? machine_stat (bitflag)
 *-     Machine status bit flags.
 *-     Possible bit flags:
 *-        BROKEN:1 - //? Machine is broken.
 *-        NOPOWER:2  //? No power is being supplied to machine.
 *-        POWEROFF:4 //? tbd
 *-        MAINT:8 -- //? Machine is currently under going maintenance.
 *-        EMPED:16 - //? Temporary broken by EMP pulse.
 *
 *! ## Class Procs:
 *? Initialize()
 *
 *? Destroy()
 *
 *? auto_use_power()
 *-     This proc determines how power mode power is deducted by the machine.
 *-     'auto_use_power()' is called by the 'master_controller' game_controller every
 *-     tick.
 *
 *-     Return Values:
 *-         return:TRUE  //? If object is powered.
 *-         return:FALSE //? If object is not powered.
 *
 *-     Default definition uses 'use_power', 'power_channel', 'active_power_usage',
 *-     'idle_power_usage', 'powered()', and 'use_power()' implement behavior.
 *
 *? powered(chan = EQUIP)                       'modules/power/power.dm'
 *     Checks to see if area that contains the object has power available for power
 *     channel given in 'chan'.
 *
 *? use_power(amount, chan=EQUIP, autocalled)   'modules/power/power.dm'
 *     Deducts 'amount' from the power channel 'chan' of the area that contains the object.
 *     If it's autocalled then everything is normal, if something else calls use_power we are going to
 *     need to recalculate the power two ticks in a row.
 *
 *? power_change()                              'modules/power/power.dm'
 *     Called by the area that contains the object when ever that area under goes a
 *     power state change (area runs out of power, or area channel is turned off).
 *
 *? RefreshParts()                              'game/machinery/machine.dm'
 *-     Called to refresh the variables in the machine that are contributed to by parts
 *-     contained in the component_parts list. (example: glass and material amounts for
 *-     the autolathe)
 *
 *-    Default definition does nothing.
 *
 *? assign_uid()                                'game/machinery/machine.dm'
 *-    Called by machine to assign a value to the uid variable.
 *
 *? process()                                   'game/machinery/machine.dm'
 *-    Called by the 'master_controller' once per game tick for each machine that is listed in the 'machines' list.
 *
 *
 *! ## Compiled by Aygar
 *! ## Formatted by Zandario
 */
/obj/machinery
	name = "machinery"
	icon = 'icons/obj/stationobjs.dmi'
	w_class = WEIGHT_CLASS_HUGE
	layer = UNDER_JUNK_LAYER
	// todo: don't block rad contents and just have component parts be unable to be contaminated while inside
	// todo: wow rad contents is a weird system
	rad_flags = RAD_BLOCK_CONTENTS
	// todo: anchored / unanchored should be replaced by movement force someday, how to handle that?

	//* Construction / Deconstruction
	/// allow default part replacement. null for disallowed, number for time.
	var/default_part_replacement = 0
	/// Can be constructed / deconstructed by players by default. null for off, number for time needed. Panel must be open.
	//  todo: proc for allow / disallow, refactor
	var/default_deconstruct
	/// Can have panel open / closed by players by default. null for off, number for time needed. You usually want 0 for instant.
	var/default_panel
	/// Can be anchored / unanchored by players without deconstructing by default with a wrench. null for off, number for time needed.
	//  todo: proc for allow / disallow, refactor, unify with can_be_unanchored
	var/default_unanchor
	/// default deconstruct requires panel open
	var/default_deconstruct_requires_panel_open = TRUE
	/// tool used for deconstruction
	var/tool_deconstruct = TOOL_CROWBAR
	/// tool used for panel open
	var/tool_panel = TOOL_SCREWDRIVER
	/// tool used for unanchor
	var/tool_unanchor = TOOL_WRENCH
	/// default icon state overlay for panel open
	var/panel_icon_state
	/// is the maintenance panel open?
	var/panel_open = FALSE

	//* unsorted
	var/machine_stat = 0
	var/emagged = FALSE
	/**
	 * USE_POWER_OFF = dont run the auto
	 * USE_POWER_IDLE = run auto, use idle
	 * USE_POWER_ACTIVE = run auto, use active
	 */
	var/use_power = USE_POWER_IDLE
	/// idle power usage in watts
	var/idle_power_usage = 0
	/// active power usage in watts
	var/active_power_usage = 0
	///EQUIP, ENVIRON or LIGHT
	var/power_channel = EQUIP
	var/power_init_complete = FALSE
	///List of all the parts used to build it, if made from certain kinds of frames.
	var/list/component_parts = null
	var/uid
	var/global/gl_uid = 1
	///Sound played on succesful interface. Just put it in the list of vars at the start.
	var/clicksound
	///Volume of interface sounds.
	var/clickvol = 40
	var/obj/item/circuitboard/circuit = null
	///If false, SSmachines. If true, SSprocess_5fps.
	var/speed_process = FALSE

	var/interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_SET_MACHINE

// todo: from_frame? arg for frame to pass in context..
/obj/machinery/Initialize(mapload, newdir)
	if(newdir)
		setDir(newdir)
	. = ..()

	GLOB.machines += src

	if(ispath(circuit))
		circuit = new circuit(src)
		default_apply_parts()

	if(!speed_process)
		START_MACHINE_PROCESSING(src)
	else
		START_PROCESSING(SSprocess_5fps, src)

	if(!mapload)	// area handles this
		power_change()

/obj/machinery/Destroy()
	GLOB.machines.Remove(src)
	if(!speed_process)
		STOP_MACHINE_PROCESSING(src)
	else
		STOP_PROCESSING(SSprocess_5fps, src)
	if(component_parts)
		for(var/atom/A in component_parts)
			if(A.loc == src) // If the components are inside the machine, delete them.
				qdel(A)
			else // Otherwise we assume they were dropped to the ground during deconstruction, and were not removed from the component_parts list by deconstruction code.
				component_parts -= A
		component_parts = null
	if(contents) // The same for contents.
		for(var/atom/A in contents)
			if(ismob(A))
				var/mob/M = A
				M.forceMove(loc)
				M.update_perspective()
			else
				qdel(A)
	return ..()

/obj/machinery/process(delta_time)//If you dont use process or power why are you here
	return PROCESS_KILL

/obj/machinery/update_overlays()
	. = ..()
	if(panel_open && panel_icon_state)
		. += panel_icon_state

/obj/machinery/emp_act(severity)
	if(use_power && machine_stat == NONE)
		use_power(7500/severity)

		var/obj/effect/overlay/pulse2 = new /obj/effect/overlay(src.loc)
		pulse2.icon = 'icons/effects/effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.name = "emp sparks"
		pulse2.anchored = 1
		pulse2.setDir(pick(GLOB.cardinal))

		spawn(10)
			qdel(pulse2)
	..()

/obj/machinery/update_overlays()
	. = ..()
	if(panel_open && panel_icon_state)
		. += panel_icon_state

/obj/machinery/proc/set_panel_open(panel_opened)
	panel_open = panel_opened
	update_appearance()

/obj/machinery/vv_edit_var(var_name, new_value)
	if(var_name == NAMEOF(src, use_power))
		update_use_power(new_value)
		return TRUE
	else if(var_name == NAMEOF(src, power_channel))
		update_power_channel(new_value)
		return TRUE
	else if(var_name == NAMEOF(src, idle_power_usage))
		update_idle_power_usage(new_value)
		return TRUE
	else if(var_name == NAMEOF(src, active_power_usage))
		update_active_power_usage(new_value)
		return TRUE
	return ..()

// todo: refactor tihs
// todo: rendered_inoperable()
// todo: rendered_operable()

/obj/machinery/proc/operable(additional_flags = NONE)
	return !inoperable(additional_flags)

/obj/machinery/proc/inoperable(additional_flags = NONE)
	return (machine_stat & (NOPOWER | BROKEN | additional_flags))

/obj/machinery/CanUseTopic(mob/user)
	if(!(interaction_flags_machine & INTERACT_MACHINE_OFFLINE) && (machine_stat & (NOPOWER | BROKEN)))
		return UI_CLOSE
	return ..()

/obj/machinery/CouldUseTopic(mob/user)
	..()
	user.set_machine(src)

/obj/machinery/CouldNotUseTopic(mob/user)
	user.unset_machine()

////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/attack_ai(mob/user)
	if(IsAdminGhost(user))
		interact(user)
		return
	if(isrobot(user))
		// For some reason attack_robot doesn't work
		// This is to stop robots from using cameras to remotely control machines.
		if(user.client && user.client.eye == user)
			return attack_hand(user)
	else
		return attack_hand(user)

// todo: refactor
/obj/machinery/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(IsAdminGhost(user))
		return FALSE
	if(!user.IsAdvancedToolUser())
		to_chat(user, SPAN_WARNING("You don't have the dexterity to do this!"))
		return TRUE
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 55)
			visible_message(SPAN_WARNING("[H] stares cluelessly at [src]."))
			return TRUE
		else if(prob(H.getBrainLoss()))
			to_chat(user, SPAN_WARNING("You momentarily forget how to use [src]."))
			return TRUE

	if(clicksound && istype(user, /mob/living/carbon))
		playsound(src, clicksound, clickvol)

	return ..()

/obj/machinery/attackby(obj/item/I, mob/living/user, list/params, clickchain_flags, damage_multiplier)
	if(istype(I, /obj/item/storage/part_replacer))
		if(isnull(default_part_replacement))
			user.action_feedback(SPAN_WARNING("[src] doesn't support part replacement."), src)
			return CLICKCHAIN_DO_NOT_PROPAGATE
		default_part_replacement(user, I)
		return CLICKCHAIN_DO_NOT_PROPAGATE | CLICKCHAIN_DID_SOMETHING
	return ..()

/obj/machinery/can_interact(mob/user)
	if((machine_stat & (NOPOWER|BROKEN|MAINT)) && !(interaction_flags_machine & INTERACT_MACHINE_OFFLINE)) // Check if the machine is broken, and if we can still interact with it if so
		return FALSE
	var/silicon = issilicon(user)
	if(panel_open && !(interaction_flags_machine & INTERACT_MACHINE_OPEN)) // Check if we can interact with an open panel machine, if the panel is open
		if(!silicon || !(interaction_flags_machine & INTERACT_MACHINE_OPEN_SILICON))
			return FALSE
	// check silicon, but cyborgs can interact if within reach.
	// todo: refactor interaction flags, fuck.
	if(silicon && (!isrobot(user) || !user.Reachability(src))) // If we are an AI or adminghsot, make sure the machine allows silicons to interact
		if(!(interaction_flags_machine & INTERACT_MACHINE_ALLOW_SILICON))
			return FALSE
	else if(isliving(user)) // If we are a living human
		var/mob/living/L = user
		if(interaction_flags_machine & INTERACT_MACHINE_REQUIRES_SILICON) // First make sure the machine doesn't require silicon interaction
			return FALSE

		if(interaction_flags_machine & INTERACT_MACHINE_REQUIRES_SIGHT)
			if(user.is_blind())
				to_chat(user, SPAN_WARNING("This machine requires sight to use."))
				return FALSE
/*
		if(!Adjacent(user)) // Next make sure we are next to the machine unless we have telekinesis
			var/mob/living/carbon/H = L
			if(!(istype(H) && H.has_dna() && H.dna.check_mutation(MUTATION_TELEKINESIS)))
				return FALSE
*/
		if(L.incapacitated()) // Finally make sure we aren't incapacitated
			return FALSE
	else // If we aren't a silicon, living, or admin ghost, bad!
		return FALSE
	return TRUE // If we pass all these checks, woohoo! We can interact

/obj/machinery/proc/RefreshParts() //Placeholder proc for machines that are built using frames.
	return

/obj/machinery/proc/assign_uid()
	uid = gl_uid
	gl_uid++

/obj/machinery/proc/state(var/msg)
	for(var/mob/O in hearers(src, null))
		O.show_message("[icon2html(thing = src, target = O)] [SPAN_NOTICE(msg)]", 2)

/obj/machinery/proc/ping(text=null)
	if(!text)
		text = "\The [src] pings."

	state(text, "blue")
	playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)

/obj/machinery/proc/shock(mob/user, prb)
	if(inoperable())
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if(electrocute_mob(user, get_area(src), src, 0.7))
		var/area/temp_area = get_area(src)
		if(temp_area)
			var/obj/machinery/power/apc/temp_apc = temp_area.get_apc()

			if(temp_apc && temp_apc.terminal && temp_apc.terminal.powernet)
				temp_apc.terminal.powernet.trigger_warning()
		if(!CHECK_MOBILITY(user, MOBILITY_CAN_USE))
			return 1
	return 0

/obj/machinery/proc/default_apply_parts()
	var/obj/item/circuitboard/CB = circuit
	if(!istype(CB))
		return
	CB.apply_default_parts(src)
	RefreshParts()

// todo: this is fucked, refactor
/obj/machinery/proc/default_part_replacement(var/mob/user, var/obj/item/storage/part_replacer/R)
	if(!istype(R))
		return 0
	if(!component_parts)
		return 0
	to_chat(user, "<span class='notice'>Following parts detected in [src]:</span>")
	for(var/obj/item/C in component_parts)
		to_chat(user, "<span class='notice'>    [C.name]</span>")
	if(panel_open || !R.panel_req)
		var/obj/item/circuitboard/CB = circuit
		var/P
		var/replaced = FALSE //simply to play a sound for feedback for now.
		for(var/obj/item/A in component_parts)
			var/our_rating = A.rped_rating()
			if(isnull(our_rating))
				continue
			for(var/T in CB.req_components)
				if(ispath(A.type, T))
					P = T
					break
			for(var/obj/item/B in R.contents)
				var/their_rating = B.rped_rating()
				if(isnull(their_rating))
					continue
				if(istype(B, P) && istype(A, P))
					if(their_rating > our_rating)
						R.obj_storage.remove(B, src)
						R.obj_storage.insert(A, suppressed = TRUE, no_update = TRUE)
						component_parts -= A
						component_parts += B
						B.loc = null
						to_chat(user, "<span class='notice'>[A.name] replaced with [B.name].</span>")
						replaced = TRUE
						break
		R.obj_storage.ui_queue_refresh()
		if(replaced)
			playsound(src.loc, R.part_replacement_sound, 50, TRUE)
		update_appearance()
		RefreshParts()

	return 1

// todo: refactor
/obj/machinery/set_anchored(anchorvalue)
	. = ..()
	power_change()
	update_appearance()

// Default behavior for wrenching down machines.  Supports both delay and instant modes.
/obj/machinery/proc/default_unfasten_wrench(var/mob/user, var/obj/item/W, var/time = 0)
	if(!W.is_wrench())
		return FALSE
	if(panel_open)
		return FALSE // Close panel first!
	playsound(loc, W.tool_sound, 50, 1)
	var/actual_time = W.tool_speed * time
	if(actual_time != 0)
		user.visible_message( \
			"<span class='warning'>\The [user] begins [anchored ? "un" : ""]securing \the [src].</span>", \
			"<span class='notice'>You start [anchored ? "un" : ""]securing \the [src].</span>")
	if(actual_time == 0 || do_after(user, actual_time, target = src))
		user.visible_message( \
			"<span class='warning'>\The [user] has [anchored ? "un" : ""]secured \the [src].</span>", \
			"<span class='notice'>You [anchored ? "un" : ""]secure \the [src].</span>")
		anchored = !anchored
		power_change() //Turn on or off the machine depending on the status of power in the new area.
		update_appearance()
	return TRUE

/obj/machinery/proc/default_deconstruction_crowbar(var/mob/user, var/obj/item/C)
	if(!C.is_crowbar())
		return 0
	if(!panel_open)
		return 0
	. = dismantle()

/obj/machinery/proc/default_deconstruction_screwdriver(var/mob/user, var/obj/item/S)
	if(!S.is_screwdriver())
		return 0
	playsound(src, S.tool_sound, 50, 1)
	panel_open = !panel_open
	to_chat(user, "<span class='notice'>You [panel_open ? "open" : "close"] the maintenance hatch of [src].</span>")
	update_appearance()
	return 1

/obj/machinery/proc/computer_deconstruction_screwdriver(var/mob/user, var/obj/item/S)
	if(!S.is_screwdriver())
		return 0
	if(!circuit)
		return 0
	to_chat(user, "<span class='notice'>You start disconnecting the monitor.</span>")
	playsound(src, S.tool_sound, 50, 1)
	if(do_after(user, 20 * S.tool_speed))
		if(machine_stat & BROKEN)
			to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
		else
			to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
		. = dismantle()

/obj/machinery/proc/alarm_deconstruction_screwdriver(var/mob/user, var/obj/item/S)
	if(!S.is_screwdriver())
		return 0
	playsound(src, S.tool_sound, 50, 1)
	panel_open = !panel_open
	to_chat(user, "The wires have been [panel_open ? "exposed" : "unexposed"]")
	update_appearance()
	return 1

/obj/machinery/proc/alarm_deconstruction_wirecutters(var/mob/user, var/obj/item/W)
	if(!W.is_wirecutter())
		return 0
	if(!panel_open)
		return 0
	user.visible_message("<span class='warning'>[user] has cut the wires inside \the [src]!</span>", "You have cut the wires inside \the [src].")
	playsound(src.loc, W.tool_sound, 50, 1)
	new/obj/item/stack/cable_coil(get_turf(src), 5)
	. = dismantle()

/obj/machinery/deconstructed(method)
	. = ..()
	// todo: get rid of this, legacy.
	on_deconstruction()

/obj/machinery/drop_products(method, atom/where)
	. = ..()
	if(isnull(circuit))
		return
	var/obj/structure/frame/A = new /obj/structure/frame(src.loc)
	var/obj/item/circuitboard/M = circuit
	A.circuit = M
	A.anchored = 1
	A.frame_type = M.board_type
	if(A.frame_type.circuit)
		A.need_circuit = 0

	if(A.frame_type.frame_class == FRAME_CLASS_ALARM || A.frame_type.frame_class == FRAME_CLASS_DISPLAY)
		A.density = 0
	else
		A.density = 1

	if(A.frame_type.frame_class == FRAME_CLASS_MACHINE)
		for(var/obj/D in component_parts)
			D.forceMove(src.loc)
		if(A.components)
			A.components.Cut()
		else
			A.components = list()
		component_parts = list()
		A.check_components()

	if(A.frame_type.frame_class == FRAME_CLASS_ALARM)
		A.state = FRAME_FASTENED
	else if(A.frame_type.frame_class == FRAME_CLASS_COMPUTER || A.frame_type.frame_class == FRAME_CLASS_DISPLAY)
		if(machine_stat & BROKEN)
			A.state = FRAME_WIRED
		else
			A.state = FRAME_PANELED
	else
		A.state = FRAME_WIRED

	A.setDir(dir)
	A.pixel_x = pixel_x
	A.pixel_y = pixel_y
	A.update_desc()
	A.update_appearance()
	M.loc = null
	M.after_deconstruct(src)

// todo: kill this shit, this is legacy
/obj/machinery/proc/dismantle()
	deconstruct(ATOM_DECONSTRUCT_DISASSEMBLED)

//called on machinery construction (i.e from frame to machinery) but not on initialization
// /obj/machinery/proc/on_construction() //! Not used yet.
// 	return

//called on deconstruction before the final deletion
/obj/machinery/proc/on_deconstruction()
	return

/**
 * Puts passed object in to user's hand
 *
 * Puts the passed object in to the users hand if they are adjacent.
 * If the user is not adjacent then place the object on top of the machine.
 *
 * Vars:
 * * object (obj) The object to be moved in to the users hand.
 * * user (mob/living) The user to recive the object
 */
/obj/machinery/proc/try_put_in_hand(obj/object, mob/living/user)
	if(!issilicon(user) && in_range(src, user))
		user.grab_item_from_interacted_with(object, src)
		// todo: probably split this proc into something that isn't try
		// because if this fails and something nulls, something bad happens
		// i bandaided this to drop location but that's inflexible
	else
		object.forceMove(drop_location())

/// Adjust item drop location to a 3x3 grid inside the tile, returns slot id from 0 to 8.
/obj/machinery/proc/adjust_item_drop_location(atom/movable/dropped_atom)
	var/md5 = md5(dropped_atom.name) // Oh, and it's deterministic too. A specific item will always drop from the same slot.
	for (var/i in 1 to 32)
		. += hex2num(md5[i])
	. = . % 9
	dropped_atom.pixel_x = -8 + ((.%3)*8)
	dropped_atom.pixel_y = -8 + (round( . / 3)*8)

/obj/machinery/atom_break()
	. = ..()
	// todo: rework
	machine_stat |= BROKEN

/obj/machinery/atom_fix()
	. = ..()
	// todo: rework
	machine_stat &= ~BROKEN
