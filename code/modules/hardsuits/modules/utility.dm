/* Contains:
 * /obj/item/hardsuit_module/device
 * /obj/item/hardsuit_module/device/plasmacutter
 * /obj/item/hardsuit_module/device/healthscanner
 * /obj/item/hardsuit_module/device/drill
 * /obj/item/hardsuit_module/device/orescanner
 * /obj/item/hardsuit_module/device/rcd
 * /obj/item/hardsuit_module/device/anomaly_scanner
 * /obj/item/hardsuit_module/maneuvering_jets
 * /obj/item/hardsuit_module/foam_sprayer
 * /obj/item/hardsuit_module/device/broadcaster
 * /obj/item/hardsuit_module/chem_dispenser
 * /obj/item/hardsuit_module/chem_dispenser/injector
 * /obj/item/hardsuit_module/voice
 * /obj/item/hardsuit_module/device/paperdispenser
 * /obj/item/hardsuit_module/device/pen
 * /obj/item/hardsuit_module/device/stamp
 * /obj/item/hardsuit_module/mop
 * /obj/item/hardsuit_module/cleaner_launcher
 * /obj/item/hardsuit_module/device/hand_defib
 */

/obj/item/hardsuit_module/device
	name = "mounted device"
	desc = "Some kind of hardsuit mount."
	usable = 0
	selectable = 1
	toggleable = 0
	disruptive = 0

	var/device_type
	var/obj/item/device

/obj/item/hardsuit_module/device/plasmacutter
	name = "hardsuit plasma cutter"
	desc = "A lethal-looking industrial cutter."
	icon_state = "plasmacutter"
	interface_name = "plasma cutter"
	interface_desc = "A self-sustaining plasma arc capable of cutting through walls."
	suit_overlay_active = "plasmacutter"
	suit_overlay_inactive = "plasmacutter"
	use_power_cost = 0.01
	module_cooldown = 0.5

	device_type = /obj/item/pickaxe/plasmacutter

/obj/item/hardsuit_module/device/healthscanner
	name = "health scanner module"
	desc = "A hardsuit-mounted health scanner."
	icon_state = "scanner"
	interface_name = "health scanner"
	interface_desc = "Shows an informative health readout when used on a subject."

	device_type = /obj/item/healthanalyzer

/obj/item/hardsuit_module/device/drill
	name = "hardsuit drill mount"
	desc = "A very heavy diamond-tipped drill."
	icon_state = "drill"
	interface_name = "mounted drill"
	interface_desc = "A diamond-tipped industrial drill."
	suit_overlay_active = "mounted-drill"
	suit_overlay_inactive = "mounted-drill"
	use_power_cost = 0.01
	module_cooldown = 0.5

	device_type = /obj/item/pickaxe/diamonddrill

/obj/item/hardsuit_module/device/anomaly_scanner
	name = "hardsuit anomaly scanner"
	desc = "You think it's called an Elder Sarsparilla or something."
	icon_state = "eldersasparilla"
	interface_name = "Alden-Saraspova counter"
	interface_desc = "An exotic particle detector commonly used by xenoarchaeologists."
	engage_string = "Begin Scan"
	usable = 1
	selectable = 0
	device_type = /obj/item/ano_scanner

/obj/item/hardsuit_module/device/orescanner
	name = "ore scanner module"
	desc = "A clunky old ore scanner."
	icon_state = "scanner"
	interface_name = "ore detector"
	interface_desc = "A sonar system for detecting large masses of ore."
	engage_string = "Begin Scan"
	usable = 1
	selectable = 0
	device_type = /obj/item/mining_scanner

/obj/item/hardsuit_module/device/orescanner/advanced
	name = "advanced ore scanner module"
	desc = "A sleeker, yet still somewhat clunky ore scanner."
	interface_name = "adv. ore detector"
	device_type = /obj/item/mining_scanner/advanced

