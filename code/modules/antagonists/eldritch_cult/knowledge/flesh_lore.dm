/datum/eldritch_knowledge/base_flesh
	name = "Principle of Hunger"
	desc = "Inducts you into the Path of Flesh. Allows you to transmute a pool of blood with your eldritch blade into a Blade of Flesh."
	gain_text = "Hundred's of us starved, but I.. I found the strength in my greed."
	banned_knowledge = list(/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_rust,/datum/eldritch_knowledge/final/ash_final,/datum/eldritch_knowledge/final/rust_final)
	next_knowledge = list(/datum/eldritch_knowledge/flesh_grasp)
	required_atoms = list(/obj/item/melee/sickly_blade,/obj/effect/decal/cleanable/blood)
	result_atoms = list(/obj/item/melee/sickly_blade/flesh)
	cost = 1
	route = PATH_FLESH

/datum/eldritch_knowledge/flesh_ghoul
	name = "Imperfect Ritual"
	desc = "Allows you to resurrect the dead as voiceless dead by sacrificing them on the transmutation rune with a poppy. Voiceless dead are mute and have 50 HP. You can only have 2 at a time."
	gain_text = "I found notes... notes of a ritual, scraps, unfinished, and yet... I still did it."
	cost = 1
	required_atoms = list(/mob/living/carbon/human,/obj/item/reagent_containers/food/snacks/grown/poppy)
	next_knowledge = list(/datum/eldritch_knowledge/flesh_mark,/datum/eldritch_knowledge/armor,/datum/eldritch_knowledge/ashen_eyes)
	route = PATH_FLESH
	var/max_amt = 2
	var/current_amt = 0
	var/list/ghouls = list()

/datum/eldritch_knowledge/flesh_ghoul/on_finished_recipe(mob/living/user,list/atoms,loc)
	var/mob/living/carbon/human/humie = locate() in atoms
	if(QDELETED(humie) || humie.stat != DEAD)
		return

	if(length(ghouls) >= max_amt)
		return

	if(HAS_TRAIT(humie,TRAIT_HUSK))
		return

	humie.grab_ghost()

	if(!humie.mind || !humie.client)
		var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a [humie.real_name], a voiceless dead.", ROLE_HERETIC, null, ROLE_HERETIC, 50,humie)
		if(!LAZYLEN(candidates))
			return
		var/mob/dead/observer/C = pick(candidates)
		message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(humie)]) to replace an AFK player.")
		humie.ghostize(0)
		humie.key = C.key

	ADD_TRAIT(humie,TRAIT_MUTE,MAGIC_TRAIT)
	log_game("[key_name_admin(humie)] has become a voiceless dead, their master is [user.real_name]")
	humie.revive(full_heal = TRUE, admin_revive = TRUE)
	humie.setMaxHealth(75)
	humie.health = 75 // Voiceless dead are much tougher than ghouls
	humie.become_husk()
	humie.faction |= "heretics"

	var/datum/antagonist/heretic_monster/heretic_monster = humie.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	var/datum/antagonist/heretic/master = user.mind.has_antag_datum(/datum/antagonist/heretic)
	heretic_monster.set_owner(master)
	atoms -= humie
	RegisterSignal(humie,COMSIG_MOB_DEATH,.proc/remove_ghoul)
	ghouls += humie

/datum/eldritch_knowledge/flesh_ghoul/proc/remove_ghoul(datum/source)
	var/mob/living/carbon/human/humie = source
	ghouls -= humie
	humie.mind.remove_antag_datum(/datum/antagonist/heretic_monster)
	UnregisterSignal(source,COMSIG_MOB_DEATH)

/datum/eldritch_knowledge/flesh_grasp
	name = "Grasp of Flesh"
	gain_text = "'My newfound desire, it drove me to do great things,' The Priest said."
	desc = "Empowers your Mansus Grasp to be able to create a single ghoul out of a dead player. You cannot raise the same person twice. Ghouls have only 50 HP and look like husks."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/flesh_ghoul)
	var/ghoul_amt = 4
	var/list/spooky_scaries
	route = PATH_FLESH

