/datum/category_item/catalogue/fauna/spiderbot
	name = "Spiderbot"
	desc = "A roaming curiosity, spiderbots are as harmless as \
	they are visually frightening. Generally friendly, the intelligence \
	piloting a spiderbot is usually still fully cognizant, and benign."
	value = CATALOGUER_REWARD_EASY

/mob/living/simple_mob/spiderbot
	name = "spider-bot"
	desc = "A skittering robotic friend!"
	tt_desc = "Maintenance Robot"
	icon = 'icons/mob/robots.dmi'
	icon_state = "spiderbot-chassis"
	icon_living = "spiderbot-chassis"
	icon_dead = "spiderbot-smashed"
	intelligence_level = SA_HUMANOID // Because its piloted by players.
	catalogue_data = list(/datum/category_item/catalogue/fauna/spiderbot)

	health = 10
	maxHealth = 10

	wander = 0
	speed = -1                    //Spiderbots gotta go fast.
	pass_flags = ATOM_PASS_TABLE
	mob_size = MOB_SMALL

	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"

	legacy_melee_damage_lower = 1
	legacy_melee_damage_upper = 3
	attacktext = list("shocked")

	min_oxy = 0
	max_tox = 0
	max_co2 = 0
	minbodytemp = 0
	maxbodytemp = 500

	speak_chance = 1
	speak_emote = list("beeps","clicks","chirps")

	var/obj/item/radio/borg/radio = null
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/cell/cell = null
	var/obj/machinery/camera/camera = null
	var/obj/item/mmi/mmi = null
	var/list/req_access = list(ACCESS_SCIENCE_ROBOTICS) //Access needed to pop out the brain.
	var/positronic

	can_enter_vent_with = list(
	/obj/item/implant,
	/obj/item/radio/borg,
	/obj/item/holder,
	/obj/machinery/camera,
	/mob/living/simple_mob/animal/borer,
	/obj/item/mmi,
	)

	var/emagged = 0
	var/obj/item/held_item = null //Storage for single item they can hold.

/mob/living/simple_mob/spiderbot/Initialize(mapload)
	. = ..()
	add_language(LANGUAGE_GALCOM)
	default_language = RSlanguages.legacy_resolve_language_name(LANGUAGE_GALCOM)
	add_verb(src, /mob/living/proc/ventcrawl)
	add_verb(src, /mob/living/proc/hide)

/mob/living/simple_mob/spiderbot/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if(istype(O, /obj/item/mmi))
		var/obj/item/mmi/B = O
		if(src.mmi)
			to_chat(user, "<span class='warning'>There's already a brain in [src]!</span>")
			return
		if(!B.brainmob)
			to_chat(user, "<span class='warning'>Sticking an empty MMI into the frame would sort of defeat the purpose.</span>")
			return
		if(!B.brainmob.key)
			var/ghost_can_reenter = 0
			if(B.brainmob.mind)
				for(var/mob/observer/dead/G in GLOB.player_list)
					if(G.can_reenter_corpse && G.mind == B.brainmob.mind)
						ghost_can_reenter = 1
						break
			if(!ghost_can_reenter)
				to_chat(user, "<span class='notice'>[O] is completely unresponsive; there's no point.</span>")
				return

		if(B.brainmob.stat == DEAD)
			to_chat(user, "<span class='warning'>[O] is dead. Sticking it into the frame would sort of defeat the purpose.</span>")
			return

		if(jobban_isbanned(B.brainmob, "Cyborg"))
			to_chat(user, "<span class='warning'>\The [O] does not seem to fit.</span>")
			return

		to_chat(user, "<span class='notice'>You install \the [O] in \the [src]!</span>")

		if(istype(O, /obj/item/mmi/digital))
			positronic = 1
			add_language("Robot Talk")

		user.drop_item()
		src.mmi = O
		src.transfer_personality(O)

		O.forceMove(src)
		src.update_icon()
		return 1

	if (istype(O, /obj/item/weldingtool))
		var/obj/item/weldingtool/WT = O
		if (WT.remove_fuel(0))
			if(health < getMaxHealth())
				health += pick(1,1,1,2,2,3)
				if(health > getMaxHealth())
					health = getMaxHealth()
				add_fingerprint(user)
				src.visible_message("<span class='notice'>\The [user] has spot-welded some of the damage to \the [src]!</span>")
			else
				to_chat(user, "<span class='warning'>\The [src] is undamaged!</span>")
		else
			to_chat(user, "<span class='danger'>You need more welding fuel for this task!</span>")
			return
	else if(istype(O, /obj/item/card/id)||istype(O, /obj/item/pda))
		if (!mmi)
			to_chat(user, "<span class='danger'>There's no reason to swipe your ID - \the [src] has no brain to remove.</span>")
			return 0

		var/obj/item/card/id/id_card

		if(istype(O, /obj/item/card/id))
			id_card = O
		else
			var/obj/item/pda/pda = O
			id_card = pda.id

		if(ACCESS_SCIENCE_ROBOTICS in id_card.access)
			to_chat(user, "<span class='notice'>You swipe your access card and pop the brain out of \the [src].</span>")
			eject_brain()
			if(held_item)
				held_item.forceMove(src.loc)
				held_item = null
			return 1
		else
			to_chat(user, "<span class='danger'>You swipe your card with no effect.</span>")
			return 0

	else
		O.melee_interaction_chain(src, user, user.zone_sel.selecting)