/obj/item/hardsuit_module/device/rcd
	name = "RCD mount"
	desc = "A cell-powered rapid construction device for a hardsuit."
	icon_state = "rcd"
	interface_name = "mounted RCD"
	interface_desc = "A device for building or removing walls. Cell-powered."
	usable = 1
	engage_string = "Configure RCD"

	device_type = /obj/item/rcd/electric/mounted/hardsuit

/obj/item/hardsuit_module/device/Initialize(mapload)
	. = ..()
	if(device_type) device = new device_type(src)

/obj/item/hardsuit_module/device/engage(atom/target)
	if(!..() || !device)
		return 0

	if(!target)
		device.attack_self(holder.wearer)
		return 1

	var/turf/T = get_turf(target)
	if(istype(T) && !T.Adjacent(get_turf(src)))
		return 0

	device.melee_interaction_chain(target, holder.wearer, CLICKCHAIN_HAS_PROXIMITY)
	return 1

/obj/item/hardsuit_module/chem_dispenser
	name = "mounted chemical dispenser"
	desc = "A complex web of tubing and needles suitable for hardsuit use."
	icon_state = "injector"
	usable = 1
	selectable = 0
	toggleable = 0
	disruptive = 0

	engage_string = "Inject"

	interface_name = "integrated chemical dispenser"
	interface_desc = "Dispenses loaded chemicals directly into the wearer's bloodstream."

	charges = list(
		list("tricordrazine", "tricordrazine", 0, 80),
		list("tramadol",      "tramadol",      0, 80),
		list("dexalin plus",  "dexalinp",      0, 80),
		list("antibiotics",   "spaceacillin",  0, 80),
		list("antitoxins",    "anti_toxin",    0, 80),
		list("nutrients",     "glucose",     0, 80),
		list("hyronalin",     "hyronalin",     0, 80),
		list("radium",        "radium",        0, 80)
		)

	var/max_reagent_volume = 80 //Used when refilling.

/obj/item/hardsuit_module/chem_dispenser/ninja
	interface_desc = "Dispenses loaded chemicals directly into the wearer's bloodstream. This variant is made to be extremely light and flexible."

	//Want more? Go refill. Gives the ninja another reason to have to show their face.
	charges = list(
		list("tricordrazine", "tricordrazine", 0, 30),
		list("tramadol",      "tramadol",      0, 30),
		list("dexalin plus",  "dexalinp",      0, 30),
		list("antibiotics",   "spaceacillin",  0, 30),
		list("antitoxins",    "anti_toxin",    0, 60),
		list("nutrients",     "glucose",       0, 80),
		list("bicaridine",	  "bicaridine",    0, 30),
		list("clotting agent", "myelamine",    0, 30),
		list("peridaxon",     "peridaxon",     0, 30),
		list("hyronalin",     "hyronalin",     0, 30),
		list("radium",        "radium",        0, 30)
		)

/obj/item/hardsuit_module/chem_dispenser/accepts_item(var/obj/item/input_item, var/mob/living/user)

	if(!input_item.is_open_container())
		return 0

	if(!input_item.reagents || !input_item.reagents.total_volume)
		to_chat(user, "\The [input_item] is empty.")
		return 0

	// Magical chemical filtration system, do not question it.
	var/total_transferred = 0
	for(var/datum/reagent/R in input_item.reagents.get_reagent_datums())
		for(var/chargetype in charges)
			var/datum/rig_charge/charge = charges[chargetype]
			if(charge.display_name == R.id)

				var/chems_to_transfer = input_item.reagents.reagent_volumes[R.id]

				if((charge.charges + chems_to_transfer) > max_reagent_volume)
					chems_to_transfer = max_reagent_volume - charge.charges

				charge.charges += chems_to_transfer
				input_item.reagents.remove_reagent(R.id, chems_to_transfer)
				total_transferred += chems_to_transfer
				break

	if(total_transferred)
		to_chat(user, "<font color=#4F49AF>You transfer [total_transferred] units into the suit reservoir.</font>")
	else
		to_chat(user, "<span class='danger'>None of the reagents seem suitable.</span>")
	return 1

