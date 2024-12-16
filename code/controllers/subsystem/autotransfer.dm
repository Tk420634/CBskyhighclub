#define NO_MAXVOTES_CAP -1
#define EE_START 0
#define EE_WARNING_1 1
#define EE_WARNING_2 2
#define EE_WARNING_3 3
#define EE_GIRL 4
#define EE_END 5

SUBSYSTEM_DEF(autotransfer)
	name = "Autotransfer Vote"
	flags = SS_KEEP_TIMING | SS_BACKGROUND
	wait = 1 SECONDS

	var/starttime
	var/targettime = (23.5 HOURS)
	var/voteinterval
	var/maxvotes
	var/curvotes = 0
	var/allow_vote_restart = FALSE
	var/allow_vote_transfer = FALSE
	var/min_end_vote_time = INFINITY // lol

	var/easy_end = TRUE
	var/EE_stage = EE_START
	var/EE_warning_1 = (5 MINUTES)
	var/EE_warning_2 = (10 MINUTES)
	var/EE_warning_3 = (25 MINUTES)
	var/EE_true_end = (30 MINUTES)
	var/girlfailure_time = 30 // in seconds
	var/next_announce_time = 0

	var/use_config = FALSE // if TRUE, use config values instead of the above - cus fukc the config

/datum/controller/subsystem/autotransfer/Initialize(timeofday)
	// hi I'm Dan and I say fukc the config
	if(use_config)
		read_config()
	EE_true_end = EE_warning_1 + EE_warning_2 + EE_warning_3
	next_announce_time = targettime
	return ..()

/datum/controller/subsystem/autotransfer/proc/read_config()
	var/init_vote = CONFIG_GET(number/vote_autotransfer_initial)
	if(!init_vote) //Autotransfer voting disabled.
		return
	starttime = world.time
	targettime = starttime + init_vote
	voteinterval = CONFIG_GET(number/vote_autotransfer_interval)
	maxvotes = CONFIG_GET(number/vote_autotransfer_maximum)


/datum/controller/subsystem/autotransfer/Recover()
	starttime = SSautotransfer.starttime
	voteinterval = SSautotransfer.voteinterval
	curvotes = SSautotransfer.curvotes

/datum/controller/subsystem/autotransfer/fire()
	if(world.time < targettime)
		return
	if(!easy_end)
		SSshuttle.autoEnd()
	else
		RunAnnounceLoop()


/datum/controller/subsystem/autotransfer/proc/RunAnnounceLoop()
	if(world.time < next_announce_time)
		return
	Announce()
	switch(EE_stage)
		if(EE_START)
			EE_stage = EE_WARNING_1
			next_announce_time = world.time + EE_warning_1
		if(EE_WARNING_1)
			EE_stage = EE_WARNING_2
			next_announce_time = world.time + EE_warning_2
		if(EE_WARNING_2)
			EE_stage = EE_WARNING_3
			next_announce_time = world.time + EE_warning_3
		if(EE_WARNING_3)
			EE_stage = EE_GIRL
			next_announce_time = EE_true_end
		if(EE_GIRL)
			SSticker.KillGame()
			AnnounceEnd()
			next_announce_time = INFINITY

/datum/controller/subsystem/autotransfer/proc/Announce()
	var/lefttime = 0
	switch(EE_stage)
		if(EE_START)
			lefttime = EE_true_end
		if(EE_WARNING_1)
			lefttime = EE_warning_3
		if(EE_WARNING_2)
			lefttime = EE_warning_2
		if(EE_WARNING_3)
			lefttime = EE_warning_1
		else
			lefttime = (1 MINUTES)
	var/timewords = "[DisplayTimeText(lefttime, 1)]"
	var/words = "\"Attention everyone! Time to wind it down! We will be closing briefly for maintenance in around [timewords]. We'll be back in, oh, a few minutes after that!\""
	priority_announce(
		"[words]",
		"Bill Kelly, Maintenance Vixen:",
		'sound/effects/bweebweebwaa.ogg',
		null,
		"Foxy Bar - Hyperspatial PA System"
	)

/datum/controller/subsystem/autotransfer/proc/AnnounceEnd()
	priority_announce(
		"\"Attention everyone! We are now closed for maintenance. We will be back in a few minutes! Take care and see you then!\"",
		"Bill Kelly, Maintenance Vixen:",
		'sound/effects/bweebweebwaa.ogg',
		null,
		"Foxy Bar - Hyperspatial PA System"
	)


















	// if(maxvotes == NO_MAXVOTES_CAP || maxvotes > curvotes)
	// 	SSvote.initiate_vote("transfer","server")
	// 	targettime = targettime + voteinterval
	// 	curvotes++
	// else

#undef NO_MAXVOTES_CAP
