//Cloning revival method.
//The pod handles the actual cloning while the computer manages the clone profiles

//Potential replacement for genetics revives or something I dunno (?)

//Find a dead mob with a brain and client.
/proc/find_dead_player(var/find_key)
	if(isnull(find_key))
		return

	var/mob/selected = null
	for(var/mob/living/M in GLOB.player_list)
		//Dead people only thanks!
		if((M.stat != 2) || (!M.client))
			continue
		//They need a brain!
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(!H.has_brain())
				continue
		if(M.ckey == find_key)
			selected = M
			break
	return selected

#define CLONE_BIOMASS 30
/obj/machinery/clonepod
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/clonepod
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0"
	req_access = list(ACCESS_SCIENCE_GENETICS) // For premature unlocking.
	var/mob/living/occupant
	/// The clone is released once its health reaches this level.
	var/heal_level = 20
	var/heal_rate = 1
	var/locked = FALSE
	/// So we remember the connected clone machine.
	var/obj/machinery/computer/cloning/connected = null
	/// Need to clean out it if it's full of exploded clone.
	var/mess = FALSE
	/// One clone attempt at a time thanks.
	var/attempting = FALSE
	/// Don't eject them as soon as they are created.
	var/eject_wait = FALSE
	/// Beakers for our liquid biomass.
	var/list/containers = list()
	/// How many beakers can the machine hold?
	var/container_limit = 3

/obj/machinery/clonepod/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/clonepod/attack_ai(mob/user)

	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/clonepod/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if((isnull(occupant)) || (machine_stat & NOPOWER))
		return
	if((!isnull(occupant)) && (occupant.stat != 2))
		var/completion = (100 * ((occupant.health + 50) / (heal_level + 100))) // Clones start at -150 health
		to_chat(user, "Current clone cycle is [round(completion)]% complete.")
	return

/// Start growing a human clone in the pod!
/obj/machinery/clonepod/proc/growclone(var/datum/dna2/record/R)
	if(mess || attempting)
		return FALSE
	var/datum/mind/clonemind = locate(R.mind)

	if(!istype(clonemind, /datum/mind)) // Not a mind.
		return FALSE
	if(clonemind.current && clonemind.current.stat != DEAD) // Mind is associated with a non-dead body.
		return FALSE
	if(clonemind.active) // Somebody is using that mind.
		if(clonemind.ckey != R.ckey)
			return FALSE
	else
		for(var/mob/observer/dead/G in GLOB.player_list)
			if(G.ckey == R.ckey)
				if(G.can_reenter_corpse)
					break
				else
					return FALSE

	for(var/modifier_type in R.genetic_modifiers) // Can't be cloned, even if they had a previous scan
		if(istype(modifier_type, /datum/modifier/no_clone))
			return FALSE

	// Remove biomass when the cloning is started, rather than when the guy pops out
	remove_biomass(CLONE_BIOMASS)

	attempting = TRUE // One at a time!!
	locked = TRUE

	eject_wait = TRUE
	spawn(30)
		eject_wait = FALSE

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src, R.dna.species)
	occupant = H

	if(!R.dna.real_name) // To prevent null names
		R.dna.real_name = "clone ([rand(0,999)])"
	H.real_name = R.dna.real_name
	H.gender = R.gender
	H.descriptors = R.body_descriptors

	// Get the clone body ready
	H.adjustCloneLoss(150) // New damage var so you can't eject a clone early then stab them to abuse the current damage system --NeoFite
	H.afflict_unconscious(20 * 4)

	// Here let's calculate their health so the pod doesn't immediately eject them!!!
	H.update_health()

	clonemind.transfer(H)
	to_chat(H, SPAN_BOLDDANGER("Consciousness slowly creeps over you as your body regenerates.<br>") + SPAN_USERDANGER("Your recent memories are fuzzy, and it's hard to remember anything from today...<br>") + SPAN_NOTICE(SPAN_ROSE("So this is what cloning feels like?")))

	// -- Mode/mind specific stuff goes here
	callHook("clone", list(H))
	update_antag_icons(H.mind)
	// -- End mode specific stuff

	if(!R.dna)
		H.dna = new /datum/dna()
		H.dna.real_name = H.real_name
	else
		H.dna = R.dna
	H.UpdateAppearance()
	H.sync_organ_dna()
	if(heal_level < 60)
		randmutb(H) //Sometimes the clones come out wrong.
		H.dna.UpdateSE()
		H.dna.UpdateUI()

	H.set_cloned_appearance()
	update_icon()

	// A modifier is added which makes the new clone be unrobust.
	var/modifier_lower_bound = 25 MINUTES
	var/modifier_upper_bound = 40 MINUTES

	// Upgraded cloners can reduce the time of the modifier, up to 80%
	var/clone_sickness_length = abs(((heal_level - 20) / 100 ) - 1)
	clone_sickness_length = clamp( clone_sickness_length, 0.2,  1.0) // Caps it off just incase.
	modifier_lower_bound = round(modifier_lower_bound * clone_sickness_length, 1)
	modifier_upper_bound = round(modifier_upper_bound * clone_sickness_length, 1)

	H.add_modifier(H.species.cloning_modifier, rand(modifier_lower_bound, modifier_upper_bound))

	// Modifier that doesn't do anything.
	H.add_modifier(/datum/modifier/cloned)

	// This is really stupid.
	for(var/modifier_type in R.genetic_modifiers)
		H.add_modifier(modifier_type)

	for(var/datum/prototype/language/L in R.languages)
		H.add_language(L.name)

	H.flavor_texts = R.flavor.Copy()
	H.suiciding = 0
	attempting = 0
	return 1

/// Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/clonepod/process(delta_time)
	if(machine_stat & NOPOWER) // Autoeject if power is lost
		if(occupant)
			locked = 0
			go_out()
		return

	if((occupant) && (occupant.loc == src))
		if((occupant.stat == DEAD) || (occupant.suiciding) || !occupant.key)  //Autoeject corpses and suiciding dudes.
			locked = 0
			go_out()
			connected_message("Clone Rejected: Deceased.")
			return

		else if(occupant.health < heal_level && occupant.getCloneLoss() > 0)
			occupant.afflict_unconscious(20 * 4)

			 //Slowly get that clone healed and finished.
			occupant.adjustCloneLoss(-2 * heal_rate)

			//Premature clones may have brain damage.
			occupant.adjustBrainLoss(-(CEILING(0.5*heal_rate, 1)))

			//So clones don't die of oxyloss in a running pod.
			if(occupant.reagents.get_reagent_amount("inaprovaline") < 30)
				occupant.reagents.add_reagent("inaprovaline", 60)
			occupant.afflict_sleeping(20 * 30)
			//Also heal some oxyloss ourselves because inaprovaline is so bad at preventing it!!
			occupant.adjustOxyLoss(-4)

			use_power(7500) //This might need tweaking.
			return

		else if((occupant.health >= heal_level || occupant.health == occupant.getMaxHealth()) && (!eject_wait))
			playsound(src, 'sound/machines/medbayscanner1.ogg', 50, 1)
			audible_message("\The [src] signals that the cloning process is complete.")
			connected_message("Cloning Process Complete.")
			locked = 0
			go_out()
			return

	else if((!occupant) || (occupant.loc != src))
		occupant = null
		if(locked)
			locked = 0
		return

	return

