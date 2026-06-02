#define NO_SCREEN 0
#define CHANGE_SECURITY_LEVEL 1
#define TRANSFER_FUNDS 2
#define VIEW_TRANSACTION_LOGS 3

/obj/item/card/id/var/money = 2000

/obj/machinery/atm
	name = "automatic teller machine"
	desc = "For all your monetary needs!"
	icon = 'icons/obj/machines/terminals.dmi'
	icon_state = "atm"
	anchored = TRUE
	idle_power_usage = 10
	var/datum/money_account/authenticated_account
	var/number_incorrect_tries = 0
	var/previous_account_number = 0
	var/max_pin_attempts = 3
	var/ticks_left_locked_down = 0
	var/ticks_left_timeout = 0
	var/machine_id = ""
	var/obj/item/card/id/held_card
	var/editing_security_level = 0
	var/view_screen = NO_SCREEN
	var/datum/effect/spark_spread/spark_system
	var/account_security_level = 0

/obj/machinery/atm/New()
	..()
	machine_id = "[station_name()] ATM #[num_financial_terminals++]"
	spark_system = new /datum/effect/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/machinery/atm/Process()
	if(!is_powered())
		return

	if(ticks_left_timeout > 0)
		ticks_left_timeout--
		if(ticks_left_timeout <= 0)
			authenticated_account = null
	if(ticks_left_locked_down > 0)
		ticks_left_locked_down--
		if(ticks_left_locked_down <= 0)
			number_incorrect_tries = 0

	for(var/obj/item/spacecash/S in src)
		S.dropInto(loc)
		if(prob(50))
			playsound(loc, 'sound/items/polaroid1.ogg', 50, 1)
		else
			playsound(loc, 'sound/items/polaroid2.ogg', 50, 1)
		break

/obj/machinery/atm/emag_act(remaining_charges, mob/user)
	if(!emagged)
		//short out the machine, shoot sparks, spew money!
		emagged = TRUE
		spark_system.start()
		spawn_money(rand(100,500),src.loc)
		//we don't want to grief people by locking their id in an emagged ATM
		release_held_id(user)

		//display a message to the user
		var/response = pick("Initiating withdraw. Have a nice day!", "CRITICAL ERROR: Activating cash chamber panic siphon.","PIN Code accepted! Emptying account balance.", "Jackpot!")
		to_chat(user, "[icon2html(src, user)] [SPAN_WARNING("[src] beeps: \"[response]\"")]")
		return 1

/obj/machinery/atm/use_tool(obj/item/I, mob/living/user, list/click_params)
	if(isid(I))
		if (emagged)
			to_chat(user, "[icon2html(src, user)] [SPAN_WARNING("CARD READER ERROR. This system has been compromised!")]")
			return TRUE
		if(!is_powered())
			to_chat(user, "You try to insert your card into [src], but nothing happens.")
			return TRUE
		if (held_card)
			to_chat(user, "\The [src] already contains a card in the reader.")
			return TRUE

		var/obj/item/card/id/idcard = I
		if(!user.unEquip(idcard, src))
			return TRUE
		held_card = idcard
		if(authenticated_account && held_card.associated_account_number != authenticated_account.account_number)
			authenticated_account = null
		attack_hand(user)
		return TRUE

	if (authenticated_account)
		if(istype(I,/obj/item/spacecash))
			var/obj/item/spacecash/dolla = I
			if(authenticated_account.deposit(dolla.worth, "Credit deposit", machine_id))
				if(prob(50))
					playsound(loc, 'sound/items/polaroid1.ogg', 50, 1)
				else
					playsound(loc, 'sound/items/polaroid2.ogg', 50, 1)

				to_chat(user, SPAN_INFO("You insert \the [I] into \the [src]."))
				attack_hand(user)
				qdel(I)
				return TRUE
	return ..()