/obj/item/hardsuit_module/chem_dispenser/engage(atom/target)

	if(!..())
		return 0

	var/mob/living/carbon/human/H = holder.wearer

	if(!charge_selected)
		to_chat(H, "<span class='danger'>You have not selected a chemical type.</span>")
		return 0

	var/datum/rig_charge/charge = charges[charge_selected]

	if(!charge)
		return 0

	var/chems_to_use = 10
	if(charge.charges <= 0)
		to_chat(H, "<span class='danger'>Insufficient chems!</span>")
		return 0
	else if(charge.charges < chems_to_use)
		chems_to_use = charge.charges

	var/mob/living/carbon/target_mob
	if(target)
		if(istype(target,/mob/living/carbon))
			target_mob = target
		else
			return 0
	else
		target_mob = H

	if(target_mob != H)
		to_chat(H, "<span class='danger'>You inject [target_mob] with [chems_to_use] unit\s of [charge.display_name].</span>")
	to_chat(target_mob, "<span class='danger'>You feel a rushing in your veins as [chems_to_use] unit\s of [charge.display_name] [chems_to_use == 1 ? "is" : "are"] injected.</span>")
	target_mob.reagents.add_reagent(charge.display_name, chems_to_use)

	charge.charges -= chems_to_use
	if(charge.charges < 0) charge.charges = 0

	return 1

/obj/item/hardsuit_module/chem_dispenser/combat

	name = "combat chemical injector"
	desc = "A complex web of tubing and needles suitable for hardsuit use."

	charges = list(
		list("synaptizine",   "synaptizine",   0, 30),
		list("hyperzine",     "hyperzine",     0, 30),
		list("oxycodone",     "oxycodone",     0, 30),
		list("nutrients",     "glucose",     0, 80),
		list("clotting agent", "myelamine", 0, 80)
		)

	interface_name = "combat chem dispenser"
	interface_desc = "Dispenses loaded chemicals directly into the bloodstream."


/obj/item/hardsuit_module/chem_dispenser/injector

	name = "mounted chemical injector"
	desc = "A complex web of tubing and a large needle suitable for hardsuit use."
	usable = 0
	selectable = 1
	disruptive = 1

	interface_name = "mounted chem injector"
	interface_desc = "Dispenses loaded chemicals via an arm-mounted injector."

/obj/item/hardsuit_module/chem_dispenser/injector/advanced

	charges = list(
		list("tricordrazine", "tricordrazine", 0, 80),
		list("tramadol",      "tramadol",      0, 80),
		list("dexalin plus",  "dexalinp",      0, 80),
		list("antibiotics",   "spaceacillin",  0, 80),
		list("antitoxins",    "anti_toxin",    0, 80),
		list("nutrients",     "glucose",     0, 80),
		list("hyronalin",     "hyronalin",     0, 80),
		list("radium",        "radium",        0, 80),
		list("clotting agent", "myelamine", 0, 80)
		)

/obj/item/hardsuit_module/voice

	name = "hardsuit voice synthesizer"
	desc = "A speaker box and sound processor."
	icon_state = "megaphone"
	usable = 1
	selectable = 0
	toggleable = 0
	disruptive = 0

	engage_string = "Configure Synthesizer"

	interface_name = "voice synthesizer"
	interface_desc = "A flexible and powerful voice modulator system."

	var/obj/item/voice_changer/voice_holder

/obj/item/hardsuit_module/voice/Initialize(mapload)
	. = ..()
	voice_holder = new(src)
	voice_holder.active = 0

/obj/item/hardsuit_module/voice/installed()
	..()
	holder.speech = src

/obj/item/hardsuit_module/voice/engage()

	if(!..())
		return 0

	var/choice= input("Would you like to toggle the synthesizer or set the name?") as null|anything in list("Enable","Disable","Set Name")

	if(!choice)
		return 0

	switch(choice)
		if("Enable")
			active = 1
			voice_holder.active = 1
			to_chat(usr, "<font color=#4F49AF>You enable the speech synthesizer.</font>")
		if("Disable")
			active = 0
			voice_holder.active = 0
			to_chat(usr, "<font color=#4F49AF>You disable the speech synthesizer.</font>")
		if("Set Name")
			var/raw_choice = sanitize(input(usr, "Please enter a new name.")  as text|null, MAX_NAME_LEN)
			if(!raw_choice)
				return 0
			voice_holder.voice = raw_choice
			to_chat(usr, "<font color=#4F49AF>You are now mimicking <B>[voice_holder.voice]</B>.</font>")
	return 1