//Let's unlock this early I guess.  Might be too early, needs tweaking.
/obj/machinery/clonepod/attackby(obj/item/W as obj, mob/user as mob)
	if(isnull(occupant))
		if(default_deconstruction_screwdriver(user, W))
			return
		if(default_deconstruction_crowbar(user, W))
			return
		if(default_part_replacement(user, W))
			return
	if(istype(W, /obj/item/card/id)||istype(W, /obj/item/pda))
		if(!check_access(W))
			to_chat(user, SPAN_WARNING("Access Denied."))
			return
		if((!locked) || (isnull(occupant)))
			return
		if((occupant.health < -20) && (occupant.stat != 2))
			to_chat(user, SPAN_WARNING("Access Refused."))
			return
		else
			locked = FALSE
			to_chat(user, "System unlocked.")
	else if(istype(W,/obj/item/reagent_containers/glass))
		if(LAZYLEN(containers) >= container_limit)
			to_chat(user, SPAN_WARNING("\The [src] has too many containers loaded!"))
		else if(do_after(user, 1 SECOND))
			if(!user.attempt_insert_item_for_installation(W, src))
				return
			user.visible_message("[user] has loaded \the [W] into \the [src].", "You load \the [W] into \the [src].")
			containers += W
		return
	else if(W.is_wrench())
		if(locked && (anchored || occupant))
			to_chat(user, SPAN_WARNING("Can not do that while [src] is in use."))
		else
			if(anchored)
				anchored = FALSE
				connected.pods -= src
				connected = null
			else
				anchored = TRUE
			playsound(src, W.tool_sound, 100, TRUE)
			if(anchored)
				user.visible_message("[user] secures [src] to the floor.", "You secure [src] to the floor.")
			else
				user.visible_message("[user] unsecures [src] from the floor.", "You unsecure [src] from the floor.")
	else if(istype(W, /obj/item/multitool))
		var/obj/item/multitool/M = W
		M.connecting = src
		to_chat(user, SPAN_NOTICE("You load connection data from [src] to [M]."))
		M.update_icon()
		return
	else
		..()

/obj/machinery/clonepod/emag_act(var/remaining_charges, var/mob/user)
	if(isnull(occupant))
		return
	to_chat(user, "You force an emergency ejection.")
	locked = 0
	go_out()
	return 1

/// Put messages in the connected computer's temp var for display.
/obj/machinery/clonepod/proc/connected_message(var/message)
	if((isnull(connected)) || (!istype(connected, /obj/machinery/computer/cloning)))
		return FALSE
	if(!message)
		return FALSE

	connected.temp = "[name] : [message]"
	connected.updateUsrDialog()
	return 1

/obj/machinery/clonepod/RefreshParts()
	..()
	var/rating = 0
	for(var/obj/item/stock_parts/P in component_parts)
		if(istype(P, /obj/item/stock_parts/scanning_module) || istype(P, /obj/item/stock_parts/manipulator))
			rating += P.rating

	heal_level = rating * 10 - 20
	heal_rate = round(rating / 4)

/obj/machinery/clonepod/verb/eject()
	set name = "Eject Cloner"
	set category = VERB_CATEGORY_OBJECT
	set src in oview(1)

	if(usr.stat != 0)
		return
	go_out()
	add_fingerprint(usr)
	return

/obj/machinery/clonepod/proc/go_out()
	if(locked)
		return

	if(mess) //Clean that mess and dump those gibs!
		mess = 0
		gibs(src.loc)
		update_icon()
		return

	if(!occupant)
		return

	occupant.forceMove(loc)
	occupant.update_perspective()

	eject_wait = 0 //If it's still set somehow.

	if(ishuman(occupant)) //Need to be safe.
		var/mob/living/carbon/human/patient = occupant
		if(!(patient.species.species_flags & NO_SCAN)) //If, for some reason, someone makes a genetically-unalterable clone, let's not make them permanently disabled.
			domutcheck(occupant) //Waiting until they're out before possible transforming.

	occupant = null

	update_icon()
	return

// Returns the total amount of biomass reagent in all of the pod's stored containers
/obj/machinery/clonepod/proc/get_biomass()
	var/biomass_count = 0
	for(var/obj/item/reagent_containers/container in containers)
		biomass_count += container.reagents?.reagent_volumes?[/datum/reagent/nutriment/biomass::id]
	return biomass_count

// Removes [amount] biomass, spread across all containers. Doesn't have any check that you actually HAVE enough biomass, though.
/obj/machinery/clonepod/proc/remove_biomass(amount = CLONE_BIOMASS)		//Just in case it doesn't get passed a new amount, assume one clone
	for(var/obj/item/reagent_containers/glass/beaker in containers)
		amount -= beaker.reagents.remove_reagent(/datum/reagent/nutriment/biomass, amount)
		if(!amount)
			return TRUE
	return !amount

