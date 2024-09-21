// IF you have linked your account, this will trigger a verify of the user
/*
/client/verb/verify_in_discord()
	set category = "OOC"
	set name = "Link Discord Account"
	set desc = "Verify your discord account with your BYOND account"

	// Safety checks
	if(!CONFIG_GET(flag/sql_enabled))
		to_chat(src, span_warning("This feature requires the SQL backend to be running."))
		return

	// Why this would ever be unset, who knows
	var/prefix = CONFIG_GET(string/discordbotcommandprefix)
	var/command = CONFIG_GET(string/verification_command)
	if(!prefix)
		to_chat(src, span_warning("This feature is disabled."))

	if(!SSdiscord || !SSdiscord.reverify_cache)
		to_chat(src, span_warning("Wait for the Discord subsystem to finish initialising"))
		return
	var/message = ""
	// Simple sanity check to prevent a user doing this too often
	var/cached_one_time_token = SSdiscord.reverify_cache[usr.ckey]
	if(cached_one_time_token && cached_one_time_token != "")
		message = "You already generated your one time token, it is \"[cached_one_time_token]\", if you need a new one, you will have to wait until the round ends, or switch to another server, try verifying yourself in discord by using the command <span class='warning'>\"[prefix]verify [cached_one_time_token]\"</span>"


	else
		var/datum/discord_link_record/existing_link = SSdiscord.find_discord_link_by_ckey(usr?.ckey, FALSE)
		//Do not create a new entry if they already have a linked account
		if(existing_link?.discord_id && existing_link?.valid)
			message = "You already have a linked account with discord ID ([existing_link.discord_id]) linked on [existing_link.timestamp]. If you desire to change your account please contact staff."
		// Will generate one if an expired one doesn't exist already, otherwise will grab existing token
		else
			var/one_time_token = SSdiscord.get_or_generate_one_time_token_for_ckey(ckey)
			SSdiscord.reverify_cache[usr.ckey] = one_time_token
			message = "Your one time token is: \"[one_time_token]\". You can now verify yourself in discord by using the command <span class='warning'>\"[prefix][command] [one_time_token]\"</span>"

	//Now give them a browse window so they can't miss whatever we told them
	if(CONFIG_GET(flag/forced_discord_stay))
		message += span_warning("Remember that to mantain verification you MUST stay in the discord server")
	var/datum/browser/window = new/datum/browser(usr, "discordverification", "Discord verification")
	window.set_content("<span>[message]</span>")
	window.open()
*/

