////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/food/drinks
	name = "drink"
	desc = "yummy"
	icon = 'icons/obj/drinks.dmi'
	icon_state = null
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	reagent_flags = OPENCONTAINER
	reagent_value = DEFAULT_REAGENTS_VALUE
	var/gulp_size = 5 //This is now officially broken ... need to think of a nice way to fix it.
	possible_transfer_amounts = list(5,10,15,20,25,30,50)
	volume = 50
	resistance_flags = NONE
	var/isGlass = TRUE //Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it
	tableplacesound = 'sound/machines/glassclink.ogg'

/obj/item/reagent_containers/food/drinks/on_reagent_change(changetype)
	if (gulp_size < 5)
		gulp_size = 5
	else
		gulp_size = max(round(reagents.total_volume / 5), 5)

/obj/item/reagent_containers/food/drinks/take_a_bellybite(datum/source, obj/vore_belly/gut, mob/living/vorer)
	INVOKE_ASYNC(src,PROC_REF(attempt_forcedrink), vorer, vorer, TRUE, TRUE, TRUE)
	if(gut.can_taste)
		checkLiked(min(gulp_size/reagents.total_volume, 1), vorer)
	return TRUE

/obj/item/reagent_containers/food/drinks/attack(mob/living/M, mob/user, def_zone)
	INVOKE_ASYNC(src,PROC_REF(attempt_forcedrink), M, user)

/obj/item/reagent_containers/food/drinks/proc/attempt_forcedrink(mob/living/M, mob/user, force, silent, vorebite)
	if(!reagents || !reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return 0

	if(!canconsume(M, user))
		return 0

	if (!is_drainable())
		to_chat(user, span_warning("[src]'s lid hasn't been opened!"))
		return 0

	if(M == user || vorebite)
		if(!silent)
			user.visible_message(span_notice("[user] swallows a gulp of [src]."), span_notice("I swallow a gulp of [src]."))
	else
		if(!silent)
			M.visible_message(span_danger("[user] attempts to feed the contents of [src] to [M]."), span_userdanger("[user] attempts to feed the contents of [src] to [M]."))
		if(!do_mob(user, M))
			return
		if(!reagents || !reagents.total_volume)
			return // The drink might be empty after the delay, such as by spam-feeding
		if(!silent)
			M.visible_message(span_danger("[user] feeds the contents of [src] to [M]."), span_userdanger("[user] feeds the contents of [src] to [M]."))
		log_combat(user, M, "fed", reagents.log_list())

	var/fraction = min(gulp_size/reagents.total_volume, 1)
	if(!vorebite)
		checkLiked(fraction, M)
	reagents.reaction(M, INGEST, fraction)
	reagents.trans_to(M, gulp_size, log = TRUE)
	if(!silent)
		playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
	return 1

/obj/item/reagent_containers/food/drinks/CheckAttackCooldown(mob/user, atom/target)
	var/fast = HAS_TRAIT(user, TRAIT_VORACIOUS) && (user == target)
	return user.CheckActionCooldown(fast? CLICK_CD_RANGE : CLICK_CD_MELEE)

/obj/item/reagent_containers/food/drinks/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return

	if(target.is_refillable() && is_drainable()) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, span_warning("[src] is empty."))
			return

		if(target.reagents.holder_full())
			to_chat(user, span_warning("[target] is full."))
			return

		var/refill = reagents.get_master_reagent_id()
		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this, log = TRUE)
		to_chat(user, span_notice("I transfer [trans] units of the solution to [target]."))

		if(iscyborg(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
			var/mob/living/silicon/robot/bro = user
			bro.cell.use(30)
			addtimer(CALLBACK(reagents, TYPE_PROC_REF(/datum/reagents,add_reagent), refill, trans), 600)

	else if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		if (!is_refillable())
			to_chat(user, span_warning("[src]'s tab isn't open!"))
			return

		if(!target.reagents.total_volume)
			to_chat(user, span_warning("[target] is empty."))
			return

		if(reagents.holder_full())
			to_chat(user, span_warning("[src] is full."))
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, log = TRUE)
		to_chat(user, span_notice("I fill [src] with [trans] units of the contents of [target]."))

/obj/item/reagent_containers/food/drinks/attackby(obj/item/I, mob/user, params)
	var/hotness = I.get_temperature()
	if(hotness && reagents)
		reagents.expose_temperature(hotness)
		to_chat(user, span_notice("I heat [name] with [I]!"))
	..()

/obj/item/reagent_containers/food/drinks/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!.) //if the bottle wasn't caught
		smash(hit_atom, throwingdatum?.thrower, TRUE)

