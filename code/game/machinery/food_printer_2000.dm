/obj/structure/food_printer
	name = "GekkerTec FoodFox 2000"
	desc = "A high-tech kitchen appliance that can produce a variety of food items. For free! Live! Over the internet!"
	icon = 'icons/obj/food_printer.dmi'
	icon_state = "default"
	density = TRUE
	/// the food menu to use
	var/datum/food_menu/menu
	/// currently selected output
	var/datum/weakref/foutput
	/// list of food items to be printed
	var/list/worklist = list()
	var/working = FALSE
	var/paused = FALSE
	var/datum/looping_sound/foodprinter_1/sl_1
	var/datum/looping_sound/foodprinter_2/sl_2
	var/target_beacon
	var/last_new_beacon = 0
	var/list/usage_log = list()

	var/obj/item/pda/moviefone
	var/list/calls = list()
	var/list/orders_in_progress = list()

/obj/structure/food_printer/Initialize()
	. = ..()
	menu = SSfood_printer.food_menu
	GeneratePDA()
	new /obj/item/foodprinter_output_beacon(GetNearestTable(src, 2, TRUE))
	sl_1 = new /datum/looping_sound/foodprinter_1(list(src), FALSE)
	sl_2 = new /datum/looping_sound/foodprinter_2(list(src), FALSE)
	START_PROCESSING(SSfood_printer, src)

/obj/structure/food_printer/Destroy()
	. = ..()
	CancelAllOrders()
	QDEL_NULL(moviefone)
	menu = null
	STOP_PROCESSING(SSfood_printer, src)

/obj/structure/food_printer/proc/GeneratePDA()
	if(moviefone)
		return
	moviefone = new /obj/item/pda(src)
	moviefone.owner = "GekkerTec FoodFox 2000 \[0x[random_color()]\]"
	moviefone.name = moviefone.owner
	moviefone.ownjob = "Automated Delivery System"
	moviefone.ttone = "Ack-Ack!"
	RegisterSignal(moviefone, COMSIG_PDA_RECEIVE_MESSAGE, PROC_REF(WasMessaged))

/obj/structure/food_printer/proc/AddPrintJob(FoodKey, amount, mob/user, beacon_override, datum/phone_order/assoc_order)
	if(!menu)
		menu = SSfood_printer.food_menu
	var/datum/food_menu_entry/food = SSfood_printer.food_menu.foods[FoodKey]
	if(!food)
		return
	var/datum/food_printer_workorder/work = new /datum/food_printer_workorder(src, user)
	work.SetMenuItem(food, amount)
	work.SetOutput(beacon_override || target_beacon)
	if(assoc_order)
		work.AssociateOrder(assoc_order)
	worklist += work
	say("Okay! [work.printing.name] is being printed! It will be ready in about [work.GetTimeLeftString()]!", only_overhead = TRUE)
	playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 50, TRUE)
	if(user)
		if(LAZYLEN(worklist) == 1)
			update_static_data(user)

/obj/structure/food_printer/proc/BeaconKey2Output(beacon_key)
	var/obj/item/foodprinter_output_beacon/beac = LAZYACCESS(SSfood_printer.food_printer_outputs, beacon_key)
	if(!beac)
		return GetNearestTable(src, 2, TRUE)
	return beac.GetOutput(src, null)

/obj/structure/food_printer/proc/StartWorking()
	working = TRUE
	sl_1.start()
	sl_2.start()

/obj/structure/food_printer/proc/StopWorking()
	working = FALSE
	sl_1.stop()
	sl_2.stop()

/obj/structure/food_printer/proc/WorkFinished(datum/food_printer_workorder/work, success)
	worklist -= work
	qdel(work)
	if(LAZYLEN(worklist))
		return
	StopWorking()
	if(success)
		FinishedEverything()

/obj/structure/food_printer/proc/FinishedEverything()
	playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 50, TRUE)
	say("All done!", only_overhead = TRUE)