/obj/item/hardsuit_module/maneuvering_jets

	name = "hardsuit maneuvering jets"
	desc = "A compact gas thruster system for a hardsuit."
	icon_state = "thrusters"
	usable = 1
	toggleable = 1
	selectable = 0
	disruptive = 0

	suit_overlay_active = "maneuvering_active"
	suit_overlay_inactive = null //"maneuvering_inactive"

	engage_string = "Toggle Stabilizers"
	activate_string = "Activate Thrusters"
	deactivate_string = "Deactivate Thrusters"

	interface_name = "maneuvering jets"
	interface_desc = "An inbuilt EVA maneuvering system that runs off the hardsuit air supply."

	var/obj/item/tank/jetpack/hardsuit/jets

/obj/item/hardsuit_module/maneuvering_jets/engage()
	if(!..())
		return 0
	jets.toggle_rockets()
	return 1

/obj/item/hardsuit_module/maneuvering_jets/activate()

	if(active)
		return 0

	active = 1

	spawn(1)
		if(suit_overlay_active)
			suit_overlay = suit_overlay_active
		else
			suit_overlay = null
		holder.update_icon()

	if(!jets.on)
		jets.toggle()
	return 1

/obj/item/hardsuit_module/maneuvering_jets/deactivate()
	if(!..())
		return 0
	if(jets.on)
		jets.toggle()
	return 1

/obj/item/hardsuit_module/maneuvering_jets/Initialize(mapload)
	. = ..()
	jets = new(src)

/obj/item/hardsuit_module/maneuvering_jets/installed()
	..()
	jets.holder = holder
	jets.ion_trail.set_up(holder)

/obj/item/hardsuit_module/maneuvering_jets/removed()
	..()
	jets.holder = null
	jets.ion_trail.set_up(jets)

/obj/item/hardsuit_module/foam_sprayer


//Deployable Mop

/obj/item/hardsuit_module/mop

	name = "mop projector"
	desc = "A powerful mop projector."
	icon_state = "mop"

	activate_string = "Project Mop"
	deactivate_string = "Cancel Mop"

	interface_name = "mop projector"
	interface_desc = "A mop that can be deployed from the hand of the wearer."

	usable = 0
	selectable = 1
	toggleable = 1
	use_power_cost = 0
	active_power_cost = 0
	passive_power_cost = 0

/obj/item/hardsuit_module/mop/process(delta_time)

	if(holder && holder.wearer)
		if(!(locate(/obj/item/mop_deploy) in holder.wearer))
			deactivate()
			return 0

	return ..()

/obj/item/hardsuit_module/mop/activate()

	..()

	var/mob/living/M = holder.wearer

	if(M.are_usable_hands_full())
		to_chat(M, "<span class='danger'>Your hands are full.</span>")
		deactivate()
		return

	var/obj/item/mop_deploy/blade = new(M)
	blade.creator = M
	M.put_in_hands(blade)

/obj/item/hardsuit_module/mop/deactivate()

	..()

	var/mob/living/M = holder.wearer

	if(!M)
		return

	for(var/obj/item/mop_deploy/blade in M.contents)
		qdel(blade)


	//Space Cleaner Launcher

/obj/item/hardsuit_module/cleaner_launcher

	name = "mounted space cleaner launcher"
	desc = "A shoulder-mounted micro-cleaner dispenser."
	selectable = 1
	icon_state = "grenadelauncher"
	interface_name = "integrated cleaner launcher"
	interface_desc = "Discharges loaded cleaner grenades against the wearer's location."

	var/fire_force = 30
	var/fire_distance = 10

	charges = list(
		list("cleaner grenade",   "cleaner grenade",   /obj/item/grenade/simple/chemical/premade/cleaner,  9),
		)

