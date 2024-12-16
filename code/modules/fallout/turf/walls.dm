//Fallout 13 general destructible walls directory

/turf/closed/wall/f13/
	name = "glitch"
	desc = "<font color='#6eaa2c'>You suddenly realize the truth - there is no spoon.<br>Something has caused a glitch in the simulation.</font>"
	icon = 'icons/fallout/turfs/walls.dmi'
	icon_state = "matrix"

/turf/closed/wall/f13/ReplaceWithLattice()
	ChangeTurf(baseturfs)

/turf/closed/wall/f13/ruins
	name = "ruins"
	desc = "All what has left from the good old days."  //What is this fucking english? ~TK
	icon = 'icons/turf/walls/f13composite.dmi'
	icon_state = "ruins"
//	icon_type_smooth = "ruins"
	hardness = 70
	explosion_block = 2
	smoothing_flags = SMOOTH_CORNERS
	//	disasemblable = 0
	girder_type = 0
	baseturfs = /turf/open/indestructible/ground/outside/ruins
	sheet_type = null
	canSmoothWith = null
	unbreakable = 0

/turf/closed/wall/f13/ruins/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_ROCK, -10, 5, 1)
	
/turf/closed/wall/f13/wood
	name = "cabin wall"
	desc = "A traditional wooden log cabin wall."
	icon = 'icons/turf/walls/wood_log.dmi'
	icon_state = "wall-0"
	hardness = 60
	unbreakable = 0
	baseturfs = /turf/open/floor/plating/wooden
	sheet_type = /obj/item/stack/sheet/mineral/wood
	sheet_amount = 2
	girder_type = 0
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_LOGCABIN_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_LOGCABIN_WALLS)

/turf/closed/wall/f13/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/turf/closed/wall/f13/wood/house
	name = "house wall"
	desc = "A weathered pre-War house wall."
	icon = 'icons/turf/walls/house_wall_dirty.dmi'
	icon_state = "wall-0"
	hardness = 50
	var/broken = 0
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_HOUSE_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_HOUSE_WALLS, SMOOTH_GROUP_WINDOW_FULLTILE)

/turf/closed/wall/f13/wood/house/clean
	icon = 'icons/turf/walls/house_wall.dmi'

/turf/closed/wall/f13/coyote/fortress_brick
	name = "DEPRECATED WALL! INFORM MAPPERS TO REPLACE THIS!"

/turf/closed/wall/f13/wood/interior
	name = "interior wall"
	desc = "Interesting, what kind of material they have used - these wallpapers still look good after all the centuries..."
	icon = 'icons/fallout/turfs/walls/interior.dmi'
	icon_state = "interior0"
	hardness = 10
	smoothing_flags = SMOOTH_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_INTERIOR_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_INTERIOR_WALLS, SMOOTH_GROUP_WINDOW_FULLTILE)

/turf/closed/wall/mineral/concrete
	name = "concrete wall"
	desc = "A pre-fabricated concrete wall."
	icon = 'icons/turf/walls/concrete.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	sheet_type = /obj/item/stack/sheet/mineral/sandstone
	hardness = 40
	explosion_block = 0
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_CONCRETE_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_CONCRETE_WALLS, SMOOTH_GROUP_WINDOW_FULLTILE)
	custom_materials = list(/datum/material/sandstone = 4000)

/obj/structure/falsewall/concrete
	name = "concrete wall"
	desc = "A pre-fabricated concrete wall."
	icon = 'icons/turf/walls/concrete.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	mineral = /obj/item/stack/sheet/mineral/sandstone
	walltype = /turf/closed/wall/mineral/concrete
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_CONCRETE_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_CONCRETE_WALLS, SMOOTH_GROUP_WINDOW_FULLTILE)

/turf/closed/wall/mineral/brick
	name = "brick wall"
	desc = "A wall made out of red brick."
	icon = 'icons/turf/walls/brick_wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	sheet_type = /obj/item/stack/sheet/mineral/sandstone//Needs replacing with an actual brick subtype
	hardness = 40
	explosion_block = 0
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_REDBRICK_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_REDBRICK_WALLS, SMOOTH_GROUP_WINDOW_FULLTILE)
	custom_materials = list(/datum/material/sandstone = 4000)

