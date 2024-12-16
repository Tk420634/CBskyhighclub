/*
//////////////////////////////////////

Hallucigen

	Very noticable.
	Lowers resistance considerably.
	Decreases stage speed.
	Reduced transmittable.
	Critical Level.

Bonus
	Makes the affected mob be hallucinated for short periods of time.

//////////////////////////////////////
*/

/datum/symptom/hallucigen
	name = "Hallucigen"
	desc = "The virus stimulates the brain, causing occasional hallucinations."
	stealth = -1
	resistance = -3
	stage_speed = -3
	transmittable = -1
	level = 5
	severity = 2
	base_message_chance = 25
	symptom_delay_min = 25
	symptom_delay_max = 90
	var/fake_healthy = FALSE
	threshold_desc = list(
		"Stage Speed 7" = "Increases the amount of hallucinations.",
		"Stealth 4" = "The virus mimics positive symptoms.",
	)

/datum/symptom/hallucigen/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stealth"] >= 4) //fake good symptom messages
		fake_healthy = TRUE
		base_message_chance = 50
	if(A.properties["stage_rate"] >= 7) //stronger hallucinations
		power = 2

/datum/symptom/hallucigen/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	var/list/healthy_messages = list("My lungs feel great.", "I realize you haven't been breathing.", "I don't feel the need to breathe.",\
					"My eyes feel great.", "I am now blinking manually.", "I don't feel the need to blink.")
	switch(A.stage)
		if(1, 2)
			if(prob(base_message_chance))
				if(!fake_healthy)
					to_chat(M, span_notice("[pick("Something appears in your peripheral vision, then winks out.", "I hear a faint whisper with no source.", "My head aches.")]"))
				else
					to_chat(M, span_notice("[pick(healthy_messages)]"))
		if(3, 4)
			if(prob(base_message_chance))
				if(!fake_healthy)
					to_chat(M, span_danger("[pick("Something is following you.", "I am being watched.", "I hear a whisper in your ear.", "Thumping footsteps slam toward you from nowhere.")]"))
				else
					to_chat(M, span_notice("[pick(healthy_messages)]"))
		else
			if(prob(base_message_chance))
				to_chat(M, span_userdanger("[pick("Oh, your head...", "My head pounds.", "They're everywhere! Run!", "Something in the shadows...")]"))
			M.hallucination += (45 * power)