// Empties all of the beakers from the cloning pod, used to refill it
/obj/machinery/clonepod/verb/empty_beakers()
	set name = "Eject Beakers"
	set category = VERB_CATEGORY_OBJECT
	set src in oview(1)

	if(usr.stat != 0)
		return

	add_fingerprint(usr)
	drop_beakers()
	return

// Actually does all of the beaker dropping
// Returns 1 if it succeeds, 0 if it fails. Added in case someone wants to add messages to the user.
/obj/machinery/clonepod/proc/drop_beakers()
	if(LAZYLEN(containers))
		var/turf/T = get_turf(src)
		if(T)
			for(var/obj/item/reagent_containers/glass/G in containers)
				G.forceMove(T)
				containers -= G
		return	1
	return 0

/obj/machinery/clonepod/proc/malfunction()
	if(occupant)
		connected_message("Critical Error!")
		mess = 1
		update_icon()
		occupant.ghostize()
		spawn(5)
			qdel(occupant)
	return

/obj/machinery/clonepod/relaymove(mob/user as mob)
	if(user.stat)
		return
	go_out()
	return

/obj/machinery/clonepod/emp_act(severity)
	if(prob(100/severity))
		malfunction()
	..()

/obj/machinery/clonepod/legacy_ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				legacy_ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					legacy_ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					legacy_ex_act(severity)
				qdel(src)
				return
		else
	return

/obj/machinery/clonepod/update_icon()
	..()
	icon_state = "pod_0"
	if(occupant && !(machine_stat & NOPOWER))
		icon_state = "pod_1"
	else if(mess)
		icon_state = "pod_g"


/obj/machinery/clonepod/full/Initialize(mapload, newdir)
	. = ..()
	for(var/i = 1 to container_limit)
		containers += new /obj/item/reagent_containers/glass/bottle/biomass(src)

/// Health Tracker Implant
/obj/item/implant/health
	name = "health implant"
	var/healthstring = ""

/obj/item/implant/health/proc/sensehealth()
	if(!implanted)
		return "ERROR"
	else
		if(isliving(implanted))
			var/mob/living/L = implanted
			healthstring = "[round(L.getOxyLoss())] - [round(L.getFireLoss())] - [round(L.getToxLoss())] - [round(L.getBruteLoss())]"
		if(!healthstring)
			healthstring = "ERROR"
		return healthstring

///Disk stuff.
///The return of data disks?? Just for transferring between genetics machine/cloning machine.
///TODO: Make the genetics machine accept them.
/obj/item/disk/data
	name = "Cloning Data Disk"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk0" //Gosh I hope syndies don't mistake them for the nuke disk.
	item_state = "card-id"
	w_class = WEIGHT_CLASS_SMALL
	var/datum/dna2/record/buf = null
	var/read_only = 0 //Well,it's still a floppy disk

/obj/item/disk/data/proc/initializeDisk()
	buf = new
	buf.dna=new

/obj/item/disk/data/demo
	name = "data disk - 'God Emperor of Mankind'"
	read_only = 1

/obj/item/disk/data/demo/Initialize(mapload)
	. = ..()
	initializeDisk()
	buf.types=DNA2_BUF_UE|DNA2_BUF_UI
	//data = "066000033000000000AF00330660FF4DB002690"
	//data = "0C80C80C80C80C80C8000000000000161FBDDEF" - Farmer Jeff
	buf.dna.real_name="God Emperor of Mankind"
	buf.dna.unique_enzymes = md5(buf.dna.real_name)
	buf.dna.UI=list(0x066,0x000,0x033,0x000,0x000,0x000,0xAF0,0x033,0x066,0x0FF,0x4DB,0x002,0x690)
	//buf.dna.UI=list(0x0C8,0x0C8,0x0C8,0x0C8,0x0C8,0x0C8,0x000,0x000,0x000,0x000,0x161,0xFBD,0xDEF) // Farmer Jeff
	buf.dna.UpdateUI()