/obj/structure/falsewall/brick
	name = "brick wall"
	desc = "A wall made out of red brick."
	icon = 'icons/turf/walls/brick_wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	mineral = /obj/item/stack/sheet/mineral/sandstone
	walltype = /turf/closed/wall/mineral/brick
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_REDBRICK_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_REDBRICK_WALLS, SMOOTH_GROUP_WINDOW_FULLTILE)

/turf/closed/wall/mineral/brick/old
	name = "weathered brick wall"
	desc = "A wall made out of red brick."
	icon = 'icons/turf/walls/brick_wall_old.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	sheet_type = /obj/item/stack/sheet/mineral/sandstone//Needs replacing with an actual brick subtype
	hardness = 40
	explosion_block = 0
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_OLDBRICK_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_OLDBRICK_WALLS, SMOOTH_GROUP_WINDOW_FULLTILE)
	custom_materials = list(/datum/material/sandstone = 4000)

/obj/structure/falsewall/brick/old
	name = "weathered brick wall"
	desc = "A wall made out of red brick."
	icon = 'icons/turf/walls/brick_wall_old.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	mineral = /obj/item/stack/sheet/mineral/sandstone
	walltype = /turf/closed/wall/mineral/brick
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_OLDBRICK_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_OLDBRICK_WALLS, SMOOTH_GROUP_WINDOW_FULLTILE)

/turf/closed/wall/f13/tentwall
	name = "tent wall"
	desc = "The walls of a portable tent."
	icon = 'icons/turf/walls/tent_wall.dmi'
	icon_state = "wall-0"
	hardness = 10
	unbreakable = 0
	baseturfs = /turf/open/indestructible/ground/outside/ruins
	girder_type = 0
	sheet_type = /obj/item/stack/sheet/cloth
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_TENT_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_TENT_WALLS, SMOOTH_GROUP_WINDOW_FULLTILE)

/turf/closed/wall/f13/scrap
	name = "scrap wall"
	desc = "A wall held together by corrugated metal and prayers."
	icon = 'icons/fallout/turfs/walls/scrap.dmi'
	icon_state = "scrap0"
//	icon_type_smooth = "scrap"
	hardness = 80
//	smoothing_flags = SMOOTH_OLD
	girder_type = 0
	canSmoothWith = null

/turf/closed/wall/f13/scrap/red
	icon = 'icons/fallout/turfs/walls/scrap_red.dmi'
	icon_state = "scrapr0"
//	icon_type_smooth = "scrapr"

/turf/closed/wall/f13/scrap/blue
	icon = 'icons/fallout/turfs/walls/scrap_blue.dmi'
	icon_state = "scrapb0"
//	icon_type_smooth = "scrapb"

/turf/closed/wall/f13/scrap/white
	icon = 'icons/fallout/turfs/walls/scrap_white.dmi'
	icon_state = "scrapw0"
//	icon_type_smooth = "scrapw"

/turf/closed/wall/f13/scrap/junk
	name = "junk wall"
	desc = "More a pile of debris and rust than a wall, but it'll hold for now."
	icon = 'icons/fallout/turfs/walls/scrap_rough.dmi'
	icon_state = "scrapro0"
//	icon_type_smooth = "scrapro"

/turf/closed/wall/f13/supermart
	name = "supermart wall"
	desc = "A pre-War supermart wall made of reinforced concrete."
	icon = 'icons/turf/walls/f13superstore.dmi'
	icon_state = "supermart"
//	icon_type_smooth = "supermart"
	hardness = 90
	explosion_block = 2
	smoothing_flags = SMOOTH_CORNERS
	baseturfs = /turf/open/indestructible/ground/outside/ruins
	//	disasemblable = 0
	girder_type = 0
	sheet_type = null
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_SUPERMART_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_SUPERMART_WALLS, SMOOTH_GROUP_WINDOW_FULLTILE)

/turf/closed/wall/f13/tunnel
	name = "utility tunnel wall"
	desc = "A sturdy metal wall with various pipes and wiring set inside a special groove."
	icon = 'icons/turf/walls/utility_wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	hardness = 100
	girder_type = 0
	sheet_type = null
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_UTILITY_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_UTILITY_WALLS, SMOOTH_GROUP_WINDOW_FULLTILE)

