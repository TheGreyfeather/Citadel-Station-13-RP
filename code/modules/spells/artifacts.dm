//////////////////////Scrying orb//////////////////////

/obj/item/scrying
	name = "scrying orb"
	desc = "An incandescent orb of otherworldly energy, staring into it gives you vision beyond mortal means."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bluespace"
	throw_speed = 3
	throw_range = 7
	throw_force = 10
	damage_type = DAMAGE_TYPE_BURN
	damage_force = 10
	attack_sound = 'sound/items/welder2.ogg'

/obj/item/scrying/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if((user.mind && !wizards.is_antagonist(user.mind)))
		to_chat(user, "<span class='warning'>You stare into the orb and see nothing but your own reflection.</span>")
		return

	to_chat(user, "<span class='info'>You can see... everything!</span>")
	visible_message("<span class='danger'>[user] stares into [src], their eyes glazing over.</span>")

	user.teleop = user.ghostize(1)
	announce_ghost_joinleave(user.teleop, 1, "You feel that they used a powerful artifact to [pick("invade","disturb","disrupt","infest","taint","spoil","blight")] this place with their presence.")
	return

///////////////////////////Veil Render//////////////////////
/*
/obj/item/veilrender
	name = "veil render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast city."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "knife"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	damage_force = 15
	throw_force = 10
	w_class = WEIGHT_CLASS_NORMAL
	attack_sound = 'sound/weapons/bladeslice.ogg'
	var/charges = 1
	var/spawn_type = /obj/singularity/wizard
	var/spawn_amt = 1
	var/activate_descriptor = "reality"
	var/rend_desc = "You should run now."
	var/spawn_fast = 0 //if 1, ignores checking for mobs on loc before spawning

/obj/item/veilrender/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(charges > 0)
		new /obj/effect/rend(get_turf(user), spawn_type, spawn_amt, rend_desc, spawn_fast)
		charges--
		user.visible_message("<span class='boldannounce'>[src] hums with power as [user] deals a blow to [activate_descriptor] itself!</span>")
	else
		to_chat(user, "<span class='danger'>The unearthly energies that powered the blade are now dormant.</span>")

/obj/effect/rend
	name = "tear in the fabric of reality"
	desc = "You should run now."
	icon = 'icons/effects/effects.dmi'
	icon_state = "rift"
	density = TRUE
	anchored = TRUE
	var/spawn_path = /mob/living/simple_animal/cow //defaulty cows to prevent unintentional narsies
	var/spawn_amt_left = 20
	var/spawn_fast = 0

/obj/effect/rend/New(loc, var/spawn_type, var/spawn_amt, var/desc, var/spawn_fast)
	src.spawn_path = spawn_type
	src.spawn_amt_left = spawn_amt
	src.desc = desc
	src.spawn_fast = spawn_fast
	START_PROCESSING(SSobj, src)
	return

/obj/effect/rend/process(delta_time)
	if(!spawn_fast)
		if(locate(/mob) in loc)
			return
	new spawn_path(loc)
	spawn_amt_left--
	if(spawn_amt_left <= 0)
		qdel(src)

/obj/effect/rend/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/nullrod))
		user.visible_message("<span class='danger'>[user] seals \the [src] with \the [I].</span>")
		qdel(src)
		return
	else
		return ..()

/obj/effect/rend/singularity_pull()
	return

/obj/effect/rend/singularity_pull()
	return

/obj/item/veilrender/vealrender
	name = "veal render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast farm."
	spawn_type = /mob/living/simple_animal/cow
	spawn_amt = 20
	activate_descriptor = "hunger"
	rend_desc = "Reverberates with the sound of ten thousand moos."

/obj/item/veilrender/honkrender
	name = "honk render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast circus."
	spawn_type = /mob/living/simple_animal/hostile/retaliate/clown
	spawn_amt = 10
	activate_descriptor = "depression"
	rend_desc = "Gently wafting with the sounds of endless laughter."
	icon_state = "clownrender"

////TEAR IN REALITY

/obj/singularity/wizard
	name = "tear in the fabric of reality"
	desc = "This isn't right."
	icon = 'icons/effects/224x224.dmi'
	icon_state = "reality"
	pixel_x = -96
	pixel_y = -96
	dissipate = 0
	move_self = 0
	consume_range = 3
	grav_pull = 4
	current_size = STAGE_FOUR
	allowed_size = STAGE_FOUR

/obj/singularity/wizard/process(delta_time)
	move()
	eat()
	return

/obj/singularity/wizard/attack_tk(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/datum/component/mood/insaneinthemembrane = C.GetComponent(/datum/component/mood)
		if(insaneinthemembrane.sanity < 15)
			return //they've already seen it and are about to die, or are just too insane to care
		to_chat(C, "<span class='userdanger'>OH GOD! NONE OF IT IS REAL! NONE OF IT IS REEEEEEEEEEEEEEEEEEEEEEEEAL!</span>")
		insaneinthemembrane.sanity = 0
		for(var/lore in typesof(/datum/brain_trauma/severe))
			C.gain_trauma(lore)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/singularity/wizard, deranged), C), 100)

/obj/singularity/wizard/proc/deranged(mob/living/carbon/C)
	if(!C || C.stat == DEAD)
		return
	C.vomit(0, TRUE, TRUE, 3, TRUE)
	C.spew_organ(3, 2)
	C.death()

/obj/singularity/wizard/mapped/admin_investigate_setup()
	return
*/

