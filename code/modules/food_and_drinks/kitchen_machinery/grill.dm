/obj/machinery/grill
	name = "grill"
	desc = "Just like the old days."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grill_open"
	density = TRUE
	layer = BELOW_OBJ_LAYER
	use_power = NO_POWER_USE
	var/grill_fuel = 0
	var/obj/item/reagent_containers/food/grilled_item
	var/grill_time = 0
	var/datum/looping_sound/grill/grill_loop

/obj/machinery/grill/Destroy()
	QDEL_NULL(grill_loop)
	return ..()

/obj/machinery/grill/Initialize()
	. = ..()
	grill_loop = new(list(src), FALSE)

/obj/machinery/grill/Destroy()
	QDEL_NULL(grill_loop)
	return ..()

/obj/machinery/grill/update_icon_state()
	if(grilled_item)
		icon_state = "grill"
	else if(grill_fuel)
		icon_state = "grill_on"
	else
		icon_state = "grill_open"

/obj/machinery/grill/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/sheet/mineral/coal) || istype(I, /obj/item/stack/sheet/mineral/wood))
		var/obj/item/stack/S = I
		var/stackamount = S.get_amount()
		to_chat(user, span_notice("I put [stackamount] [I]s in [src]."))
		if(istype(I, /obj/item/stack/sheet/mineral/coal))
			grill_fuel += (500 * stackamount)
		else
			grill_fuel += (50 * stackamount)
		S.use(stackamount)
		update_icon()
		return
	if(I.resistance_flags & INDESTRUCTIBLE)
		to_chat(user, span_warning("I don't feel it would be wise to grill [I]..."))
		return ..()
	if(istype(I, /obj/item/reagent_containers))
		if(istype(I, /obj/item/reagent_containers/food) && !istype(I, /obj/item/reagent_containers/food/drinks))
			if(HAS_TRAIT(I, TRAIT_NODROP) || (I.item_flags & (ABSTRACT | DROPDEL)))
				return ..()
			else if(!grill_fuel)
				to_chat(user, span_notice("There is not enough fuel."))
				return
			else if(!grilled_item && user.transferItemToLoc(I, src))
				grilled_item = I
				to_chat(user, span_notice("I put the [grilled_item] on [src]."))
				update_icon()
				grill_loop.start()
				return
		else
			if(I.reagents.has_reagent(/datum/reagent/consumable/monkey_energy))
				grill_fuel += (20 * (I.reagents.get_reagent_amount(/datum/reagent/consumable/monkey_energy)))
				to_chat(user, span_notice("I pour the Monkey Energy in [src]."))
				I.reagents.remove_reagent("monkey_energy", I.reagents.get_reagent_amount(/datum/reagent/consumable/monkey_energy))
				update_icon()
				return
	..()

/obj/machinery/grill/process()
	..()
	update_icon()
	if(!grill_fuel)
		return
	else
		grill_fuel -= 1
	if(grilled_item)
		grill_time += 1
		grilled_item.reagents.add_reagent(/datum/reagent/consumable/char, 1)
		grill_fuel -= 10
		grilled_item.AddComponent(/datum/component/sizzle)

/obj/machinery/grill/Exited(atom/movable/AM)
	if(AM == grilled_item)
		finish_grill()
		grilled_item = null
	..()

/obj/machinery/grill/Destroy()
	grilled_item = null
	. = ..()

/obj/machinery/grill/handle_atom_del(atom/A)
	if(A == grilled_item)
		grilled_item = null
	. = ..()

/obj/machinery/grill/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(default_unfasten_wrench(user, I) != CANT_UNFASTEN)
		return TRUE

/obj/machinery/grill/deconstruct(disassembled = TRUE)
	finish_grill()
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/metal(loc, 5)
		new /obj/item/stack/rods(loc, 5)
	..()

/obj/machinery/grill/attack_ai(mob/user)
	return

/obj/machinery/grill/on_attack_hand(mob/user, act_intent = user.a_intent, unarmed_attack_flags)
	if(grilled_item)
		to_chat(user, span_notice("I take out [grilled_item] from [src]."))
		grilled_item.forceMove(drop_location())
		update_icon()
		return
	return ..()

/obj/machinery/grill/proc/finish_grill()
	switch(grill_time) //no 0-9 to prevent spam
		if(10 to 15)
			grilled_item.name = "lightly-grilled [grilled_item.name]"
			grilled_item.desc = "[grilled_item.desc] It's been lightly grilled."
		if(16 to 39)
			grilled_item.name = "grilled [grilled_item.name]"
			grilled_item.desc = "[grilled_item.desc] It's been grilled."
			grilled_item.foodtype |= FRIED
		if(40 to 50)
			grilled_item.name = "heavily grilled [grilled_item.name]"
			grilled_item.desc = "[grilled_item.desc] It's been heavily grilled."
			grilled_item.foodtype |= FRIED
		if(51 to INFINITY) //grill marks reach max alpha
			grilled_item.name = "Powerfully Grilled [grilled_item.name]"
			grilled_item.desc = "A [grilled_item.name]. Reminds you of your deepfryer skills, wait, no, it's better!"
			grilled_item.foodtype |= FRIED
	grill_time = 0
	grill_loop.stop()

/obj/machinery/grill/unwrenched
	anchored = FALSE