/// the loop that goes through all the work orders and works on them, one by one
/obj/structure/food_printer/process()
	if(paused)
		return
	var/datum/food_printer_workorder/work = LAZYACCESS(worklist, 1)
	if(work)
		if(!working)
			StartWorking()
		if(!work.in_progress)
			work.Start()
			if(work.associated_order)
				var/datum/phone_order/order = orders_in_progress[work.associated_order]
				order.StartingOrder()
		work.TickTime()
		if(work.timeleft <= 0)
			work.Stop()
			FinalizeWork(work)
	else
		if(working)
			StopWorking()
	// now, handle our calls
	for(var/datum/phone_relay/relay in calls)
		if(relay.CanSend())
			if(relay.is_beacon_request)
				var/obj/item/foodprinter_output_beacon/beac = MakeNewBeacon()
				if(beac)
					TeleportFood(beac, get_turf(GET_WEAKREF(relay.targetpda))) // not food, but it'll food
					SendMessage(relay)
			else
				SendMessage(relay)
			calls -= relay
			qdel(relay)
	// now, handle our orders
	for(var/oname in orders_in_progress)
		var/datum/phone_order/order = orders_in_progress[oname]
		if(!order.order_confirmed)
			continue
		if(!order.order_queued)
			AddPrintJob(order.food.food_key, order.amount, extract_mob(order.customer_ckey), order.target_beacon, order)
			order.order_queued = TRUE
		if(order.fully_done)
			CancelPhoneOrder(order)


/obj/structure/food_printer/proc/CancelOrder(FoodKey)
	for(var/datum/food_printer_workorder/work in worklist)
		if(work.mytag == FoodKey)
			say("Okay! [work.printing.name] is no longer being printed!", only_overhead = TRUE)
			playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 50, TRUE)
			work.Stop()
			WorkFinished(work, FALSE)

/obj/structure/food_printer/proc/CancelAllOrders()
	for(var/datum/food_printer_workorder/work in worklist)
		work.Stop()
		WorkFinished(work, null)
	say("Okay! All orders cancelled!", only_overhead = TRUE)
	playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 50, TRUE)

/obj/structure/food_printer/proc/TogglePause()
	paused = !paused
	if(paused)
		say("Okay! Pausing all orders!", only_overhead = TRUE)
		playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 50, TRUE)
	else
		say("Okay! Resuming all orders!", only_overhead = TRUE)
		playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 50, TRUE)
	
/obj/structure/food_printer/proc/SetTargetBeacon(beacon_key)
	if(SSfood_printer.food_printer_outputs[beacon_key])
		target_beacon = beacon_key
	else
		target_beacon = null
	
/obj/structure/food_printer/proc/MakeNewBeacon()
	if(world.time < last_new_beacon + (5 SECONDS))
		say("Hold your horses! I'm still looking for another beacon!", only_overhead = TRUE)
		playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 50, TRUE)
		return
	last_new_beacon = world.time
	var/obj/item/foodprinter_output_beacon/beac = new /obj/item/foodprinter_output_beacon(GetNearestTable(src, 2, TRUE))
	say("A new beacon has been created! Be sure to name it!", only_overhead = TRUE)
	playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 50, TRUE)
	return beac

/obj/structure/food_printer/proc/LogFoodPrint(datum/food_printer_workorder/work, user_ckey, atom/dest)
	if(!user_ckey)
		return
	var/log = list()
	log["Time"] = world.time
	log["UserCkey"] = user_ckey
	log["FoodKey"] = work.printing.food_key
	log["Amount"] = work.amt
	log["Beacon"] = work.output_name
	if(isbelly(dest)) // mainly for this, in case people send un-asked-for things to someone's voregan
		log["IsBelly"] = TRUE
	else
		log["IsBelly"] = FALSE
	usage_log += list(log)

/obj/structure/food_printer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "FoodPrinter")
		ui.open()

/// our stuff thats constantly changing!
/obj/structure/food_printer/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	var/list/workdata = list()
	for(var/datum/food_printer_workorder/work in worklist)
		workdata += list(work.data_for_tgui())
	data["WorkOrders"] = workdata
	var/list/beacons = list()
	for(var/beacid in SSfood_printer.food_printer_outputs)
		var/obj/item/foodprinter_output_beacon/beac = SSfood_printer.food_printer_outputs[beacid]
		beacons += "[beac.beacon_name]QOSXZOVVVZZZZZZHHHHH&!&!&!&!&![beac.beacon_id]"
	beacons = sort_list(beacons)
	var/list/truebeacons = list()
	for(var/bacon in beacons)
		var/list/beac = splittext(bacon, "QOSXZOVVVZZZZZZHHHHH&!&!&!&!&!") // im coder
		var/list/beacdat = list()
		beacdat["DisplayName"] = beac[1]
		beacdat["BeaconID"] = beac[2]
		truebeacons += list(beacdat)
	data["Beacons"] = truebeacons
	data["SelectedBeacon"] = target_beacon
	return data

/// The menu!
/obj/structure/food_printer/ui_static_data(mob/user)
	var/list/data = list()
	data["EntriesPerPage"] = SSfood_printer.entries_per_page
	data["FoodMenuList"] = SSfood_printer.food_menu.TGUI_chunk
	data["FullFoodMenu"] = SSfood_printer.food_menu.full_TGUI_chunk
	data["CoolTip"] = pick(SSfood_printer.tips)
	data["Tagline"] = pick(SSfood_printer.taglines)
	return data