/obj/item/reagent_containers/food/drinks/proc/smash(atom/target, mob/thrower, ranged = FALSE)
	if(!isGlass && !istype(src, /obj/item/reagent_containers/food/drinks/bottle)) //I don't like this but I also don't want to rework drink container hierarchy
		return
	if(QDELING(src) || (ranged && !target))
		return
	if(bartender_check(target) && ranged)
		return
	var/obj/item/broken_bottle/B = new (loc)
	B.icon_state = icon_state
	var/icon/I = new('icons/obj/drinks.dmi', src.icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I
	B.name = "broken [name]"
	if(ranged)
		var/matrix/M = matrix(B.transform)
		M.Turn(rand(-170, 170))
		B.transform = M
		B.pixel_x = rand(-12, 12)
		B.pixel_y = rand(-12, 12)
	if(isGlass)
		playsound(src, "shatter", 70, 1)
		if(prob(33))
			new/obj/item/shard(drop_location())
	else
		B.force = 0
		B.throwforce = 0
		B.desc = "A carton with the bottom half burst open. Might give you a papercut."
	transfer_fingerprints_to(B)
	qdel(src)

/obj/item/reagent_containers/food/drinks/MouseDrop(atom/over, atom/src_location, atom/over_location, src_control, over_control, params)
	var/mob/user = usr
	. = ..()
	if (!istype(src_location) || !istype(over_location))
		return
	if (!user || user.incapacitated(allow_crit = TRUE) || !user.Adjacent(src))
		return
	if (!(locate(/obj/structure/table) in src_location) || !(locate(/obj/structure/table) in over_location))
		return

	//Are we an expert slider?
	var/datum/action/innate/D = get_action_of_type(user, /datum/action/innate/drink_fling)
	if(!D?.active)
		if (!src_location.Adjacent(over_location)) // Regular users can only do short slides.
			return
		if (prob(10))
			user.visible_message(span_warning("\The [user] tries to slide \the [src] down the table, but fails miserably."), span_warning("I <b>fail</b> to slide \the [src] down the table!"))
			smash(over_location, user, FALSE)
			return
		user.visible_message(span_notice("\The [user] slides \the [src] down the table."), span_notice("I slide \the [src] down the table!"))
		forceMove(over_location)
		return
	var/distance = MANHATTAN_DISTANCE(over_location, src)
	if (distance >= 8 || distance == 0) // More than a full screen to go, or trying to slide to the same tile
		return

	// Geometrically checking if we're on a straight line.
	var/datum/vector/V = atoms2vector(src, over_location)
	var/datum/vector/V_norm = V.duplicate()
	V_norm.normalize()
	if (!V_norm.is_integer())
		return // Only a cardinal vector (north, south, east, west) can pass this test

	// Checks if there's tables on the path.
	var/turf/dest = get_translated_turf(V)
	var/turf/temp_turf = src_location

	do
		temp_turf = temp_turf.get_translated_turf(V_norm)
		if (!locate(/obj/structure/table) in temp_turf)
			var/datum/vector/V2 = atoms2vector(src, temp_turf)
			vector_translate(V2, 0.1 SECONDS)
			user.visible_message(span_warning("\The [user] slides \the [src] down the table... and straight into the ground!"), span_warning("I slide \the [src] down the table, and straight into the ground!"))
			smash(over_location, user, FALSE)
			return
	while (temp_turf != dest)

	vector_translate(V, 0.1 SECONDS)
	user.visible_message(span_notice("\The [user] expertly slides \the [src] down the table."), span_notice("I slide \the [src] down the table. What a pro."))
	return


////////////////////////////////////////////////////////////////////////////////
/// Drinks. END
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/food/drinks/trophy
	name = "pewter cup"
	desc = "Everyone gets a trophy."
	icon_state = "pewter_cup"
	w_class = WEIGHT_CLASS_TINY
	force = 1
	throwforce = 1
	amount_per_transfer_from_this = 5
	custom_materials = list(/datum/material/iron=100)
	possible_transfer_amounts = list()
	volume = 5
	flags_1 = CONDUCT_1
	spillable = TRUE
	resistance_flags = FIRE_PROOF
	isGlass = FALSE

/obj/item/reagent_containers/food/drinks/trophy/gold_cup
	name = "gold cup"
	desc = "You're winner!"
	icon_state = "golden_cup"
	w_class = WEIGHT_CLASS_BULKY
	force = 14
	throwforce = 10
	amount_per_transfer_from_this = 20
	custom_materials = list(/datum/material/gold=1000)
	volume = 150

/obj/item/reagent_containers/food/drinks/trophy/silver_cup
	name = "silver cup"
	desc = "Best loser!"
	icon_state = "silver_cup"
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	throwforce = 8
	amount_per_transfer_from_this = 15
	custom_materials = list(/datum/material/silver=800)
	volume = 100

/obj/item/reagent_containers/food/drinks/trophy/bronze_cup
	name = "bronze cup"
	desc = "At least you ranked!"
	icon_state = "bronze_cup"
	w_class = WEIGHT_CLASS_SMALL
	force = 5
	throwforce = 4
	amount_per_transfer_from_this = 10
	custom_materials = list(/datum/material/iron=400)
	volume = 25

///////////////////////////////////////////////Drinks/////////////////////////////////////////
//Notes by Darem: Drinks are simply containers that start preloaded. Unlike condiments, the contents can be ingested directly
//	rather then having to add it to something else first. They should only contain liquids. They have a default container size of 50.
//	Formatting is the same as food.

/obj/item/reagent_containers/food/drinks/coffee
	name = "robust coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	list_reagents = list(/datum/reagent/consumable/coffee = 30)
	spillable = TRUE
	resistance_flags = FREEZE_PROOF
	isGlass = FALSE
	foodtype = BREAKFAST

//Used by MREs
/obj/item/reagent_containers/food/drinks/coffee/type2
	name = "\improper Coffee, instant (type 2)"
	desc = "Coffee that's been blow dried into a granulated powder. This packet includes self heating water for your nutritional pleasure."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "condi_cornoil"

/obj/item/reagent_containers/food/drinks/ice
	name = "ice cup"
	desc = "Careful, cold ice, do not chew."
	custom_price = PRICE_CHEAP_AS_FREE
	icon_state = "coffee"
	list_reagents = list(/datum/reagent/consumable/ice = 30)
	spillable = TRUE
	isGlass = FALSE

/obj/item/reagent_containers/food/drinks/ice/sustanance
	custom_price = PRICE_FREE

/obj/item/reagent_containers/food/drinks/mug/ // parent type is literally just so empty mug sprites are a thing
	name = "mug"
	desc = "A drink served in a classy mug."
	icon_state = "tea"
	inhand_icon_state = "coffee"
	spillable = TRUE

/obj/item/reagent_containers/food/drinks/mug/on_reagent_change(changetype)
	cut_overlays()
	if(reagents.total_volume)
		var/mutable_appearance/MA = mutable_appearance(icon,"mugoverlay", color = mix_color_from_reagents(reagents.reagent_list))
		add_overlay(MA)
	else
		icon_state = "tea_empty"

/obj/item/reagent_containers/food/drinks/mug/tea
	name = "Duke Purple tea"
	icon_state = "tea"
	desc = "An insult to Duke Purple is an insult to the Space Queen! Any proper gentleman will fight you, if you sully this tea."
	list_reagents = list(/datum/reagent/consumable/tea = 30)

/obj/item/reagent_containers/food/drinks/mug/tea/red
	name = "Dutchess Red tea"
	icon_state = "tea"
	desc = "Duchess Red's personal blend of red tea leaves and hot water. Great addition to any meal."
	list_reagents = list(/datum/reagent/consumable/tea/red = 30)

/obj/item/reagent_containers/food/drinks/mug/tea/green
	name = "Prince Green tea"
	icon_state = "tea"
	desc = "Prince Green's brew of tea. The blend may be different from time to time, but Prince Green swears by it!"
	list_reagents = list(/datum/reagent/consumable/tea/green = 30)

/obj/item/reagent_containers/food/drinks/mug/tea/forest
	name = "Royal Forest tea"
	icon_state = "tea"
	desc = "Tea fit for anyone with a sweet tooth like Royal Forest."
	list_reagents = list(/datum/reagent/consumable/tea/forest = 30)

/obj/item/reagent_containers/food/drinks/mug/tea/mush
	name = "Rebel Mush tea"
	icon_state = "tea"
	desc = "Rebel Mush, a hallucinogenic tea to help people find their inner self."
	list_reagents = list(/datum/reagent/consumable/tea/mush = 30)


/obj/item/reagent_containers/food/drinks/mug/coco
	name = "Dutch hot coco"
	desc = "Made in Space South America."
	icon_state = "coco"
	list_reagents = list(/datum/reagent/consumable/hot_coco = 30, /datum/reagent/consumable/sugar = 5)
	foodtype = SUGAR
	resistance_flags = FREEZE_PROOF
	custom_price = PRICE_ALMOST_CHEAP

/obj/item/reagent_containers/food/drinks/dry_ramen
	name = "cup ramen"
	desc = "Just add 10ml of water, self heats! A pre-collapse delicacy that's grown all-too-rare."
	icon_state = "ramen"
	list_reagents = list(/datum/reagent/consumable/dry_ramen = 30)
	foodtype = GRAIN
	isGlass = FALSE
	custom_price = PRICE_PRETTY_CHEAP

/obj/item/reagent_containers/food/drinks/beer
	name = "Beer"
	desc = "Beer. Its cheap."
	icon_state = "beer"
	list_reagents = list(/datum/reagent/consumable/ethanol/beer = 30)
	foodtype = GRAIN | ALCOHOL
	custom_price = PRICE_PRETTY_CHEAP

/obj/item/reagent_containers/food/drinks/beer/light
	name = "Beer Lite"
	desc = "Beer that somehow tastes \"even worse\"."
	list_reagents = list(/datum/reagent/consumable/ethanol/beer/light = 30)

/obj/item/reagent_containers/food/drinks/ale
	name = "Magm-Ale"
	desc = "A true dorf's drink of choice."
	icon_state = "alebottle"
	inhand_icon_state = "beer"
	list_reagents = list(/datum/reagent/consumable/ethanol/ale = 30)
	foodtype = GRAIN | ALCOHOL

/obj/item/reagent_containers/food/drinks/sillycup
	name = "paper cup"
	desc = "A paper water cup."
	icon_state = "water_cup_e"
	possible_transfer_amounts = list()
	volume = 10
	spillable = TRUE
	isGlass = FALSE

/obj/item/reagent_containers/food/drinks/sillycup/handcup
	name = "a cupped hand"
	desc = "My hand, cupped to hold liquids."
	icon_state = "water_cup_e"
	possible_transfer_amounts = list()
	volume = 5
	spillable = TRUE
	isGlass = FALSE
	item_flags = DROPDEL | ABSTRACT | HAND_ITEM
	is_food = FALSE

/obj/item/reagent_containers/food/drinks/sillycup/on_reagent_change(changetype)
	if(reagents.total_volume)
		icon_state = "water_cup"
	else
		icon_state = "water_cup_e"

/obj/item/reagent_containers/food/drinks/sillycup/smallcarton
	name = "small carton"
	desc = "A small carton, intended for holding drinks."
	icon_state = "juicebox"
	volume = 15 //I figure if you have to craft these it should at least be slightly better than something you can get for free from a watercooler

/obj/item/reagent_containers/food/drinks/sillycup/smallcarton/on_reagent_change(changetype)
	if (reagents.reagent_list.len)
		switch(reagents.get_master_reagent_id())
			if(/datum/reagent/consumable/orangejuice)
				icon_state = "orangebox"
				name = "orange juice box"
				desc = "A great source of vitamins. Stay healthy!"
				foodtype = FRUIT | BREAKFAST
			if(/datum/reagent/consumable/milk)
				icon_state = "milkbox"
				name = "carton of milk"
				desc = "An excellent source of calcium for growing space explorers."
				foodtype = DAIRY | BREAKFAST
			if(/datum/reagent/consumable/applejuice)
				icon_state = "juicebox"
				name = "apple juice box"
				desc = "Sweet apple juice. Don't be late for school!"
				foodtype = FRUIT | BREAKFAST
			if(/datum/reagent/consumable/grapejuice)
				icon_state = "grapebox"
				name = "grape juice box"
				desc = "Tasty grape juice in a fun little container. Non-alcoholic!"
				foodtype = FRUIT | BREAKFAST
			if(/datum/reagent/consumable/pineapplejuice)
				icon_state = "pineapplebox"
				name = "pineapple juice box"
				desc = "Why would you even want this?"
				foodtype = FRUIT | PINEAPPLE
			if(/datum/reagent/consumable/milk/chocolate_milk)
				icon_state = "chocolatebox"
				name = "carton of chocolate milk"
				desc = "Milk for cool kids!"
				foodtype = SUGAR | BREAKFAST
			if("eggnog")
				icon_state = "nog2"
				name = "carton of eggnog"
				desc = "For enjoying the most wonderful time of the year."
				foodtype = MEAT
	else
		icon_state = "juicebox"
		name = "small carton"
		desc = "A small carton, intended for holding drinks."


//////////////////////////drinkingglass and shaker/////////////////////////////////////////////////////////////////////////////////////
//Note by Darem: This code handles the mixing of drinks. New drinks go in three places: In Chemistry-Reagents.dm (for the drink
//	itself), in Chemistry-Recipes.dm (for the reaction that changes the components into the drink), and here (for the drinking glass
//	icon states.

/obj/item/reagent_containers/food/drinks/shaker
	name = "shaker"
	desc = "A metal shaker to mix drinks in."
	icon_state = "shaker"
	custom_materials = list(/datum/material/iron=1500)
	amount_per_transfer_from_this = 10
	volume = 100
	isGlass = FALSE

/obj/item/reagent_containers/food/drinks/flask
	name = "flask"
	desc = "Every good wastelander knows it's a good idea to bring along a couple of pints of whiskey wherever they go."
	icon_state = "flask"
	custom_materials = list(/datum/material/iron=250)
	volume = 60
	isGlass = FALSE
	custom_price = PRICE_ABOVE_NORMAL

/obj/item/reagent_containers/food/drinks/flask/gold
	name = "golden flask"
	desc = "A gold flask belonging to the someone important."
	icon_state = "flask_gold"
	custom_materials = list(/datum/material/gold=500)

/obj/item/reagent_containers/food/drinks/flask/det
	name = "detective's flask"
	desc = "The detective's only true friend."
	icon_state = "detflask"
	list_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 30)