//Need to add skeletons before this one works.
/////////////////////////////////////////Necromantic Stone///////////////////

/obj/item/necromantic_stone
	name = "necromantic stone"
	desc = "A shard capable of resurrecting humans as skeleton thralls."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "necrostone"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_TINY
	var/list/spooky_scaries = list()
	var/unlimited = 0

/obj/item/necromantic_stone/unlimited
	unlimited = 1

/obj/item/necromantic_stone/legacy_mob_melee_hook(mob/target, mob/user, clickchain_flags, list/params, mult, target_zone, intent)
	var/mob/living/carbon/human/H = target
	if(!istype(H))
		return ..()

	if(!istype(user))
		return

	if(H.stat != DEAD)
		to_chat(user, "<span class='warning'>This artifact can only affect the dead!</span>")
		return

	if(!H.mind || !H.client)
		to_chat(user, "<span class='warning'>There is no soul connected to this body...</span>")
		return

	check_spooky()//clean out/refresh the list
	if(spooky_scaries.len >= 3 && !unlimited)
		to_chat(user, "<span class='warning'>This artifact can only affect three undead at a time!</span>")
		return

	H.set_species(/datum/species/skeleton, regen_icons=0)
	H.revive(full_heal = TRUE)
	H.remove_all_restraints()
	spooky_scaries |= H
	to_chat(H, "<span class='userdanger'>You have been revived by </span><B>[user.real_name]!</B>")
	to_chat(H, "<span class='userdanger'>[user] is your master now, assist [user] them even if it costs you your new life!</span>")

	equip_roman_skeleton(H)

	desc = "A shard capable of resurrecting humans as skeleton thralls[unlimited ? "." : ", [spooky_scaries.len]/3 active thralls."]"

/obj/item/necromantic_stone/proc/check_spooky()
	if(unlimited) //no point, the list isn't used.
		return

	for(var/X in spooky_scaries)
		if(!ishuman(X))
			spooky_scaries.Remove(X)
			continue
		var/mob/living/carbon/human/H = X
		if(H.stat == DEAD)
			H.dust(TRUE)
			spooky_scaries.Remove(X)
			continue
	listclearnulls(spooky_scaries)

//Funny gimmick, skeletons always seem to wear roman/ancient armour
/obj/item/necromantic_stone/proc/equip_roman_skeleton(mob/living/carbon/human/H)
	for(var/obj/item/I in H)
		//H.dropItemtoGround(I) //Just gonna disable this until I figure out what it does.

	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/roman(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/roman(H), SLOT_ID_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(H), SLOT_FEET)
	H.put_in_hands(new /obj/item/shield/riot/roman(H), INV_OP_FORCE)
	H.put_in_hands(new /obj/item/material/sword(H), INV_OP_FORCE)
	H.equip_to_slot_or_del(new /obj/item/material/twohanded/spear(H), SLOT_BACK)