/obj/structure/food_printer/ui_act(action, params)
	. = ..()
	var/mob/user = usr
	switch(action)
		if("PrintFood")
			var/datum/food_menu_entry/food = SSfood_printer.food_menu.foods[params["FoodKey"]]
			if(!food)
				say("Oh! I can't seem to find that recipe! Maybe it's expired?")
				playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 50, TRUE)
				return
			var/howmany = numberfy(params["Amount"])
			howmany = clamp(howmany, 1, SSfood_printer.max_food_print)
			AddPrintJob(food.food_key, howmany, user)
		if("CancelOrder")
			CancelOrder(params["FoodKey"])
		if("CancelAllOrders")
			CancelAllOrders()
		if("Pause")
			TogglePause()
		if("SetTargetBeacon")
			SetTargetBeacon(params["BeaconKey"])
		if("NewBeacon")
			MakeNewBeacon()

/obj/structure/food_printer/proc/FinalizeWork(datum/food_printer_workorder/work)
	if(!work || !work.printing)
		return
	var/turf/dest = get_turf(src)
	if(!dest)
		return
	var/turf/first_dest = GetNearestTable(dest, 2, TRUE)
	var/is_tele
	// worklist's output thing can be a beacon ID, an atom, or nothing at all!
	var/b_id = work.output_tag
	if(b_id)
		var/obj/item/foodprinter_output_beacon/beac = SSfood_printer.food_printer_outputs[b_id]
		if(beac)
			dest = beac.GetOutput(src, work.printing)
			is_tele = TRUE
	else if(isweakref(work.foutput))
		var/atom/thing = GET_WEAKREF(work.foutput)
		if(thing)
			dest = thing
			if(get_dist(dest, get_turf(src)) > 2)
				is_tele = TRUE
	else if(isatom(work.foutput))
		var/atom/thing = work.foutput
		dest = thing
		if(get_dist(dest, get_turf(src)) > 2)
			is_tele = TRUE
	else
		dest = GetNearestTable(dest, 5, TRUE)
		if(get_dist(dest, get_turf(src)) > 2)
			is_tele = TRUE

	var/isvore = isbelly(dest)
	if(!isvore)
		dest = get_turf(dest)
	var/quiet = FALSE
	for(var/i in 1 to work.amt)
		var/obj/item/food
		if(is_tele)
			food = new work.printing.itempath(first_dest)
			TeleportFood(food, dest, quiet)
			quiet = TRUE
		else
			food = new work.printing.itempath(first_dest)
			food.forceMove(dest)
	if(isvore)
		var/obj/vore_belly/belly = dest
		var/mob/owner = belly.owner
		to_chat(owner, span_notice("Oh! Something just appeared in your [belly.name]!"))
	if(work.associated_order)
		var/datum/phone_order/order = orders_in_progress[work.associated_order]
		order.OrderComplete()
	LogFoodPrint(work, work.ckeywhodidit, dest)
	WorkFinished(work, TRUE)
	playsound(src, 'sound/weapons/energy_chargedone_ding.ogg', 95, TRUE)

/obj/structure/food_printer/proc/TeleportFood(atom/movable/food, atom/put_herre, silent)
	if(!food)
		return
	if(!silent)
		playsound(get_turf(food), 'sound/effects/claim_thing.ogg', 100)
		playsound(get_turf(put_herre), 'sound/effects/claim_thing.ogg', 100)
	var/obj/effect/afterimage = new(get_turf(food))
	food.forceMove(put_herre)

	/// image of the food item teleporting out
	afterimage.appearance = food.appearance
	var/matrix/M = food.transform.Scale(1, 3)
	animate(afterimage, transform = M, pixel_y = 32, time = 10, alpha = 50, easing = CIRCULAR_EASING, flags=ANIMATION_PARALLEL)
	M.Scale(0,4)
	animate(transform = M, time = 5, color = "#1111ff", alpha = 0, easing = CIRCULAR_EASING)
	QDEL_IN(afterimage, 2 SECONDS)