/obj/item/reagent_containers/food/drinks/flask/tech
	name = "High-tech Canteen"
	desc = "A rather technical looking drinking vessel made of a polymer housing for the general shape, it is reminiscent of a water canteen. It faintly hums as the metallic refrigeration kicks in to keep the contents cold. It is woven with a carbon fiber mesh at places to also help with this, and to offer some grip. The initials J.N. are marked on the underside of the vessel."
	icon_state = "techcanteen"
	list_reagents = list(/datum/reagent/water = 60)

/obj/item/reagent_containers/food/drinks/britcup
	name = "cup"
	desc = "A cup with the british flag emblazoned on it."
	icon_state = "britcup"
	volume = 30
	spillable = TRUE

//////////////////////////soda_cans////////////////////////////////////////////////////
//These are in their own group to be used as IED's in /obj/item/grenade/ghettobomb.dm//

/obj/item/reagent_containers/food/drinks/soda_cans
	name = "soda can"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	reagent_flags = NONE
	spillable = FALSE
	isGlass = FALSE
	custom_price = PRICE_CHEAP_AS_FREE

/obj/item/reagent_containers/food/drinks/soda_cans/attack(mob/M, mob/user)
	if(M == user && !src.reagents.total_volume && user.a_intent == INTENT_HARM && user.zone_selected == BODY_ZONE_HEAD)
		crush_can(user)
	..()

