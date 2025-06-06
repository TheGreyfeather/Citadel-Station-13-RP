/obj/item/forensics/swab
	name = "swab kit"
	desc = "A sterilized cotton swab and vial used to take forensic samples."
	icon_state = "swab"
	var/gsr = 0
	var/list/dna
	var/used
	drop_sound = 'sound/items/drop/glass.ogg'
	pickup_sound = 'sound/items/pickup/glass.ogg'

/obj/item/forensics/swab/proc/is_used()
	return used

/obj/item/forensics/swab/legacy_mob_melee_hook(mob/target, mob/user, clickchain_flags, list/params, mult, target_zone, intent)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(!ishuman(target))
		return ..()
	if(is_used())
		return

	var/mob/living/carbon/human/H = target
	var/sample_type

	. = CLICKCHAIN_DO_NOT_PROPAGATE
	if(user != H && H.a_intent != "help" && !H.lying)
		user.visible_message("<span class='danger'>\The [user] tries to take a swab sample from \the [H], but they move away.</span>")
		return

	if(user.zone_sel.selecting == O_MOUTH)
		if(!H.organs_by_name[BP_HEAD])
			to_chat(user, "<span class='warning'>They don't have a head.</span>")
			return

		if(H.wear_mask)
			to_chat(user, "<span class='warning'>Something is blocking \the [H]'s mouth.</span>")
			return

		if(!H.dna || !H.dna.unique_enzymes)
			to_chat(user, "<span class='warning'>They don't seem to have DNA!</span>")
			return

		if(!H.check_has_mouth())
			to_chat(user, "<span class='warning'>They don't have a mouth.</span>")
			return
		user.visible_message("[user] swabs \the [H]'s mouth for a saliva sample.")
		dna = list(H.dna.unique_enzymes)
		sample_type = "DNA"

	else if(user.zone_sel.selecting == BP_R_HAND || user.zone_sel.selecting == BP_L_HAND)
		var/has_hand
		var/obj/item/organ/external/O = H.organs_by_name[BP_R_HAND]
		if(istype(O) && !O.is_stump())
			has_hand = 1
		else
			O = H.organs_by_name[BP_L_HAND]
			if(istype(O) && !O.is_stump())
				has_hand = 1
		if(!has_hand)
			to_chat(user, "<span class='warning'>They don't have any hands.</span>")
			return
		user.visible_message("[user] swabs [H]'s palm for a sample.")
		sample_type = "residue"
		gsr = H.gunshot_residue
	else
		return

	if(sample_type)
		set_used(sample_type, H)

/obj/item/forensics/swab/afterattack(atom/target, mob/user, clickchain_flags, list/params)

	if(!(clickchain_flags & CLICKCHAIN_HAS_PROXIMITY) || istype(target, /obj/machinery/dnaforensics))
		return

	if(is_used())
		to_chat(user, "<span class='warning'>This swab has already been used.</span>")
		return

	add_fingerprint(user)

	var/list/choices = list()
	if(target.blood_DNA)
		choices |= "Blood"
	if(istype(target, /obj/item/clothing))
		choices |= "Gunshot Residue"

	var/choice
	if(!choices.len)
		to_chat(user, "<span class='warning'>There is no evidence on \the [target].</span>")
		return
	else if(choices.len == 1)
		choice = choices[1]
	else
		choice = input("What kind of evidence are you looking for?","Evidence Collection") as null|anything in choices

	if(!choice)
		return

	var/sample_type
	if(choice == "Blood")
		if(!target.blood_DNA || !target.blood_DNA.len) return
		dna = target.blood_DNA.Copy()
		sample_type = "blood"

	else if(choice == "Gunshot Residue")
		var/obj/item/clothing/B = target
		if(!istype(B) || !B.gunshot_residue)
			to_chat(user, "<span class='warning'>There is no residue on \the [target].</span>")
			return
		gsr = B.gunshot_residue
		sample_type = "residue"

	if(sample_type)
		user.visible_message("\The [user] swabs \the [target] for a sample.", "You swab \the [target] for a sample.")
		set_used(sample_type, target)

/obj/item/forensics/swab/proc/set_used(var/sample_str, var/atom/source)
	name = "[initial(name)] ([sample_str] - [source])"
	desc = "[initial(desc)] The label on the vial reads 'Sample of [sample_str] from [source].'."
	icon_state = "swab_used"
	used = 1