/obj/structure/food_printer/proc/WasMessaged(datum/source, datum/rental_mommy/pda/pda)
	if(!moviefone)
		return
	var/datum/phone_order/order
	// okay, parse the message for any key words
	if(findtextEx(pda.message, "CANCEL ORDER"))
		order = orders_in_progress[pda.name]
		if(!order)
			QueueMessage(pda.sender_pda, "I'm sorry, you don't have an order in progress! Please try again!", quick = TRUE)
			return
	if(findtextEx(pda.message, "NEW ORDER"))
		// okay, we have an order!
		if(orders_in_progress[pda.name])
			QueueMessage(pda.sender_pda, "I'm sorry, you already have an order in progress! Please wait for it to finish (or cancel by replying: CANCEL ORDER) before placing a new order!")
			return
		QueueMessage(pda.sender_pda, "New order started! Please standby for further instructions!", quick = TRUE)
		order = new /datum/phone_order(src, pda)
		orders_in_progress[pda.name] = order
		order.ParseMessage(pda.message)
		return // it'll handle the rest
	// from here, we try to parse for help stuff
	if(findtextEx(pda.message, "HELP ORDER"))
		HelpOrder(pda)
		return
	if(findtextEx(pda.message, "SEND ME A BEACON"))
		SendBeacon(pda)
		return
	if(findtextEx(pda.message, "LIST BEACONS"))
		ListBeacons(pda)
		return
	if(findtextEx(pda.message, "FIND"))
		var/str = replacetext(pda.message, "FIND", "")
		SearchForFood(pda, str)
		return
	// now try and fulfill the order
	order = orders_in_progress[pda.name]
	if(order)
		if(order.ParseMessage(pda.message))
			return
	SendHello(pda)

/obj/structure/food_printer/proc/SendHello(datum/rental_mommy/pda/pda)
	var/list/message = list()
	message += "Hello! You have reached the GekkerTec FoodFox 2000 hotline! Tasty food, live, over the internet!"
	message += "For more information on how to order food, please respond with: HELP ORDER."
	message += "To receive a beacon for your food, please respond with: SEND ME A BEACON."
	message += "To search for a specific food item, please respond with: FIND and the name of the food item."
	message += "For more information on how to use the GekkerTec FoodFox 2000, please respond with: HELP."
	QueueMessage(pda.sender_pda, message.Join("\n"))

/obj/structure/food_printer/proc/HelpOrder(datum/rental_mommy/pda/pda)
	var/list/message = list()
	message += "To order food from this GekkerTec FoodFox 2000, simply respond with: NEW ORDER."
	message += "The automated assistant will guide you through the process of selecting a food item and the amount you'd like to order."
	message += "Once you've placed your order, the GekkerTec FoodFox 2000 will begin preparing your food item."
	message += "You will receive a message when your food is ready for intergalactic supertransfer."
	message += "If you'd like to cancel an order, please respond with: CANCEL ORDER."
	QueueMessage(pda.sender_pda, message.Join("\n"))

/obj/structure/food_printer/proc/ListBeacons(datum/rental_mommy/pda/pda)
	var/list/message = list()
	message += "The following beacons are available for use with the GekkerTec FoodFox 2000:"
	for(var/beacid in SSfood_printer.food_printer_outputs)
		var/obj/item/foodprinter_output_beacon/beac = SSfood_printer.food_printer_outputs[beacid]
		message += "[beac.beacon_name]"
	message += "To use a beacon, you will need to have an active order. To start an order, please respond with: NEW ORDER"
	QueueMessage(pda.sender_pda, message.Join("\n"))

/obj/structure/food_printer/proc/SearchForFood(datum/rental_mommy/pda/pda, str)
	var/list/founds = list()
	for(var/fentry in SSfood_printer.food_menu.foods)
		var/datum/food_menu_entry/fme = SSfood_printer.food_menu.foods[fentry]
		if(findtext(fme.name, str))
			founds += fme
	if(!founds)
		QueueMessage(pda.sender_pda, "I'm sorry, I couldn't find any food items containing '[str]'. Please try again!")
		return
	if(LAZYLEN(founds) > 25)
		founds.len = 25
	var/list/message = list()
	message += "I have found the following food items containing '[str]':"
	for(var/datum/food_menu_entry/fme in founds)
		message += "#[fme.disambiguator] [fme.name]"
	message += "When ordering, please use the full number on the far left. For example: #1030"
	QueueMessage(pda.sender_pda, message.Join("\n"))

/obj/structure/food_printer/proc/SendBeacon(datum/rental_mommy/pda/pda)
	QueueMessage(pda.sender_pda, "Attempting to send you a new Beacon! If one does not arrive, please try again later!", TRUE)

/obj/structure/food_printer/proc/QueueMessage(obj/item/pda/pda, message, is_beacon, quick)
	var/delay = 3 SECONDS
	if(quick)
		delay = 1 SECONDS
	var/datum/phone_relay/relay = new /datum/phone_relay(message, pda, delay, is_beacon)
	calls += relay