/obj/item/reagent_containers/food/drinks/soda_cans/proc/crush_can(mob/user, silent, vorebite)
	if(!silent)
		user.visible_message(span_warning("[user] crushes the can of [src] on [user.p_their()] forehead!"), span_notice("I crush the can of [src] on your forehead."))
	playsound(user.loc,'sound/weapons/pierce.ogg', rand(10,50), 1)
	var/obj/item/trash/can/crushed_can = new /obj/item/trash/can(vorebite ? loc : get_turf(src))
	crushed_can.icon_state = icon_state
	SEND_SIGNAL(loc, COMSIG_BELLY_HANDLE_TRASH, crushed_can)
	qdel(src)

/obj/item/reagent_containers/food/drinks/soda_cans/attack_self(mob/user)
	if(!is_drainable())
		pop_top(user)
	return ..()

/obj/item/reagent_containers/food/drinks/soda_cans/proc/pop_top(mob/user, silent)
	if(!silent)
		to_chat(user, "I pull back the tab of \the [src] with a satisfying pop.") //Ahhhhhhhh
	playsound(src, "can_open", 50, 1)
	ENABLE_BITFIELD(reagents.reagents_holder_flags, OPENCONTAINER)
	spillable = TRUE
	return

/obj/item/reagent_containers/food/drinks/soda_cans/take_a_bellybite(datum/source, obj/vore_belly/gut, mob/living/vorer)
	if(!is_drainable())
		INVOKE_ASYNC(src,PROC_REF(pop_top), vorer, vorer, TRUE, TRUE, TRUE)
		return TRUE
	if(!reagents.total_volume)
		INVOKE_ASYNC(src,PROC_REF(crush_can), vorer, vorer, TRUE, TRUE, TRUE)
		return TRUE
	return ..()