/datum/eldritch_knowledge/flesh_grasp/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!ishuman(target) || target == user)
		return
	var/mob/living/carbon/human/human_target = target
	var/datum/status_effect/eldritch/eldritch_effect = human_target.has_status_effect(/datum/status_effect/eldritch/rust) || human_target.has_status_effect(/datum/status_effect/eldritch/ash) || human_target.has_status_effect(/datum/status_effect/eldritch/flesh)
	if(eldritch_effect)
		. = TRUE
		eldritch_effect.on_effect()
		if(iscarbon(target))
			var/mob/living/carbon/carbon_target = target
			var/obj/item/bodypart/bodypart = pick(carbon_target.bodyparts)
			var/datum/wound/bleed/slash/severe/crit_wound = new
			crit_wound.apply_wound(bodypart)

	if(QDELETED(human_target) || human_target.stat != DEAD)
		return

	human_target.grab_ghost()

	if(!human_target.mind || !human_target.client)
		to_chat(user, span_warning("There is no soul connected to this body..."))
		return

	if(HAS_TRAIT(human_target, TRAIT_HUSK))
		to_chat(user, span_warning("I cannot revive a dead ghoul!"))
		return

	if(LAZYLEN(spooky_scaries) >= ghoul_amt)
		to_chat(user, span_warning("My patron cannot support more ghouls on this plane!"))
		return

	LAZYADD(spooky_scaries, human_target)
	log_game("[key_name_admin(human_target)] has become a ghoul, their master is [user.real_name]")
	//we change it to true only after we know they passed all the checks
	. = TRUE
	RegisterSignal(human_target,COMSIG_MOB_DEATH,.proc/remove_ghoul)
	human_target.revive(full_heal = TRUE, admin_revive = TRUE)
	human_target.setMaxHealth(40)
	human_target.health = 40
	human_target.become_husk()
	human_target.faction |= "heretics"
	var/datum/antagonist/heretic_monster/heretic_monster = human_target.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	var/datum/antagonist/heretic/master = user.mind.has_antag_datum(/datum/antagonist/heretic)
	heretic_monster.set_owner(master)
	return


/datum/eldritch_knowledge/flesh_grasp/proc/remove_ghoul(datum/source)
	var/mob/living/carbon/human/humie = source
	spooky_scaries -= humie
	humie.mind.remove_antag_datum(/datum/antagonist/heretic_monster)
	UnregisterSignal(source, COMSIG_MOB_DEATH)

/datum/eldritch_knowledge/flesh_mark
	name = "Mark of Flesh"
	gain_text = "I saw them, the marked ones. The screams... the silence."
	desc = "My sickly blade now applies a mark of flesh to those cut by it. Once marked, using your Mansus Grasp upon them will cause additional bleeding from the target."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/summon/raw_prophet)
	banned_knowledge = list(/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/ash_mark)
	route = PATH_FLESH

/datum/eldritch_knowledge/flesh_mark/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/flesh)

/datum/eldritch_knowledge/flesh_blade_upgrade
	name = "Bleeding Steel"
	gain_text = "It rained blood, that's when I understood the gravekeeper's advice."
	desc = "My blade will now cause additional bleeding to those hit by it."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/summon/stalker)
	banned_knowledge = list(/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/rust_blade_upgrade)
	route = PATH_FLESH

/datum/eldritch_knowledge/flesh_blade_upgrade/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		var/obj/item/bodypart/bodypart = pick(carbon_target.bodyparts)
		var/datum/wound/bleed/slash/severe/crit_wound = new
		crit_wound.apply_wound(bodypart)

/datum/eldritch_knowledge/summon/raw_prophet
	name = "Raw Ritual"
	gain_text = "The uncanny man walks alone in the valley, I was able to call his aid."
	desc = "I can now summon a Raw Prophet using eyes, a left arm, right arm and a pool of blood using a transmutation circle. Raw prophets have increased seeing range, and can see through walls. They can jaunt long distances, though they are fragile."
	cost = 1
	required_atoms = list(/obj/item/organ/eyes,/obj/item/bodypart/l_arm,/obj/item/bodypart/r_arm,/obj/effect/decal/cleanable/blood)
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/raw_prophet
	next_knowledge = list(/datum/eldritch_knowledge/flesh_blade_upgrade,/datum/eldritch_knowledge/spell/blood_siphon,/datum/eldritch_knowledge/curse/paralysis)
	route = PATH_FLESH

/datum/eldritch_knowledge/summon/stalker
	name = "Lonely Ritual"
	gain_text = "I was able to combine my greed and desires to summon an eldritch beast I have not seen before."
	desc = "I can now summon a Stalker using a knife, a flower, a pen and a piece of paper using a transmutation circle. Stalkers possess the ability to shapeshift into various forms while assuming the vigor and powers of that form."
	cost = 1
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/reagent_containers/food/snacks/grown/poppy,/obj/item/pen,/obj/item/paper)
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/stalker
	next_knowledge = list(/datum/eldritch_knowledge/summon/ashy,/datum/eldritch_knowledge/summon/rusty,/datum/eldritch_knowledge/flesh_blade_upgrade_2)
	route = PATH_FLESH

/datum/eldritch_knowledge/summon/ashy
	name = "Ashen Ritual"
	gain_text = "I combined principle of hunger with desire of destruction. The eyeful lords have noticed me."
	desc = "I can now summon an Ashen One by transmuting a pile of ash, a head and a book using a transmutation circle. They possess the ability to jaunt short distances and create a cascade of flames."
	cost = 1
	required_atoms = list(/obj/effect/decal/cleanable/ash,/obj/item/bodypart/head,/obj/item/book)
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/ash_spirit
	next_knowledge = list(/datum/eldritch_knowledge/summon/stalker,/datum/eldritch_knowledge/spell/flame_birth)