/obj/structure/food_printer/proc/SendMessage(datum/phone_relay/relay)
	if(!moviefone)
		return
	if(!relay)
		return
	var/obj/item/pda/target = GET_WEAKREF(relay.targetpda)
	if(!target)
		return
	moviefone.send_message(null, list(target), FALSE, relay.message) // whether or not it gets there is no longer our concern
	playsound(src, 'sound/machines/terminal_select.ogg', 50, TRUE)

/obj/structure/food_printer/proc/CancelPhoneOrder(datum/phone_order/po)
	if(!po)
		return
	if(istype(po))
		orders_in_progress -= po.key_id
		qdel(po)
	if(istext(po))
		po = orders_in_progress[po]
		orders_in_progress -= po.key_id
		qdel(po)

/// something to let us write down something to reply to someone with, later
/datum/phone_relay
	var/message
	var/datum/weakref/targetpda
	var/when_to_send
	var/is_beacon_request

/datum/phone_relay/New(msg, obj/item/pda/pda, delay, is_beacon)
	message = msg
	targetpda = WEAKREF(pda)
	when_to_send = world.time + delay
	is_beacon_request = is_beacon

/datum/phone_relay/proc/CanSend()
	return world.time >= when_to_send

//////////////////////////////////////////////////////////////////////
// Phone Order! /////////////////////////////////////////////////////
/datum/phone_order
	var/obj/structure/food_printer/food_printer
	var/datum/weakref/target_pda
	var/datum/food_menu_entry/food
	var/amount = 1
	var/target_beacon
	var/target_beacon_name
	var/customer_name
	var/customer_ckey
	var/customer_quid
	var/list/possible_beacons = list()
	var/order_confirmed = FALSE
	var/order_queued = FALSE
	var/in_progress = FALSE
	var/fully_done = FALSE
	var/key_id

/datum/phone_order/New(printer, datum/rental_mommy/pda/pda)
	key_id = pda.name
	food_printer = printer
	target_pda = WEAKREF(pda.sender_pda)
	customer_name = pda.name
	customer_ckey = pda.senderckey
	customer_quid = pda.senderquid

/datum/phone_order/Destroy()
	food_printer = null
	target_pda = null
	food = null
	. = ..()

