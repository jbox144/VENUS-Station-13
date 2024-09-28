/proc/exploration_announce(text, z_value)
	var/announcement = "<meta charset='UTF-8'>"
	announcement += "<h1 class='alert'>[command_name()] Update</h1>"
	announcement += "<br><span class='alert'>[html_encode(text)]</span><br>"
	announcement += "<br>"