/mob/living/simple_mob/spiderbot/emag_act(var/remaining_charges, var/mob/user)
	if (emagged)
		to_chat(user, "<span class='warning'>[src] is already overloaded - better run.</span>")
		return 0
	else
		to_chat(user, "<span class='notice'>You short out the security protocols and overload [src]'s cell, priming it to explode in a short time.</span>")
		spawn(100)
			to_chat(src, "<span class='danger'>Your cell seems to be outputting a lot of power...</span>")
		spawn(200)
			to_chat(src, "<span class='danger'>Internal heat sensors are spiking! Something is badly wrong with your cell!</span>")
		spawn(300)	src.explode()

/mob/living/simple_mob/spiderbot/proc/transfer_personality(var/obj/item/mmi/M as obj)

		src.mind = M.brainmob.mind
		src.mind.key = M.brainmob.key
		set_ckey(M.brainmob.ckey)
		src.name = "spider-bot ([M.brainmob.name])"
		src.languages = M.brainmob.languages

/mob/living/simple_mob/spiderbot/proc/explode() //When emagged.
	src.visible_message("<span class='danger'>\The [src] makes an odd warbling noise, fizzles, and explodes!</span>")
	explosion(get_turf(loc), -1, -1, 3, 5)
	eject_brain()
	death()

/mob/living/simple_mob/spiderbot/update_icon()
	if(mmi)
		if(positronic)
			icon_state = "spiderbot-chassis-posi"
			icon_living = "spiderbot-chassis-posi"
		else
			icon_state = "spiderbot-chassis-mmi"
			icon_living = "spiderbot-chassis-mmi"
	else
		icon_state = "spiderbot-chassis"
		icon_living = "spiderbot-chassis"

/mob/living/simple_mob/spiderbot/proc/eject_brain()
	if(mmi)
		var/turf/T = get_turf(loc)
		if(T)
			mmi.forceMove(T)
		if(mind)	mind.transfer(mmi.brainmob)
		mmi = null
		real_name = initial(real_name)
		name = real_name
		update_icon()
	remove_language("Robot Talk")
	positronic = null

/mob/living/simple_mob/spiderbot/Destroy()
	eject_brain()
	..()

/mob/living/simple_mob/spiderbot/Initialize(mapload)
	. = ..()
	radio = new /obj/item/radio/borg(src)
	camera = new /obj/machinery/camera(src)
	camera.c_tag = "spiderbot-[real_name]"
	camera.replace_networks(list("SS13"))

/mob/living/simple_mob/spiderbot/death()

	living_mob_list -= src
	dead_mob_list += src

	if(camera)
		camera.status = 0

	held_item.forceMove(src.loc)
	held_item = null

	gibs(loc, null, null, /obj/effect/gibspawner/robot) //TODO: use gib() or refactor spiderbots into synthetics.
	qdel(src)
	return

//Cannibalized from the parrot mob. ~Zuhayr
/mob/living/simple_mob/spiderbot/verb/drop_held_item()
	set name = "Drop held item"
	set category = "Spiderbot"
	set desc = "Drop the item you're holding."

	if(stat)
		return

	if(!held_item)
		to_chat(usr, "<font color='red'>You have nothing to drop!</font>")
		return 0

	if(istype(held_item, /obj/item/grenade))
		visible_message("<span class='danger'>\The [src] launches \the [held_item]!</span>", \
			"<span class='danger'>You launch \the [held_item]!</span>", \
			"You hear a skittering noise and a thump!")
		var/obj/item/grenade/G = held_item
		G.forceMove(src.loc)
		G.detonate()
		held_item = null
		return 1

	visible_message("<span class='notice'>\The [src] drops \the [held_item].</span>", \
		"<span class='notice'>You drop \the [held_item].</span>", \
		"You hear a skittering noise and a soft thump.")

	held_item.forceMove(src.loc)
	held_item = null
	return 1

	return

/mob/living/simple_mob/spiderbot/verb/get_item()
	set name = "Pick up item"
	set category = "Spiderbot"
	set desc = "Allows you to take a nearby small item."

	if(stat)
		return -1

	if(held_item)
		to_chat(src, "<span class='warning'>You are already holding \the [held_item]</span>")
		return 1

	var/list/items = list()
	for(var/obj/item/I in view(1,src))
		if(I.loc != src && I.w_class <= WEIGHT_CLASS_SMALL && I.Adjacent(src) )
			items.Add(I)

	var/obj/selection = input("Select an item.", "Pickup") in items

	if(selection)
		for(var/obj/item/I in view(1, src))
			if(selection == I)
				held_item = selection
				selection.forceMove(src)
				visible_message("<span class='notice'>\The [src] scoops up \the [held_item].</span>", \
					"<span class='notice'>You grab \the [held_item].</span>", \
					"You hear a skittering noise and a clink.")
				return held_item
		to_chat(src, "<span class='warning'>\The [selection] is too far away.</span>")
		return 0

	to_chat(src, "<span class='warning'>There is nothing of interest to take.</span>")
	return 0

/mob/living/simple_mob/spiderbot/examine(mob/user, dist)
	. = ..()
	if(src.held_item)
		. += "It is carrying [icon2html(thing = src, target = world)] \a [src.held_item]."

/mob/living/simple_mob/spiderbot/cannot_use_vents()
	return

/mob/living/simple_mob/spiderbot/binarycheck()
	return positronic