/// OKAY FAT LISTEN UP
/// We need to extract three things from the message:
/// 1. The food item they want
/// 2. The amount of that food item they want
/// 3. The beacon they want the food item to be sent to
/// Chances are they arent all gonna be in the same message, but we can try!
/// a successful order would look like...
/// ORDER #1304 X5 SENDTO DANK STAX
/// Though if we start an order, and dont get what we want out of them in the first try, we can keep asking for more info
/datum/phone_order/proc/ParseMessage(msg)
	if(findtext(msg, "CANCEL ORDER"))
		food_printer.QueueMessage(GET_WEAKREF(target_pda), "Your order has been cancelled!", quick = TRUE)
		food_printer.CancelPhoneOrder(src)
		return TRUE
	if(findtext(msg, "CONFIRM ORDER") && food && amount && target_beacon)
		ActuallyOrder()
		return TRUE
	if(findtext(msg, "ORDER INFO"))
		SendOrderInfo()
		return TRUE
	var/list/orderQ = list()
	var/list/words = splittext(msg, " ")
	for(var/word in words)
		if(findtext(word, "#")) // menu number, maybe!
			var/str = replacetext(word, "#", "")
			var/foundit = FALSE
			for(var/fentry in SSfood_printer.food_menu.foods)
				var/datum/food_menu_entry/fme = SSfood_printer.food_menu.foods[fentry]
				if(fme.disambiguator == str)
					food = fme
					foundit = TRUE
					break
			if(foundit)
				orderQ += "You have selected: [food.name] (#[food.disambiguator])"
			else
				orderQ += "I'm sorry, I couldn't find a food item with the number #[str]. Please try again!"
		if(copytext(word, 1, 2) == "X" && isnum(numberfy(copytext(word, 2, 0)))) // amount, maybe!
			var/str = replacetext(word, "X", "")
			amount = numberfy(str)
			amount = clamp(amount, 1, SSfood_printer.max_food_print)
			orderQ += "You have selected: [amount] orders."
			. = TRUE
		if(findtext(word, "SENDTO")) // beacon, maybe!
			// this one is a bit more complicated, because it can be a partial match
			// but, the beacon name is always after the word SENDTO
			// so we can just grab everything after that
			var/list/xploded = splittext(msg, "SENDTO")
			if(LAZYLEN(xploded) == 2)
				var/str = trim(xploded[2])
				if(!str)
					continue // we clearly dont have a beacon name
				var/numbo = 1
				for(var/beacid in SSfood_printer.food_printer_outputs)
					var/obj/item/foodprinter_output_beacon/beac = SSfood_printer.food_printer_outputs[beacid]
					if(findtext(beac.beacon_name, str))
						var/list/diambig = list()
						diambig["BeaconID"] = beac.beacon_id
						diambig["BeaconName"] = beac.beacon_name
						diambig["DisNumber"] = "[numbo++]"
						possible_beacons += list(diambig)
						. = TRUE
				if(LAZYLEN(possible_beacons) == 1)
					target_beacon = possible_beacons[1]["BeaconID"]
					target_beacon_name = possible_beacons[1]["BeaconName"]
					possible_beacons = list()
					orderQ += "You have selected: [target_beacon_name] as your destination."
					. = TRUE
				else if(LAZYLEN(possible_beacons) > 1)
					orderQ += "I found multiple beacons that match your request. Please standby for a message to disambiguate."
					. = TRUE
				else
					orderQ += "I'm sorry, I couldn't find a beacon with the name '[str]'. Please try again!"
					. = TRUE
		if(findtext(word, "DISAMBIGUATE")) // disambiguation, maybe!
			// Same as above, but we need to find the number they want
			var/list/xploded = splittext(msg, "DISAMBIGUATE")
			if(LAZYLEN(xploded) == 2)
				var/str = trim(xploded[2])
				var/foundit = FALSE
				for(var/list/diambig in possible_beacons)
					if(diambig["DisNumber"] == str)
						target_beacon = diambig["BeaconID"]
						target_beacon_name = diambig["BeaconName"]
						possible_beacons = list()
						orderQ += "You have selected: [target_beacon_name] as your destination."
						foundit = TRUE
						. = TRUE
						break
				if(!foundit)
					orderQ += "I'm sorry, I couldn't find a beacon with the number '[str]'. Please try again!"
					. = TRUE
			else
				orderQ += "I'm sorry, I didn't understand your disambiguation request. Please try again!"
	if(orderQ)
		food_printer.QueueMessage(GET_WEAKREF(target_pda), orderQ.Join("\n"))
	if(!food)
		AskForFood()
		return TRUE
	if(!amount)
		AskForAmount()
		return TRUE
	if(!target_beacon)
		if(LAZYLEN(possible_beacons) > 1)
			DisambiguateBeacon()
			return TRUE
		AskForBeacon()
		return TRUE
	// okay, now we need to check if we got everything we need
	if(food && amount && target_beacon)
		ConfrimOrder()
		return TRUE

/datum/phone_order/proc/AskForFood()
	var/list/message = list()
	message += "What food item would you like to order? Please respond with the number of the food item you'd like to order."
	message += "For example, if you'd like to order the food item 'Bepis', and the number is 1304, you would respond with: #1304"
	message += "If you'd like to search for a specific food item, please respond with: FIND and a partial or full name of the food item, or the number."
	message += "Note that food item indexes start at #1000 and go up from there."
	food_printer.QueueMessage(GET_WEAKREF(target_pda), message.Join("\n"))

/datum/phone_order/proc/AskForAmount()
	var/list/message = list()
	message += "How many of the food item would you like to order? Please respond with the number of food items you'd like to order."
	message += "For example, if you'd like to order 5 of the food item, you would respond with: X5"
	food_printer.QueueMessage(GET_WEAKREF(target_pda), message.Join("\n"))

/datum/phone_order/proc/DisambiguateBeacon()
	var/list/message = list()
	message += "I found multiple beacons that match your request."
	for(var/diambig in possible_beacons)
		message += "[diambig["DisNumber"]] [diambig["BeaconName"]]"
	message += "For example, if you'd like to use the beacon 'Dank Stax', and the number is 1, you would respond with: DISAMBIGUATE 1"
	food_printer.QueueMessage(GET_WEAKREF(target_pda), message.Join("\n"))

/datum/phone_order/proc/AskForBeacon()
	var/list/message = list()
	message += "Where would you like your food item to be sent? Please respond with the name of the beacon you'd like to use."
	message += "For example, if you'd like to use the beacon 'Dank Stax', you would respond with: SENDTO Dank Stax"
	message += "If you'd like to see a list of available beacons, please respond with: LIST BEACONS"
	message += "If you'd like a new beacon sent to you, please respond with: SEND ME A BEACON"
	message += "A full name is not required, but the more specific you are, the better!"
	food_printer.QueueMessage(GET_WEAKREF(target_pda), message.Join("\n"))

