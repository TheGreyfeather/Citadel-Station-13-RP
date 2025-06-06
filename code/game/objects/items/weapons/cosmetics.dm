/obj/item/lipstick
	gender = PLURAL
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon = 'icons/obj/items.dmi'
	icon_state = "lipstick"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_EARS
	var/colour = "red"
	var/open = 0
	drop_sound = 'sound/items/drop/glass.ogg'
	pickup_sound = 'sound/items/pickup/glass.ogg'


/obj/item/lipstick/orange
	name = "orange lipstick"
	colour = "orange"

/obj/item/lipstick/yellow
	name = "yellow lipstick"
	colour = "yellow"

/obj/item/lipstick/jade
	name = "jade lipstick"
	colour = "jade"

/obj/item/lipstick/cyan
	name = "cyan lipstick"
	colour = "cyan"

/obj/item/lipstick/purple
	name = "purple lipstick"
	colour = "purple"

/obj/item/lipstick/pink
	name = "pink lipstick"
	colour = "pink"

/obj/item/lipstick/maroon
	name = "maroon lipstick"
	colour = "maroon"

/obj/item/lipstick/black
	name = "black lipstick"
	colour = "black"

/obj/item/lipstick/white
	name = "white lipstick"
	colour = "white"

/obj/item/lipstick/random
	name = "lipstick"

/obj/item/lipstick/random/Initialize(mapload)
	. = ..()
	colour = pick("red","orange","yellow","jade","cyan","purple","pink","maroon","black","white")
	name = "[colour] lipstick"

/obj/item/lipstick/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	to_chat(user, "<span class='notice'>You twist \the [src] [open ? "closed" : "open"].</span>")
	open = !open
	if(open)
		icon_state = "[initial(icon_state)]_[colour]"
	else
		icon_state = initial(icon_state)

/obj/item/lipstick/legacy_mob_melee_hook(mob/target, mob/user, clickchain_flags, list/params, mult, target_zone, intent)
	if(!open)
		return ..()
	. = CLICKCHAIN_DO_NOT_PROPAGATE
	if(!ishuman(target))
		to_chat(user, "<span class='notice'>Where are the lips on that?</span>")
		return
	var/mob/living/carbon/human/H = target
	if(H.lip_style)	//if they already have lipstick on
		to_chat(user, "<span class='notice'>You need to wipe off the old lipstick first!</span>")
		return
	if(H == user)
		user.visible_message("<span class='notice'>[user] does their lips with \the [src].</span>", \
								"<span class='notice'>You take a moment to apply \the [src]. Perfect!</span>")
		H.lip_style = colour
		H.update_icons_body()
	else
		user.visible_message("<span class='warning'>[user] begins to do [H]'s lips with \the [src].</span>", \
								"<span class='notice'>You begin to apply \the [src].</span>")
		if(do_after(user, 20, H))	//user needs to keep their active hand, H does not.
			user.visible_message("<span class='notice'>[user] does [H]'s lips with \the [src].</span>", \
									"<span class='notice'>You apply \the [src].</span>")
			H.lip_style = colour
			H.update_icons_body()

//you can wipe off lipstick with paper! see code/modules/paperwork/paper.dm, paper/attack()

/obj/item/haircomb //sparklysheep's comb
	name = "purple comb"
	desc = "A pristine purple comb made from flexible plastic."
	w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_EARS
	icon = 'icons/obj/items.dmi'
	icon_state = "purplecomb"

/obj/item/haircomb/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	var/text = "person"
	if(ishuman(user))
		var/mob/living/carbon/human/U = user
		switch(U.identifying_gender)
			if(MALE)
				text = "guy"
			if(FEMALE)
				text = "lady"
	else
		switch(user.gender)
			if(MALE)
				text = "guy"
			if(FEMALE)
				text = "lady"
	user.visible_message("<span class='notice'>[user] uses [src] to comb their hair with incredible style and sophistication. What a [text].</span>")

/obj/item/makeover
	name = "makeover kit"
	desc = "A tiny case containing a mirror and some contact lenses."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/items.dmi'
	icon_state = "trinketbox"
	var/list/ui_users = list()

/obj/item/makeover/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(ishuman(user))
		to_chat(user, "<span class='notice'>You flip open \the [src] and begin to adjust your appearance.</span>")
		var/datum/nano_module/appearance_changer/AC = ui_users[user]
		if(!AC)
			AC = new(src, user)
			AC.name = "SalonPro Porta-Makeover Deluxe&trade;"
			ui_users[user] = AC
		AC.nano_ui_interact(user)
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/internal/eyes/E = H.internal_organs_by_name[O_EYES]
		if(istype(E))
			E.change_eye_color()