/turf/closed/wall/f13/vault
	name = "vault wall"
	desc = "A sturdy and cold metal wall."
	icon = 'icons/fallout/turfs/walls/vault.dmi'
	icon_state = "vault0"
//	icon_type_smooth = "vault"
	hardness = 130
	explosion_block = 5
//	smoothing_flags = SMOOTH_OLD
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_VAULT_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_VAULT_WALLS, SMOOTH_GROUP_WINDOW_FULLTILE)

/turf/closed/wall/r_wall/f13
	name = "glitch"
	desc = "<font color='#6eaa2c'>You suddenly realize the truth - there is no spoon.<br>Something has caused a glitch in the simulation.</font>"
	icon = 'icons/fallout/turfs/walls.dmi'
	icon_state = "matrix"

/turf/closed/wall/r_wall/f13/vault
	name = "vault reinforced wall"
	desc = "A wall built to withstand an atomic explosion."
	icon = 'icons/fallout/turfs/walls/vault_reinforced.dmi'
	icon_state = "vaultrwall0"
	hardness = 230
	explosion_block = 5
	smoothing_flags = null
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_VAULT_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_VAULT_WALLS, SMOOTH_GROUP_WINDOW_FULLTILE)

/turf/closed/wall/r_wall/f13vault/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -15, 8, 1)

//Sunset custom walls

/turf/closed/wall/f13/sunset/brick_small
	name = "brick wall"
	desc = "A wall made out of solid brick."
	icon = 'modular_sunset/icons/turfs/walls/brick_small.dmi'
	icon_state = "brick0"
//	icon_type_smooth = "brick"
	hardness = 80
//	smoothing_flags = SMOOTH_OLD
	girder_type = 0
	sheet_type = null
	canSmoothWith = null

/turf/closed/wall/f13/sunset/brick_small_dark
	name = "brick wall"
	desc = "A wall made out of solid brick."
	icon = 'modular_sunset/icons/turfs/walls/brick_small_dark.dmi'
	icon_state = "brick0"
//	icon_type_smooth = "brick"
	hardness = 80
//	smoothing_flags = SMOOTH_OLD
	girder_type = 0
	sheet_type = null
	canSmoothWith = null

/turf/closed/wall/f13/sunset/brick_small_light
	name = "brick wall"
	desc = "A wall made out of solid brick."
	icon = 'modular_sunset/icons/turfs/walls/brick_small_light.dmi'
	icon_state = "brick0"
//	icon_type_smooth = "brick"
	hardness = 80
//	smoothing_flags = SMOOTH_OLD
	girder_type = 0
	sheet_type = null
	canSmoothWith = null

//Fallout 13 indestructible walls

/turf/closed/indestructible/f13
	name = "glitch"
	desc = "<font color='#6eaa2c'>You suddenly realize the truth - there is no spoon.<br>Something has caused a glitch in the simulation.</font>"
	icon = 'icons/fallout/turfs/walls.dmi'
	icon_state = "matrix"

/turf/closed/indestructible/f13/subway
	name = "tunnel wall"
	desc = "This wall is made of reinforced concrete.<br>Pre-War engineers knew how to build reliable things."
	icon = 'icons/fallout/turfs/walls/subway.dmi'
	icon_state = "subwaytop"

/turf/closed/indestructible/f13/matrix //The Chosen One from Arroyo!
	name = "matrix"
	desc = "<font color='#6eaa2c'>You suddenly realize the truth - there is no spoon.<br>Digital simulation ends here.</font>"
	icon_state = "matrix"
	var/in_use = FALSE

/turf/closed/indestructible/f13/matrix/MouseDrop_T(atom/dropping, mob/user)
	. = ..()
	if(!dropping || !user)
		return
	if(!isliving(user))
		to_chat(user, span_warning("Can't quite do that!"))
		return
	if(!isliving(dropping))
		to_chat(user, span_warning("That's not something that this thing can do anything with!"))
		return
	if(QDELETED(dropping))
		to_chat(user, span_warning("They're already on their way out!"))
		return
	if(!isliving(user) || user.incapacitated(allow_crit = TRUE) || !isliving(dropping))
		return //No ghosts or incapacitated folk allowed to do this.
	if(in_use) // Someone's already going in.
		to_chat(user, span_warning("Someone is already using that thing, or it just stopped working. Try a different tile =3"))
		return
	if(SSmobs.there_is_no_escape)
		to_chat(user, span_warning("This method of escape has been disabled. Sorry!"))
		return
	if(dropping == user)
		depart_self(user)
	else
		depart_other(user, dropping)