/datum/phone_order/proc/ConfrimOrder()
	var/list/message = list()
	message += "You have ordered [amount] of [food.name] to be sent to [target_beacon_name]."
	message += "If this is correct, please respond with CONFIRM ORDER."
	message += "If you'd like to cancel this order, please respond with CANCEL ORDER."
	food_printer.QueueMessage(GET_WEAKREF(target_pda), message.Join("\n"))

/datum/phone_order/proc/ActuallyOrder()
	food_printer.QueueMessage(GET_WEAKREF(target_pda), "Your order has been placed! Your food item will be ready soon!", quick = TRUE)
	order_confirmed = TRUE
	// it'll handle the rest

/datum/phone_order/proc/StartingOrder()
	var/list/message = list()
	in_progress = TRUE
	message += "Your order is being created! Your meal will be delivered soon!"
	food_printer.QueueMessage(GET_WEAKREF(target_pda), message.Join("\n"))

/datum/phone_order/proc/OrderComplete()
	var/list/message = list()
	fully_done = TRUE
	message += "Your order has been delivered! Thank you for using the GekkerTec FoodFox 2000, we hope you have a very FoodFox day!"
	food_printer.QueueMessage(GET_WEAKREF(target_pda), message.Join("\n"))

/datum/phone_order/proc/SendOrderInfo()
	var/list/message = list()
	message += "Here is a summary of your order:"
	if(food)
		message += "Food Item: [food.name]"
	else
		message += "Food Item: Not yet selected"
		message += "To select a food item, please respond with: # and the number of the food item you'd like to order, for example: #1304"
	if(amount)
		message += "Amount: [amount]"
	else
		message += "Amount: Not yet selected"
		message += "To select an amount, please respond with: X and the number of food items you'd like to order, for example: X5"
	if(target_beacon)
		message += "Beacon: [target_beacon]"
	else
		message += "Beacon: Not yet selected"
		message += "To select a beacon, please respond with: SENDTO and the name of the beacon you'd like to use, for example: SENDTO Dank Stax"
	food_printer.QueueMessage(GET_WEAKREF(target_pda), message.Join("\n"))







/datum/food_printer_workorder
	var/datum/food_menu_entry/printing
	var/datum/weakref/printer
	var/datum/weakref/foutput
	var/output_tag
	var/output_name
	var/totaltime = 1
	var/timeleft = 0
	var/last_tick = 0
	var/in_progress = FALSE
	var/amt = 1
	var/mytag
	var/ckeywhodidit
	var/quidwhodidit
	var/associated_order

/datum/food_printer_workorder/New(obj/structure/food_printer, mob/doer)
	mytag = "FUPA-[rand(1000,9999)]-[rand(1000,9999)]-BEPIS"
	printer = WEAKREF(food_printer)
	if(doer)
		ckeywhodidit = extract_ckey(doer)
		quidwhodidit = SSeconomy.extract_quid(doer)
	. = ..()

/datum/food_printer_workorder/Destroy()
	. = ..()
	printing = null
	printer = null
	foutput = null
	Stop()

/datum/food_printer_workorder/proc/AssociateOrder(datum/phone_order/order)
	associated_order = order.key_id

/datum/food_printer_workorder/proc/SetMenuItem(datum/food_menu_entry/food, amount)
	printing = food
	amt = clamp(amount, 1, SSfood_printer.max_food_print)
	timeleft = printing.print_time
	if(amt > 1)
		// extra items take longer to print, but not linearly
		timeleft = timeleft * sqrt(amt) // sure
	totaltime = max(timeleft, 1) // i fear division by zero

/datum/food_printer_workorder/proc/SetOutput(atom/dest)
	if(isatom(dest))
		foutput = GET_WEAKREF(dest)
		output_tag = null
		output_name = null
	else
		var/obj/item/foodprinter_output_beacon/beac = SSfood_printer.food_printer_outputs[dest]
		if(beac)
			foutput = GET_WEAKREF(beac)
			output_tag = beac.beacon_id
			output_name = beac.beacon_name
		else
			foutput = null
			output_tag = null
			output_name = null

/datum/food_printer_workorder/proc/Start()
	in_progress = TRUE

/datum/food_printer_workorder/proc/Stop()
	in_progress = FALSE

/datum/food_printer_workorder/proc/GetTimeLeft()
	return timeleft

/datum/food_printer_workorder/proc/GetTimeLeftString()
	var/timeleft = GetTimeLeft()
	return DisplayTimeText(timeleft, 0.1, TRUE, TRUE)

