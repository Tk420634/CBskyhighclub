

/obj/item/stack/sticky_tape
	name = "sticky tape"
	singular_name = "sticky tape"
	desc = "Used for sticking to things for sticking said things to people."
	icon = 'icons/obj/tapes.dmi'
	icon_state = "tape_w"
	var/prefix = "sticky"
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
	amount = 5
	max_amount = 5
	resistance_flags = FLAMMABLE
	splint_factor = 0.8
	grind_results = list(/datum/reagent/cellulose = 5)
	merge_type = /obj/item/stack/sticky_tape

	var/list/conferred_embed = EMBED_HARMLESS
	var/overwrite_existing = FALSE

	var/endless = FALSE
	var/apply_time = 30

/obj/item/stack/sticky_tape/afterattack(obj/item/I, mob/living/user)
	if(!istype(I))
		return

	if(I.embedding && I.embedding == conferred_embed)
		to_chat(user, span_warning("[I] is already coated in [src]!"))
		return

	user.visible_message(span_notice("[user] begins wrapping [I] with [src]."), span_notice("I begin wrapping [I] with [src]."))

	if(do_after(user, apply_time, target=I))
		I.embedding = conferred_embed
		I.updateEmbedding()
		to_chat(user, span_notice("I finish wrapping [I] with [src]."))
		if(!endless)
			use(1)
		I.name = "[prefix] [I.name]"

		if(istype(I, /obj/item/grenade))
			var/obj/item/grenade/sticky_bomb = I
			sticky_bomb.sticky = TRUE

/obj/item/stack/sticky_tape/infinite //endless tape that applies far faster, for maximum honks
	name = "endless sticky tape"
	desc = "This roll of sticky tape somehow has no end."
	endless = TRUE
	apply_time = 10
	merge_type = /obj/item/stack/sticky_tape/infinite

/obj/item/stack/sticky_tape/super
	name = "super sticky tape"
	singular_name = "super sticky tape"
	desc = "Quite possibly the most mischevious substance in the galaxy. Use with extreme lack of caution."
	icon_state = "tape_y"
	prefix = "super sticky"
	conferred_embed = EMBED_HARMLESS_SUPERIOR
	splint_factor = 0.6
	merge_type = /obj/item/stack/sticky_tape/super

/obj/item/stack/sticky_tape/pointy
	name = "pointy tape"
	singular_name = "pointy tape"
	desc = "Used for sticking to things for sticking said things inside people."
	icon_state = "tape_evil"
	prefix = "pointy"
	conferred_embed = EMBED_POINTY
	merge_type = /obj/item/stack/sticky_tape/pointy

/obj/item/stack/sticky_tape/pointy/super
	name = "super pointy tape"
	singular_name = "super pointy tape"
	desc = "I didn't know tape could look so sinister. Welcome to Space Station 13."
	icon_state = "tape_spikes"
	prefix = "super pointy"
	conferred_embed = EMBED_POINTY_SUPERIOR
	merge_type = /obj/item/stack/sticky_tape/pointy/super

/obj/item/stack/sticky_tape/surgical
	name = "surgical tape"
	singular_name = "surgical tape"
	desc = "Made for patching broken bones back together alongside bone gel, not for playing pranks."
	icon_state = "tapemedical"
	conferred_embed = list("embed_chance" = 30, "pain_mult" = 0, "jostle_pain_mult" = 0, "ignore_throwspeed_threshold" = TRUE)
	splint_factor = 0.4
	custom_price = 50
	merge_type = /obj/item/stack/sticky_tape/surgical