/obj/item/disk/data/monkey
	name = "data disk - 'Mr. Muggles'"
	read_only = 1

/obj/item/disk/data/monkey/New()
	..()
	initializeDisk()
	buf.types=DNA2_BUF_SE
	var/list/new_SE=list(0x098,0x3E8,0x403,0x44C,0x39F,0x4B0,0x59D,0x514,0x5FC,0x578,0x5DC,0x640,0x6A4)
	for(var/i=new_SE.len;i<=DNA_SE_LENGTH;i++)
		new_SE += rand(1,1024)
	buf.dna.SE=new_SE
	buf.dna.SetSEValueRange(DNABLOCK_MONKEY,0xDAC, 0xFFF)

/obj/item/disk/data/Initialize(mapload)
	. = ..()
	var/diskcolor = pick(0,1,2)
	icon_state = "datadisk[diskcolor]"

/obj/item/disk/data/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	read_only = !read_only
	to_chat(user, "You flip the write-protect tab to [read_only ? "protected" : "unprotected"].")

/obj/item/disk/data/examine(mob/user, dist)
	. = ..()
	. += "<span class = 'notice'>The write-protect tab is set to [read_only ? "protected" : "unprotected"].</span>"

/*
 *	Diskette Box
 */

/obj/item/storage/box/disks
	name = "Diskette Box"
	icon_state = "disk_kit"

/obj/item/storage/box/disks/legacy_spawn_contents()
	new /obj/item/disk/data(src)
	new /obj/item/disk/data(src)
	new /obj/item/disk/data(src)
	new /obj/item/disk/data(src)
	new /obj/item/disk/data(src)
	new /obj/item/disk/data(src)
	new /obj/item/disk/data(src)

/*
 *	Manual -- A big ol' manual.
 */

/obj/item/paper/Cloning
	name = "H-87 Cloning Apparatus Manual"
	info = {"<h4>Getting Started</h4>
	Congratulations, your station has purchased the H-87 industrial cloning device!<br>
	Using the H-87 is almost as simple as brain surgery! Simply insert the target humanoid into the scanning chamber and select the scan option to create a new profile!<br>
	<b>That's all there is to it!</b><br>
	<i>Notice, cloning system cannot scan inorganic life or small primates.  Scan may fail if subject has suffered extreme brain damage.</i><br>
	<p>Clone profiles may be viewed through the profiles menu. Scanning implants a complementary HEALTH MONITOR IMPLANT into the subject, which may be viewed from each profile.
	Profile Deletion has been restricted to \[Station Head\] level access.</p>
	<h4>Cloning from a profile</h4>
	Cloning is as simple as pressing the CLONE option at the bottom of the desired profile.<br>
	Per your company's EMPLOYEE PRIVACY RIGHTS agreement, the H-87 has been blocked from cloning crewmembers while they are still alive.<br>
	<br>
	<p>The provided CLONEPOD SYSTEM will produce the desired clone.  Standard clone maturation times (With SPEEDCLONE technology) are roughly 90 seconds.
	The cloning pod may be unlocked early with any \[Medical Researcher\] ID after initial maturation is complete.</p><br>
	<i>Please note that resulting clones may have a small DEVELOPMENTAL DEFECT as a result of genetic drift.</i><br>
	<h4>Profile Management</h4>
	<p>The H-87 (as well as your station's standard genetics machine) can accept STANDARD DATA DISKETTES.
	These diskettes are used to transfer genetic information between machines and profiles.
	A load/save dialog will become available in each profile if a disk is inserted.</p><br>
	<i>A good diskette is a great way to counter aforementioned genetic drift!</i><br>
	<br>
	<font size=1>This technology produced under license from Thinktronic Systems, LTD.</font>"}

//SOME SCRAPS I GUESS
/* EMP grenade/spell effect
		if(istype(A, /obj/machinery/clonepod))
			A:malfunction()
*/