/datum/food_printer_workorder/proc/GetTimeLeftPercent()
	var/timeleft = GetTimeLeft()
	return 100 - ((timeleft / totaltime) * 100)

/datum/food_printer_workorder/proc/TickTime()
	if(!last_tick)
		last_tick = world.time
		return
	var/now = world.time
	var/delta = now - last_tick
	last_tick = now
	timeleft -= delta
	if(timeleft <= 0)
		timeleft = 0

/datum/food_printer_workorder/proc/data_for_tgui()
	var/list/data = list()
	data["Name"] = printing.name || "Food"
	data["Description"] = printing.desc || "No description available."
	data["OutputTag"] = output_tag || "Right here!"
	data["TimeLeft"] = GetTimeLeftString()
	data["TimeLeftPercent"] = GetTimeLeftPercent()
	data["Amount"] = amt
	data["MyTag"] = mytag
	return data

//////////////////////////////////////////////////////////////////////
// Food Beacon - The Beacon of the Future ////////////////////////////
/obj/item/foodprinter_output_beacon
	name = "Food Beacon"
	desc = "This thing is used by the GekkerTec FoodFox 2000 to deliver food items. \
		That's right, the GekkerTec FoodFox 2000 will teleport food to you, any time, \
		any place! For free! Live! Over the internet!\n\
		\n\
		To use, squeeze (click) it in hand, then select a helpful name that the GekkerTec FoodFox 2000 will use to identify it. \
		Then, have whoever's using the GekkerTec FoodFox 2000 select the beacon in the food printer's output menu. \
		Then, the GekkerTec FoodFox 2000 will teleport whatever it prints out to the beacon's location."
	icon = 'icons/obj/food_printer.dmi'
	icon_state = "beacon"
	var/beacon_name = "Bepis"
	var/beacon_id = "BEPIS"

/obj/item/foodprinter_output_beacon/Initialize()
	. = ..()
	RandomName()
	RandomID()
	SSfood_printer.food_printer_outputs[beacon_id] = src

/obj/item/foodprinter_output_beacon/Destroy()
	. = ..()
	SSfood_printer.food_printer_outputs -= beacon_id

/obj/item/foodprinter_output_beacon/attack_self(mob/user)
	. = ..()
	SetName(user)

/obj/item/foodprinter_output_beacon/proc/RandomID()
	beacon_id = "CHIARA-[rand(1000,9999)]-IS-[rand(1000,9999)]-FAT-[rand(1000,9999)]"

/obj/item/foodprinter_output_beacon/proc/SetName(mob/setter)
	if(!setter || !setter.client)
		return RandomName()
	var/newname = input(
		setter,
		"Enter a name for the beacon. This is what will show up in the GekkerTec FoodFox 2000's output menu, so make it something helpful, like your name, or some kind of big shark! 64 characters max, please!",
		"Name 4 Me",
		"[beacon_name]") as text|null
	if(isnull(newname))
		return
	if(!newname)
		RandomName()
	else
		beacon_name = copytext(newname, 1, 64)
	UpdateName()
	to_chat(setter, span_notice("The beacon's name has been set to [beacon_name]."))

/obj/item/foodprinter_output_beacon/proc/RandomName()
	beacon_name = "[safepick(GLOB.megacarp_first_names)] [safepick(GLOB.megacarp_last_names)]"
	UpdateName()

/obj/item/foodprinter_output_beacon/proc/UpdateName()
	name = "[initial(name)] - '[beacon_name]'"

/obj/item/foodprinter_output_beacon/proc/GetOutput(mob/printer, obj/item/food)
	if(isturf(loc))
		return loc
	if(isbelly(loc))
		return loc // =3
	if(SEND_SIGNAL(loc, COMSIG_CONTAINS_STORAGE)) // try and stuff it in there
		if(SEND_SIGNAL(loc, COMSIG_TRY_STORAGE_CAN_INSERT, food, printer, TRUE))
			return loc
	return GetNearestTable(get_turf(src), 5)

/proc/GetNearestTable(atom/place, maxdist = 5, torf)
	if(!place)
		return
	var/list/tables = list()
	for(var/obj/structure/table/T in view(maxdist, get_turf(place)))
		tables += T
	if(!tables)
		return torf ? get_turf(place) : place
	var/closest_dist = 999999
	var/obj/structure/table/closest_table
	for(var/obj/structure/table/T in tables)
		var/dist = GET_DIST_EUCLIDEAN(place, T)
		if(dist < closest_dist)
			closest_dist = dist
			closest_table = T
	if(closest_table)
		if(torf)
			return get_turf(closest_table)
		return closest_table
	return torf ? get_turf(place) : place






