/obj/machinery/atm/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/atm/ui_interact(mob/user, datum/tgui/ui)
	if(istype(user, /mob/living/silicon))
		to_chat(user, "[icon2html(src, user)] [SPAN_WARNING("Artificial unit recognized. Artificial units do not currently receive monetary compensation, as per system banking regulation #1005.")]")
		return
	ui = tgui_interact(user, src, "ATM", machine_id, ui)
	ui.set_autoupdate(TRUE)
	ui.open()

/obj/machinery/atm/ui_data(mob/user)
	var/list/data = list(
		"machine_id" = machine_id,
		"emagged" = emagged,
		"is_locked" = ticks_left_locked_down > 0,
		"has_card" = !!held_card,
		"card_name" = held_card?.name,
		"authenticated" = !!authenticated_account,
		"currency" = GLOB.using_map.local_currency_name_short,
		"account_security_level" = account_security_level,
		"view_screen" = view_screen,
		"attempts_remaining" = max(0, max_pin_attempts - number_incorrect_tries)
	)
	if(authenticated_account)
		data["account_name"] = authenticated_account.owner_name
		data["account_number"] = authenticated_account.account_number
		data["balance"] = authenticated_account.money
		data["account_suspended"] = authenticated_account.suspended
		data["security_level"] = authenticated_account.security_level
		if(view_screen == VIEW_TRANSACTION_LOGS)
			var/list/logs = list()
			for(var/datum/transaction/T in authenticated_account.transaction_log)
				logs += list(list(
					"date" = T.date,
					"time" = T.time,
					"target" = T.get_target_name(),
					"purpose" = T.purpose,
					"amount" = T.amount,
					"source" = T.get_source_name()
				))
			data["transaction_logs"] = logs
	return data

/obj/machinery/atm/ui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("insert_card")
			if(!held_card)
				if(emagged)
					to_chat(usr, "[icon2html(src, usr)] [SPAN_WARNING("The ATM card reader rejected your ID because this machine has been sabotaged!")]")
				else
					var/obj/item/I = usr.get_active_hand()
					if(istype(I, /obj/item/card/id))
						if(!usr.unEquip(I, src))
							return
						held_card = I
						if(authenticated_account && held_card.associated_account_number != authenticated_account.account_number)
							authenticated_account = null
			else
				release_held_id(usr)
			. = TRUE
		if("attempt_auth")
			var/obj/item/card/id/login_card = held_card
			if(!login_card)
				login_card = scan_user(usr)
			if(!ticks_left_locked_down)
				var/tried_account_num = text2num(params["account_num"])
				if(!tried_account_num && login_card && account_security_level != 2)
					tried_account_num = login_card.associated_account_number
				var/tried_pin = text2num(params["account_pin"])
				if(tried_account_num)
					var/datum/money_account/D = get_account(tried_account_num)
					if(D)
						account_security_level = D.security_level
				authenticated_account = attempt_account_access(tried_account_num, tried_pin, held_card && login_card?.associated_account_number == tried_account_num ? 2 : 1)
				if(!authenticated_account)
					number_incorrect_tries++
					if(previous_account_number == tried_account_num && tried_pin)
						if(number_incorrect_tries >= max_pin_attempts)
							ticks_left_locked_down = 30
							playsound(src, 'sound/machines/buzz-two.ogg', 50, 1)
							var/datum/money_account/failed_account = get_account(tried_account_num)
							if(failed_account)
								failed_account.log_msg("Unauthorized login attempt", machine_id)
						else
							to_chat(usr, "[icon2html(src, usr)] [SPAN_WARNING("Incorrect pin/account combination, [max_pin_attempts - number_incorrect_tries] attempt(s) remaining.")]")
							previous_account_number = tried_account_num
							playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 1)
					else
						to_chat(usr, "[icon2html(src, usr)] [SPAN_WARNING("Unable to log in. Additional information may be required.")]")
						number_incorrect_tries = 0
				else
					playsound(src, 'sound/machines/twobeep.ogg', 50, 1)
					ticks_left_timeout = 120
					view_screen = NO_SCREEN
					authenticated_account.log_msg("Remote terminal access", machine_id)
					to_chat(usr, "[icon2html(src, usr)] [SPAN_INFO("Access granted. Welcome, [authenticated_account.owner_name].")]")
				previous_account_number = tried_account_num
			. = TRUE
		if("logout")
			authenticated_account = null
			account_security_level = 0
			. = TRUE
		if("set_view")
			view_screen = text2num(params["screen"])
			. = TRUE
		if("change_security_level")
			if(authenticated_account)
				authenticated_account.security_level = clamp(text2num(params["level"]), 0, 2)
			. = TRUE
		if("transfer")
			if(authenticated_account && !authenticated_account.suspended)
				var/amount = round(max(text2num(params["amount"]), 0), 0.01)
				var/target_num = text2num(params["target"])
				var/purpose = params["purpose"] || "Funds transfer"
				if(amount > 0 && amount <= authenticated_account.money)
					var/datum/money_account/target = get_account(target_num)
					if(target && authenticated_account.transfer(target, amount, purpose))
						to_chat(usr, "[icon2html(src, usr)][SPAN_INFO("Funds transfer successful.")]")
					else
						to_chat(usr, "[icon2html(src, usr)][SPAN_WARNING("Funds transfer failed.")]")
				else
					to_chat(usr, "[icon2html(src, usr)][SPAN_WARNING("Invalid amount or insufficient funds.")]")
			. = TRUE
		if("withdraw")
			if(authenticated_account && !authenticated_account.suspended)
				var/amount = round(max(text2num(params["amount"]), 0), 0.01)
				if(amount > 0)
					if(authenticated_account.withdraw(amount, "Credit withdrawal", machine_id))
						playsound(src, 'sound/machines/chime.ogg', 50, 1)
						spawn_money(amount, src.loc, usr)
					else
						to_chat(usr, "[icon2html(src, usr)][SPAN_WARNING("Insufficient funds.")]")
			. = TRUE
		if("e_withdraw")
			if(authenticated_account && !authenticated_account.suspended)
				var/amount = round(max(text2num(params["amount"]), 0), 0.01)
				if(amount > 0)
					if(authenticated_account.withdraw(amount, "Credit withdrawal", machine_id))
						playsound(src, 'sound/machines/chime.ogg', 50, 1)
						spawn_ewallet(amount, src.loc, usr)
					else
						to_chat(usr, "[icon2html(src, usr)][SPAN_WARNING("Insufficient funds.")]")
			. = TRUE
		if("balance_statement")
			if(authenticated_account)
				var/obj/item/paper/R = new(src.loc)
				R.SetName("Account balance: [authenticated_account.owner_name]")
				R.info = "<b>Automated Teller Account Statement</b><br><br>"
				R.info += "<i>Account holder:</i> [authenticated_account.owner_name]<br>"
				R.info += "<i>Account number:</i> [authenticated_account.account_number]<br>"
				R.info += "<i>Balance:</i> [GLOB.using_map.local_currency_name_short][authenticated_account.money]<br>"
				R.info += "<i>Date and time:</i> [stationtime2text()], [stationdate2text()]<br><br>"
				R.info += "<i>Service terminal ID:</i> [machine_id]<br>"
				var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
				stampoverlay.icon_state = "paper_stamp-boss"
				if(!R.stamped) R.stamped = new
				R.stamped += /obj/item/stamp
				R.AddOverlays(stampoverlay)
				R.stamps += "<HR><i>This paper has been stamped by the Automatic Teller Machine.</i>"
				if(prob(50)) playsound(loc, 'sound/items/polaroid1.ogg', 50, 1)
				else playsound(loc, 'sound/items/polaroid2.ogg', 50, 1)
			. = TRUE
		if("print_transaction")
			if(authenticated_account)
				var/obj/item/paper/R = new(src.loc)
				R.SetName("Transaction logs: [authenticated_account.owner_name]")
				R.info = "<b>Transaction logs</b><br>"
				R.info += "<i>Account holder:</i> [authenticated_account.owner_name]<br>"
				R.info += "<i>Account number:</i> [authenticated_account.account_number]<br>"
				R.info += "<i>Date and time:</i> [stationtime2text()], [stationdate2text()]<br><br>"
				R.info += "<i>Service terminal ID:</i> [machine_id]<br>"
				R.info += "<table border=1 style='width:100%'><tr><td><b>Date</b></td><td><b>Time</b></td><td><b>Target</b></td><td><b>Purpose</b></td><td><b>Value</b></td><td><b>Terminal</b></td></tr>"
				for(var/datum/transaction/T in authenticated_account.transaction_log)
					R.info += "<tr><td>[T.date]</td><td>[T.time]</td><td>[T.get_target_name()]</td><td>[T.purpose]</td><td>[GLOB.using_map.local_currency_name_short][T.amount]</td><td>[T.get_source_name()]</td></tr>"
				R.info += "</table>"
				var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
				stampoverlay.icon_state = "paper_stamp-boss"
				if(!R.stamped) R.stamped = new
				R.stamped += /obj/item/stamp
				R.AddOverlays(stampoverlay)
				R.stamps += "<HR><i>This paper has been stamped by the Automatic Teller Machine.</i>"
				if(prob(50)) playsound(loc, 'sound/items/polaroid1.ogg', 50, 1)
				else playsound(loc, 'sound/items/polaroid2.ogg', 50, 1)
			. = TRUE


/obj/machinery/atm/proc/scan_user(mob/living/carbon/human/human_user as mob)
	if(!authenticated_account)
		var/obj/item/card/id/I = human_user.GetIdCard()
		if(istype(I))
			return I

// put the currently held id on the ground or in the hand of the user
/obj/machinery/atm/proc/release_held_id(mob/living/carbon/human/human_user as mob)
	if(!held_card)
		return

	held_card.dropInto(loc)
	authenticated_account = null
	account_security_level = 0

	if(ishuman(human_user) && !human_user.get_active_hand())
		human_user.put_in_hands(held_card)
	held_card = null


/obj/machinery/atm/proc/spawn_ewallet(sum, loc, mob/living/carbon/human/human_user as mob)
	var/obj/item/spacecash/ewallet/E = new /obj/item/spacecash/ewallet(loc)
	if(ishuman(human_user) && !human_user.get_active_hand())
		human_user.put_in_hands(E)
	E.worth = sum
	E.owner_name = authenticated_account.owner_name
