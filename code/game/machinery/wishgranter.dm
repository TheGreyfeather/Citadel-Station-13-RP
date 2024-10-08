/obj/machinery/wish_granter
	name = "Wish Granter"
	desc = "You're not so sure about this, anymore..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	use_power = USE_POWER_OFF
	anchored = TRUE
	density = TRUE
	var/charges = 1
	var/insisting = 0

/obj/machinery/wish_granter/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	usr.set_machine(src)

	if(charges <= 0)
		to_chat(user, "The Wish Granter lies silent.")
		return

	else if(!istype(user, /mob/living/carbon/human))
		to_chat(user, "You feel a dark stirring inside of the Wish Granter, something you want nothing of. Your instincts are better than any man's.")
		return

	else if(is_special_character(user))
		to_chat(user, "Even to a heart as dark as yours, you know nothing good will come of this.  Something instinctual makes you pull away.")

	else if(!insisting)
		to_chat(user, "Your first touch makes the Wish Granter stir, listening to you.  Are you really sure you want to do this?")
		insisting++

	else
		to_chat(user, "You speak.  [pick("I want the station to disappear","Humanity is corrupt, mankind must be destroyed","I want to be rich", "I want to rule the world","I want immortality.")].  The Wish Granter answers.")
		to_chat(user, "Your head pounds for a moment, before your vision clears.  You are the avatar of the Wish Granter, and your power is LIMITLESS!  And it's all yours.  You need to make sure no one can take it from you.  No one can know, first.")

		charges--
		insisting = 0

		if(!(MUTATION_HULK in user.mutations))
			user.mutations.Add(MUTATION_HULK)

		if(!(MUTATION_LASER in user.mutations))
			user.mutations.Add(MUTATION_LASER)

		if(!(MUTATION_XRAY in user.mutations))
			user.mutations.Add(MUTATION_XRAY)
			user.ensure_self_perspective()
			user.handle_regular_hud_updates()

		if(!(MUTATION_COLD_RESIST in user.mutations))
			user.mutations.Add(MUTATION_COLD_RESIST)

		if(!(MUTATION_TELEKINESIS in user.mutations))
			user.mutations.Add(MUTATION_TELEKINESIS)

		if(!(MUTATION_HEAL in user.mutations))
			user.mutations.Add(MUTATION_HEAL)

		user.update_mutations()
		user.mind.special_role = "Avatar of the Wish Granter"

		var/datum/objective/silence/silence = new
		silence.owner = user.mind
		user.mind.objectives += silence

		show_objectives(user.mind)
		to_chat(user, "You have a very bad feeling about this.")

	return
