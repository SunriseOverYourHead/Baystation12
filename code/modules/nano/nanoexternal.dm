 // This file contains all Nano procs/definitions for external classes/objects

 /**
  * Called when a Nano UI window is closed
  * This is how Nano handles closed windows
  * It must be a verb so that it can be called using winset
  *
  * @return nothing
  */
/client/verb/nanoclose(uiref as text)
	set hidden = 1	// hide this verb from the user's panel
	set name = "nanoclose"

	var/datum/nanoui/ui = locate(uiref)

	if (istype(ui))
		ui.close()

		if(ui.ref)
			var/href = "close=1"
			src.Topic(href, params2list(href), ui.ref)	// this will direct to the atom's Topic() proc via client.Topic()
		else if (ui.on_close_logic)
			// no atomref specified (or not found)
			// so just reset the user mob's machine var
			if(src && src.mob)
				src.mob.unset_machine()

// open_uis is defined on /datum by the TGUI external module (external.dm)
// and is inherited by /mob, so no redefinition needed here.