/obj/item/reagent_containers/food/drinks/soda_cans/cola
	name = "Space Cola"
	desc = "Cola. in space."
	icon_state = "cola"
	list_reagents = list(/datum/reagent/consumable/space_cola = 30)
	foodtype = SUGAR

/obj/item/reagent_containers/food/drinks/soda_cans/tonic
	name = "T-Borg's tonic water"
	desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	icon_state = "tonic"
	list_reagents = list(/datum/reagent/consumable/tonic = 50)

/obj/item/reagent_containers/food/drinks/soda_cans/sodawater
	name = "soda water"
	desc = "A can of soda water. Why not make a scotch and soda?"
	icon_state = "sodawater"
	list_reagents = list(/datum/reagent/consumable/sodawater = 50)

/obj/item/reagent_containers/food/drinks/soda_cans/lemon_lime
	name = "orange soda"
	desc = "I wanted ORANGE. It gave you Lemon Lime."
	icon_state = "lemon-lime"
	list_reagents = list(/datum/reagent/consumable/lemon_lime = 30)
	foodtype = FRUIT

/obj/item/reagent_containers/food/drinks/soda_cans/lemon_lime/Initialize()
	. = ..()
	name = "lemon-lime soda"

/obj/item/reagent_containers/food/drinks/soda_cans/sol_dry
	name = "Sol Dry"
	desc = "Maybe this will help your tummy feel better. Maybe not."
	icon_state = "ginger_ale"
	list_reagents = list(/datum/reagent/consumable/sol_dry = 30)
	foodtype = SUGAR