/turf/closed/indestructible/f13/matrix/proc/depart_self(mob/living/user)
	if(in_use)
		return
	in_use = TRUE
	var/igo = alert(
		user,
		"This will depart you from the game (despawn you). You can come back any time you want! Are you sure you want to do this?",
		"Time to go!",
		"Depart!",
		"Cancel",
	)
	if(igo != "Depart!")
		return
	var/dumpit = alert(
		user,
		"Want to dump all your stuff into a bag before you go? It'll sit here until you come back (or someone else takes it!).",
		"Durg?",
		"Dump it!",
		"No thanks",
	)
	dumpit = (dumpit == "Dump it!") ? TRUE : FALSE
	var/lockit = CHECK_PREFS(user, DUMP_STUFF_ON_LOGOUT)
	var/worked = FALSE
	if(do_after(
		user,
		(3 SECONDS),
		FALSE,
		src,
		TRUE,
		null,
		null,
		null,
		FALSE,
		TRUE,
		TRUE,
		TRUE,
		TRUE,
	))
		worked = TRUE
	in_use = FALSE
	if(!worked)
		to_chat(user, span_warning("Okay nevermind!!"))
		return
	to_chat(user, span_notice("You have departed from the bar, hope to see you soon!"))
	user.visible_message(span_notice("[user] has departed from the bar. Hope to see them soon!"))
	if(dumpit)
		to_chat(user, span_notice("Your stuff has been put into a bag."))
		StuffPlayerContentsIntoABag(user, get_turf(user), lockit)
	message_admins("[key_name(user)] has departed from the bar.")
	log_admin("[key_name(user)] has departed from the bar.")
	if(user.client.is_in_game >= 1)
		// if(user.client.is_in_game == 2)
		// 	to_chat(world, span_nicegreen("I hear through the grapevine that [user.name] has left the county."))
		user.client.is_in_game = 0
	whoosh(user)
	user.despawn()

/turf/closed/indestructible/f13/matrix/proc/depart_other(mob/living/user, mob/living/departing_mob)
	if(in_use)
		return
	if(departing_mob.client)
		to_chat(user, span_warning("That person is still 'with us', so they'll have to decide for themselves if they want to leave."))
		return
	var/igo = alert(
		user,
		"This will depart [departing_mob] from the game (despawn them). They can come back any time they want! Are you sure you want to do this? All their stuff will be left in a sack, just in case.",
		"Send 'em packing!",
		"Send them away!",
		"Cancel",
	)
	if(igo != "Send them away!")
		return
	in_use = TRUE
	var/worked = FALSE
	if(do_after(
		user,
		(3 SECONDS),
		FALSE,
		src,
		TRUE,
		null,
		null,
		null,
		FALSE,
		TRUE,
		TRUE,
		TRUE,
		TRUE,
	))
		worked = TRUE
	in_use = FALSE
	if(!worked)
		to_chat(user, span_warning("Okay nevermind!!"))
		return
	var/lockit = CHECK_PREFS(user, DUMP_STUFF_ON_LOGOUT)
	to_chat(user, span_notice("[user] has sent [departing_mob] away. Hope to see them soon!"))
	departing_mob.visible_message(span_notice("[departing_mob] has been sent away. Hope to see them soon!"))
	StuffPlayerContentsIntoABag(departing_mob, get_turf(departing_mob), lockit)
	message_admins("[key_name(user)] has sent [key_name(departing_mob)] away.")
	log_admin("[key_name(user)] has sent [key_name(departing_mob)] away.")
	if(departing_mob.client.is_in_game >= 1)
		// if(departing_mob.client.is_in_game == 2)
		// 	to_chat(world, span_nicegreen("I hear through the grapevine that [departing_mob.name] has left the county."))
		departing_mob.client.is_in_game = 0
	whoosh(departing_mob)
	departing_mob.despawn()

/turf/closed/indestructible/f13/matrix/proc/whoosh(mob/departing_mob)
	do_sparks(2, TRUE, get_turf(departing_mob))
	playsound(departing_mob, 'sound/effects/player_despawn.ogg', 80, TRUE)