/obj/item/hardsuit_module/cleaner_launcher/accepts_item(var/obj/item/input_device, var/mob/living/user)

	if(!istype(input_device) || !istype(user))
		return 0

	var/datum/rig_charge/accepted_item
	for(var/charge in charges)
		var/datum/rig_charge/charge_datum = charges[charge]
		if(input_device.type == charge_datum.product_type)
			accepted_item = charge_datum
			break

	if(!accepted_item)
		return 0

	if(accepted_item.charges >= 5)
		to_chat(user, "<span class='danger'>Another grenade of that type will not fit into the module.</span>")
		return 0
	if(!user.attempt_consume_item_for_construction(input_device))
		return

	to_chat(user, "<font color=#4F49AF><b>You slot \the [input_device] into the suit module.</b></font>")
	accepted_item.charges++
	return 1

/obj/item/hardsuit_module/cleaner_launcher/engage(atom/target)

	if(!..())
		return 0

	if(!target)
		return 0

	var/mob/living/carbon/human/H = holder.wearer

	if(!charge_selected)
		to_chat(H, "<span class='danger'>You have not selected a grenade type.</span>")
		return 0

	var/datum/rig_charge/charge = charges[charge_selected]

	if(!charge)
		return 0

	if(charge.charges <= 0)
		to_chat(H, "<span class='danger'>Insufficient grenades!</span>")
		return 0

	charge.charges--
	var/obj/item/grenade/new_grenade = new charge.product_type(get_turf(H))
	H.visible_message("<span class='danger'>[H] launches \a [new_grenade]!</span>")
	new_grenade.activate(new /datum/event_args/actor(H))
	new_grenade.throw_at_old(target,fire_force,fire_distance)

/obj/item/hardsuit_module/device/paperdispenser
	name = "hardsuit paper dispenser"
	desc = "Crisp sheets."
	icon_state = "paper"
	interface_name = "paper dispenser"
	interface_desc = "Dispenses warm, clean, and crisp sheets of paper."
	engage_string = "Dispense"
	usable = 1
	selectable = 0
	device_type = /obj/item/paper_bin

/obj/item/hardsuit_module/device/paperdispenser/engage(atom/target)

	if(!..() || !device)
		return 0

	if(!target)
		device.attack_hand(holder.wearer)
		return 1

/obj/item/hardsuit_module/device/pen
	name = "mounted pen"
	desc = "For mecha John Hancocks."
	icon_state = "pen"
	interface_name = "mounted pen"
	interface_desc = "Signatures with style(tm)."
	engage_string = "Change color"
	usable = 1
	device_type = /obj/item/pen/multi

/obj/item/hardsuit_module/device/stamp
	name = "mounted internal affairs stamp"
	desc = "DENIED."
	icon_state = "stamp"
	interface_name = "mounted stamp"
	interface_desc = "Leave your mark."
	engage_string = "Toggle stamp type"
	usable = 1
	var/iastamp
	var/deniedstamp

/obj/item/hardsuit_module/device/stamp/Initialize(mapload)
	. = ..()
	iastamp = new /obj/item/stamp/internalaffairs(src)
	deniedstamp = new /obj/item/stamp/denied(src)
	device = iastamp

/obj/item/hardsuit_module/device/stamp/engage(atom/target)
	if(!..() || !device)
		return 0

	if(!target)
		if(device == iastamp)
			device = deniedstamp
			to_chat(holder.wearer, "<span class='notice'>Switched to denied stamp.</span>")
		else if(device == deniedstamp)
			device = iastamp
			to_chat(holder.wearer, "<span class='notice'>Switched to internal affairs stamp.</span>")
		return 1