/*
//Gonna need some help with Voodoo.
/obj/item/voodoo
	name = "wicker doll"
	desc = "Something creepy about it."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "voodoo"
	item_state = "electronic"
	var/mob/living/carbon/human/target = null
	var/list/mob/living/carbon/human/possible
	var/obj/item/voodoo_link = null
	var/cooldown_time = 30 //3s
	var/cooldown = 0

/obj/item/voodoo/attackby(obj/item/I, mob/user, params)
	if(target && cooldown < world.time)
		if(I.get_temperature())
			to_chat(target, "<span class='userdanger'>You suddenly feel very hot</span>")
			target.adjust_bodytemperature(50)
			GiveHint(target)
		else if(I.get_sharpness())
			to_chat(target, "<span class='userdanger'>You feel a stabbing pain in [parse_zone(user.zone_selected)]!</span>")
			target.default_combat_knockdown(40)
			GiveHint(target)
		else if(istype(I, /obj/item/bikehorn))
			to_chat(target, "<span class='userdanger'>HONK</span>")
			SEND_SOUND(target, 'sound/items/airhorn.ogg')
			target.adjustEarDamage(0,3)
			GiveHint(target)
		cooldown = world.time +cooldown_time
		return

	if(!voodoo_link)
		if(I.loc == user && istype(I) && I.w_class <= WEIGHT_CLASS_SMALL)
			if (user.transferItemToLoc(I,src))
				voodoo_link = I
				to_chat(user, "You attach [I] to the doll.")
				update_targets()

/obj/item/voodoo/check_eye(mob/user)
	if(loc != user)
		user.reset_perspective(null)
		user.unset_machine()

/obj/item/voodoo/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(!target && length(possible))
		target = input(user, "Select your victim!", "Voodoo") as null|anything in possible
		return

	if(user.zone_selected == BP_TORSO)
		if(voodoo_link)
			target = null
			voodoo_link.forceMove(drop_location())
			to_chat(user, "<span class='notice'>You remove the [voodoo_link] from the doll.</span>")
			voodoo_link = null
			update_targets()
			return

	if(target && cooldown < world.time)
		switch(user.zone_selected)
			if(O_MOUTH)
				var/wgw =  sanitize(input(user, "What would you like the victim to say", "Voodoo", null)  as text)
				target.say(wgw, forced = "voodoo doll")
				log_game("[key_name(user)] made [key_name(target)] say [wgw] with a voodoo doll.")
			if(O_EYES)
				user.set_machine(src)
				user.reset_perspective(target)
				spawn(100)
					user.reset_perspective(null)
					user.unset_machine()
			if(BP_R_LEG,BP_L_LEG)
				to_chat(user, "<span class='notice'>You move the doll's legs around.</span>")
				var/turf/T = get_step(target,pick(GLOB.cardinals))
				target.Move(T)
			if(BP_R_ARM,BP_L_ARM)
				target.click_random_mob()
				GiveHint(target)
			if(BP_HEAD)
				to_chat(user, "<span class='notice'>You smack the doll's head with your hand.</span>")
				target.Dizzy(10)
				to_chat(target, "<span class='warning'>You suddenly feel as if your head was hit with a hammer!</span>")
				GiveHint(target,user)
		cooldown = world.time + cooldown_time

/obj/item/voodoo/proc/update_targets()
	possible = null
	if(!voodoo_link)
		return
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(md5(H.dna.uni_identity) in voodoo_link.fingerprints)

/obj/item/voodoo/proc/GiveHint(mob/victim,force=0)
	if(prob(50) || force)
		var/way = dir2text(get_dir(victim,get_turf(src)))
		to_chat(victim, "<span class='notice'>You feel a dark presence from [way]</span>")
	if(prob(20) || force)
		var/area/A = get_area(src)
		to_chat(victim, "<span class='notice'>You feel a dark presence from [A.name]</span>")

/obj/item/voodoo/fire_act(exposed_temperature, exposed_volume)
	if(target)
		target.adjust_fire_stacks(20)
		target.IgniteMob()
		GiveHint(target,1)
	return ..()

//Cursed Heart requires a bit more work in other organ .dms to function. Leaving untouched for now.

//Provides a decent heal, need to pump every 6 seconds
/obj/item/organ/heart/cursed/wizard
	click_delay = 60
	H.adjustBruteloss = -25
	H.adjustBurnloss = -25
	H.adjustOxyloss = -25

//Warp Whistle: Provides uncontrolled long distance teleportation. //Not even gonna start fucking with this one yet.

/obj/item/warpwhistle
	name = "warp whistle"
	desc = "One toot on this whistle will send you to a far away land!"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "whistle"
	var/on_cooldown = 0 //0: usable, 1: in use, 2: on cooldown
	var/mob/living/carbon/last_user

/obj/item/warpwhistle/proc/interrupted(mob/living/carbon/user)
	if(!user || QDELETED(src) || user.mob_transforming)
		on_cooldown = FALSE
		return TRUE
	return FALSE

/obj/item/warpwhistle/proc/end_effect(mob/living/carbon/user)
	user.invisibility = initial(user.invisibility)
	user.status_flags &= ~STATUS_GODMODE
	REMOVE_TRAIT(user, TRAIT_MOBILITY_NOMOVE, src)
	REMOVE_TRAIT(user, TRAIT_MOBILITY_NOUSE, src)
	REMOVE_TRAIT(user, TRAIT_MOBILITY_NOPICKUP, src)
	user.update_mobility_blocked()

/obj/item/warpwhistle/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(!istype(user) || on_cooldown)
		return
	var/turf/T = get_turf(user)
	var/area/A = get_area(user)
	if(!T || !A || A.noteleport)
		to_chat(user, "<span class='warning'>You play \the [src], yet no sound comes out of it... Looks like it won't work here.</span>")
		return
	on_cooldown = TRUE
	last_user = user
	playsound(T,'sound/magic/warpwhistle.ogg', 200, 1)
	ADD_TRAIT(user, TRAIT_MOBILITY_NOMOVE, src)
	ADD_TRAIT(user, TRAIT_MOBILITY_NOUSE, src)
	ADD_TRAIT(user, TRAIT_MOBILITY_NOPICKUP, src)
	user.update_mobility_blocked()
	new /obj/effect/temp_visual/tornado(T)
	sleep(20)
	if(interrupted(user))
		return
	user.invisibility = INVISIBILITY_MAXIMUM
	user.status_flags |= STATUS_GODMODE
	sleep(20)
	if(interrupted(user))
		end_effect(user)
		return
	var/breakout = 0
	while(breakout < 50)
		if(!T)
			end_effect(user)
			return
		var/turf/potential_T = find_safe_turf()
		if(!potential_T)
			end_effect(user)
			return
		if(T.z != potential_T.z || abs(get_dist_euclidian(potential_T,T)) > 50 - breakout)
			do_teleport(user, potential_T, channel = TELEPORT_CHANNEL_MAGIC)
			T = potential_T
			break
		breakout += 1
	new /obj/effect/temp_visual/tornado(T)
	sleep(20)
	end_effect(user)
	if(interrupted(user))
		return
	on_cooldown = 2
	sleep(40)
	on_cooldown = 0

/obj/item/warpwhistle/Destroy()
	if(on_cooldown == 1 && last_user) //Flute got dunked somewhere in the teleport
		end_effect(last_user)
	return ..()

/obj/effect/temp_visual/tornado
	icon = 'icons/obj/wizard.dmi'
	icon_state = "tornado"
	name = "tornado"
	desc = "This thing sucks!"
	layer = FLY_LAYER
	randomdir = 0
	duration = 40
	pixel_x = 500

/obj/effect/temp_visual/tornado/Initialize(mapload)
	. = ..()
	animate(src, pixel_x = -500, time = 40)
*/