/proc/StuffPlayerContentsIntoABag(mob/who, atom/where, lockit)
	if(!who)
		return
	if(!where)
		where = get_turf(who)
	var/obj/item/storage/despawned/box = new /obj/item/storage/despawned(where)
	for(var/obj/item/I in who.contents)
		if(istype(I, /obj/item/organ))
			continue
		if(istype(I, /obj/item/bodypart))
			continue
		if(HAS_TRAIT(I, TRAIT_NODROP))
			continue
		I.forceMove(box)
	if(lockit)
		box.SetOwnerKey(who)

/obj/item/storage/despawned
	name = "box of stuff"
	desc = "A sack of belongings belonging to someone who left and might want to come back."
	icon_state = "eq_box"
	inhand_icon_state = "backpack"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	w_class = WEIGHT_CLASS_GIGANTIC
	slot_flags = NONE
	resistance_flags = INDESTRUCTIBLE
	component_type = /datum/component/storage/concrete/debug_sack/massive
	var/owner_key

/obj/item/storage/despawned/examine(mob/user)
	. = ..()
	if(user.ckey == owner_key)
		to_chat(user, span_greentext("This is your stuff! It belongs to you! =3"))

/obj/item/storage/despawned/proc/SetOwnerKey(mob/who)
	owner_key = who.ckey
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.lock_key = owner_key

/turf/closed/indestructible/f13/obsidian //Just like that one game studio that worked on the original game, or that block in Minecraft!
	name = "obsidian"
	desc = "No matter what you do with this rock, there's not even a scratch left on its surface.<br><font color='#7e0707'>You shall not pass!!!</font>"
	icon = 'icons/fallout/turfs/mining.dmi'
	icon_state = "rock1"

/turf/closed/indestructible/f13/obsidian/New()
	..()
	icon_state = "rock[rand(1,6)]"

//Splashscreen
/*
/turf/closed/indestructible/f13/splashscreen
	var/tickerPeriod = 300 //in deciseconds
	var/go/fullDark

/turf/closed/indestructible/f13/splashscreen/New()
	.=..()
	name = "Fallout 13"
	desc = "The wasteland is calling!"
	icon = 'icons/fallout/misc/lobby.dmi'
	icon_state = "title[rand(1,13)]"
	layer = 60
	plane = 1
	src.fullDark = new/go{
		icon = 'icons/fallout/misc/lobby.dmi' //Replace with actual icon
		icon_state = "transition" //Replace with actual darkness state
		layer = 61;
		alpha = 0;
		}(src)
	src.fullDark.plane = 1
	spawn() src.ticker()
	return

/turf/closed/indestructible/f13/splashscreen/proc/ticker()
	while(src && istype(src,/turf/closed/indestructible/f13/splashscreen))
		src.swapImage()
		sleep(src.tickerPeriod)
	to_chat(world, "Badmins spawn shit and the title screen was deleted.<br>You know... I'm out of here!")
	return

//Change the time to determine how short/long the fading animation is.
//Change the easing to determine what interpolation it uses to change the value on a curve: good ones to try are CUBIC, BOUNCE, and ELASTIC as well as CIRCULAR. BOUNCE and ELASTIC both "bounce" or "flicker" a little bit at the end instead of just finishing straight at black.

/turf/closed/indestructible/f13/splashscreen/proc/swapImage()
	animate(src.fullDark,alpha=255,time=10,easing=CUBIC_EASING)
	sleep(12) //buffer of about 1/5 of the time of the animation, since they are not synchronized: the sleep happens on the server, but the animation is played for each client using directX. It's good to leave a buffer, but most of the time the directX will be much faster than the server anyway so you probably wont have any problems.
	src.icon_state = "title[rand(1,13)]"
	animate(src.fullDark,alpha=0,time=10,easing=CUBIC_EASING)
	return
*/

/turf/closed/wall/f13/coyote/oldwood
	name = "old wood wall"
	desc = "A wall of very old and rotting wood."
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	hardness = 80
	smoothing_flags = SMOOTH_BITMASK
	girder_type = 0
	sheet_type = null
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_OLDWOOD_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_OLDWOOD_WALLS, SMOOTH_GROUP_WINDOW_FULLTILE)