/obj/item/hardsuit_module/sprinter
	name = "sprint module"
	desc = "A robust hardsuit-integrated sprint module."
	icon_state = "sprinter"

	var/sprint_speed = 1

	toggleable = 1
	disruptable = 1
	disruptive = 0

	use_power_cost = 0
	active_power_cost = 5
	passive_power_cost = 0
	module_cooldown = 30

	activate_string = "Enable Sprint"
	deactivate_string = "Disable Sprint"

	interface_name = "sprint system"
	interface_desc = "Increases power to the suit's actuators, allowing faster movement."

/obj/item/hardsuit_module/sprinter/activate()

	if(!..())
		return 0

	var/mob/living/carbon/human/H = holder.wearer

	to_chat(H, "<font color=#4F49AF><b>You activate the suit's sprint mode.</b></font>")

	holder.set_slowdown(holder.slowdown - sprint_speed)
	holder.sprint_slowdown_modifier = -sprint_speed

/obj/item/hardsuit_module/sprinter/deactivate()

	if(!..())
		return 0

	var/mob/living/carbon/human/H = holder.wearer

	to_chat(H, "<span class='danger'>Your hardsuit returns to normal speed.</span>")

	holder.set_slowdown(holder.slowdown + sprint_speed)
	holder.sprint_slowdown_modifier = 0

/obj/item/hardsuit_module/device/hand_defib
	name = "\improper Hand-mounted Defibrillator"
	desc = "Following complaints regarding the danger of switching equipment in the field, Vey-Med developed internalised defibrillator paddles mounted in the gauntlets of the rescue suit powered by the suit's cell."

	use_power_cost = 50

	interface_name = "Hand-mounted Defbrillators"
	interface_desc = "Following complaints regarding the danger of switching equipment in the field, Vey-Med developed internalised defibrillator paddles mounted in the gauntlets of the rescue suit powered by the suit's cell."

	device_type = /obj/item/shockpaddles/standalone/hardsuit

/obj/item/hardsuit_module/device/toolset
	name = "integrated toolset"
	desc = "A set of actuators and toolheads for use in hardsuit-based toolsets."
	icon_state = "stamp"
	interface_name = "integrated toolset"
	interface_desc = "The power of engineering, in the palm of your hand."
	engage_string = "Switch tool type"
	usable = 1
	module_cooldown = 0
	var/intcrowbar
	var/intwrench
	var/intcutter
	var/intdriver

/obj/item/hardsuit_module/device/toolset/Initialize(mapload)
	. = ..()
	intcrowbar = new /obj/item/tool/crowbar/RIGset(src)
	intwrench = new /obj/item/tool/wrench/RIGset(src)
	intcutter = new /obj/item/tool/wirecutters/RIGset(src)
	intdriver = new /obj/item/tool/screwdriver/RIGset(src)
	//intwelder = new /obj/item/weldingtool/electric/mounted/RIGset(src)
	device = intcrowbar

/obj/item/hardsuit_module/device/toolset/engage(atom/target)
	if(!..() || !device)
		return 0

	if(!target)
		if(device == intcrowbar)
			device = intwrench
			to_chat(holder.wearer, "<span class='notice'>Hydraulic wrench engaged.</span>")
		else if(device == intwrench)
			device = intcutter
			to_chat(holder.wearer, "<span class='notice'>Hydraulic cutters engaged.</span>")
		else if(device == intcutter)
			device = intdriver
			to_chat(holder.wearer, "<span class='notice'>Hydraulic driver engaged.</span>")
		else if(device == intdriver) // I'm tired and can't think of anything better
			device = intcrowbar // Feel free to improve this mess
			to_chat(holder.wearer, "<span class='notice'>Hydraulic crowbar engaged.</span>")
	interface_name = "[initial(interface_name)] - [device]"
	return 1

/obj/item/hardsuit_module/device/rigwelder
	name = "integrated arc-welder"
	desc = "A set of tubes and canisters to be attached to a hardsuit."
	module_cooldown = 0
	usable = 1
	interface_name = "Integrated arc-welder"
	interface_desc = "A hardsuit-mounted electrical welder. Smells of ozone."
	engage_string = "Engage/Disengage"
	device_type = /obj/item/weldingtool/electric/mounted/RIGset