/datum/eldritch_knowledge/summon/rusty
	name = "Rusted Ritual"
	gain_text = "I combined principle of hunger with desire of corruption. The rusted hills call my name."
	desc = "I can now summon a Rust Walker transmuting a vomit pool, a head, and a book using a transmutation circle. Rust Walkers possess the ability to spread rust and can fire bolts of rust to further corrode the area."
	cost = 1
	required_atoms = list(/obj/effect/decal/cleanable/vomit,/obj/item/bodypart/head,/obj/item/book)
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/rust_spirit
	next_knowledge = list(/datum/eldritch_knowledge/summon/stalker,/datum/eldritch_knowledge/spell/entropic_plume)

/datum/eldritch_knowledge/spell/blood_siphon
	name = "Blood Siphon"
	gain_text = "Our blood is all the same after all, the owl told me."
	desc = "I am granted a spell that drains some of the targets health, and returns it to you. It also has a chance to transfer any wounds you possess onto the target."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/targeted/touch/blood_siphon
	next_knowledge = list(/datum/eldritch_knowledge/summon/raw_prophet,/datum/eldritch_knowledge/spell/area_conversion)

/datum/eldritch_knowledge/final/flesh_final
	name = "Priest's Final Hymn"
	gain_text = "Man of this world. Hear me! For the time of the lord of arms has come!"
	desc = "Bring three corpses to a transmutation rune to either ascend as The Lord of the Night or summon a single Terror of the Night, however you cannot ascend more than once."
	required_atoms = list(/mob/living/carbon/human)
	cost = 5
	route = PATH_FLESH

/datum/eldritch_knowledge/final/flesh_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	var/alert_ = alert(user,"Do you want to ascend as the lord of the night or just summon a terror of the night?","...","Yes","No")
	user.SetImmobilized(10 HOURS) // no way someone will stand 10 hours in a spot, just so he can move while the alert is still showing.
	switch(alert_)
		if("No")
			var/mob/living/summoned = new /mob/living/simple_animal/hostile/eldritch/armsy(loc)
			message_admins("[summoned.name] is being summoned by [user.real_name] in [loc]")
			var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a [summoned.real_name]", ROLE_HERETIC, null, ROLE_HERETIC, 100,summoned)
			user.SetImmobilized(0)
			if(LAZYLEN(candidates) == 0)
				to_chat(user,span_warning("No ghost could be found..."))
				qdel(summoned)
				return FALSE
			var/mob/dead/observer/ghost_candidate = pick(candidates)
			priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Fear the dark, for vassal of arms has ascended! Terror of the night has come! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", 'sound/announcer/classic/spanomalies.ogg')
			log_game("[key_name_admin(ghost_candidate)] has taken control of ([key_name_admin(summoned)]).")
			summoned.ghostize(FALSE)
			summoned.key = ghost_candidate.key
			summoned.mind.add_antag_datum(/datum/antagonist/heretic_monster)
			var/datum/antagonist/heretic_monster/monster = summoned.mind.has_antag_datum(/datum/antagonist/heretic_monster)
			var/datum/antagonist/heretic/master = user.mind.has_antag_datum(/datum/antagonist/heretic)
			monster.set_owner(master)
			master.ascended = TRUE
		if("Yes")
			var/mob/living/summoned = new /mob/living/simple_animal/hostile/eldritch/armsy/prime(loc,TRUE,10)
			summoned.ghostize(0)
			user.SetImmobilized(0)
			priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Fear the dark, for king of arms has ascended! Lord of the night has come! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", 'sound/announcer/classic/spanomalies.ogg')
			log_game("[user.real_name] ascended as [summoned.real_name]")
			var/mob/living/carbon/carbon_user = user
			var/datum/antagonist/heretic/ascension = carbon_user.mind.has_antag_datum(/datum/antagonist/heretic)
			ascension.ascended = TRUE
			carbon_user.mind.transfer_to(summoned, TRUE)
			carbon_user.gib()

	return ..()

/datum/eldritch_knowledge/flesh_blade_upgrade_2
	name = "Remembrance"
	gain_text = "Pain isn't something easily forgotten."
	desc = "My blade remembers more, and remembers how easily bones broke just as its flesh did, guaranteeing dislocated, or broken bones."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/spell/touch_of_madness)
	route = PATH_FLESH

/datum/eldritch_knowledge/flesh_blade_upgrade_2/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		var/obj/item/bodypart/bodypart = pick(carbon_target.bodyparts)
		var/datum/wound/blunt/moderate/moderate_wound = new
		moderate_wound.apply_wound(bodypart)

/datum/eldritch_knowledge/spell/touch_of_madness
	name = "Touch of Madness"
	gain_text = "The ignorant mind that inhabits their feeble bodies will crumble when they acknowledge - willingly or not, the truth."
	desc = "By forcing the knowledge of the Mansus upon my foes, I can show them things that would drive any normal man insane."
	cost = 2
	spell_to_add = /obj/effect/proc_holder/spell/targeted/touch/mad_touch
	next_knowledge = list(/datum/eldritch_knowledge/final/flesh_final)
	route = PATH_FLESH