/obj/item/reagent_containers/food/drinks/soda_cans/space_up
	name = "Space-Up!"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up"
	list_reagents = list(/datum/reagent/consumable/space_up = 30)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/starkist
	name = "Star-kist"
	desc = "The taste of a star in liquid form. And, a bit of tuna...?"
	icon_state = "starkist"
	list_reagents = list(/datum/reagent/consumable/space_cola = 15, /datum/reagent/consumable/orangejuice = 15)
	foodtype = SUGAR | FRUIT | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/space_mountain_wind
	name = "Space Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind"
	list_reagents = list(/datum/reagent/consumable/spacemountainwind = 30)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/thirteenloko
	name = "Thirteen Loko"
	desc = "The CMO has advised crew members that consumption of Thirteen Loko may result in seizures, blindness, drunkenness, or even death. Please Drink Responsibly."
	icon_state = "thirteen_loko"
	list_reagents = list(/datum/reagent/consumable/ethanol/thirteenloko = 30)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/dr_gibb
	name = "Dr. Gibb"
	desc = "A delicious mixture of 42 different flavors."
	icon_state = "dr_gibb"
	list_reagents = list(/datum/reagent/consumable/dr_gibb = 30)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/pwr_game
	name = "Pwr Game"
	desc = "The only drink with the PWR that true gamers crave."
	icon_state = "purple_can"
	list_reagents = list(/datum/reagent/consumable/pwr_game = 30)

/obj/item/reagent_containers/food/drinks/soda_cans/shamblers
	name = "Shambler's juice"
	desc = "~Shake me up some of that Shambler's Juice!~"
	icon_state = "shamblers"
	list_reagents = list(/datum/reagent/consumable/shamblers = 30)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/buzz_fuzz
	name = "Buzz Fuzz"
	desc = "The sister drink of Shambler's Juice! Uses real honey, making it a sweet tooth's dream drink. The slogan reads ''A Hive of Flavour'', there's also a label about how it is adddicting."
	icon_state = "honeysoda_can"
	list_reagents = list(/datum/reagent/consumable/buzz_fuzz = 25, /datum/reagent/consumable/honey = 5)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/grey_bull
	name = "Grey Bull"
	desc = "Grey Bull, it gives you gloves!"
	icon_state = "energy_drink"
	list_reagents = list(/datum/reagent/consumable/grey_bull = 20)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/air
	name = "canned air"
	desc = "There is no air shortage. Do not drink."
	icon_state = "air"
	list_reagents = list(/datum/reagent/nitrogen = 24, /datum/reagent/oxygen = 6)

/obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy
	name = "Monkey Energy"
	desc = "Unleash the ape!"
	icon_state = "monkey_energy"
	list_reagents = list(/datum/reagent/consumable/monkey_energy = 50)
	foodtype = SUGAR | JUNKFOOD
