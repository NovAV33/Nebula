/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

/mob
	var/hud_type = null
	var/datum/hud/hud_used = null

/mob/proc/InitializeHud()
	if(hud_used)
		qdel(hud_used)
	if(hud_type)
		hud_used = new hud_type(src)
	else
		hud_used = new /datum/hud(src)

/datum/hud
	var/mob/mymob

	var/hud_shown           = 1         //Used for the HUD toggle (F12)
	var/inventory_shown     = TRUE      //the inventory
	var/show_intent_icons   = FALSE
	var/hotkey_ui_hidden    = FALSE     //This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/obj/screen/lingchemdisplay
	var/list/hand_hud_objects
	var/obj/screen/action_intent
	var/obj/screen/move_intent
	var/obj/screen/stamina/stamina_bar

	var/list/adding
	var/list/other
	var/list/obj/screen/hotkeybuttons

	var/obj/screen/movable/action_button/hide_toggle/hide_actions_toggle
	var/action_buttons_hidden = FALSE

	var/static/list/hidden_inventory_slots = list(
		slot_head_str,
		slot_shoes_str,
		slot_l_ear_str,
		slot_r_ear_str,
		slot_gloves_str,
		slot_glasses_str,
		slot_w_uniform_str,
		slot_wear_suit_str,
		slot_wear_mask_str
	)

/datum/hud/New(mob/owner)
	mymob = owner
	instantiate()
	..()

/datum/hud/Destroy()
	. = ..()
	stamina_bar = null
	lingchemdisplay = null
	action_intent = null
	move_intent = null
	adding = null
	other = null
	hotkeybuttons = null
	mymob = null
	QDEL_NULL_LIST(hand_hud_objects)

/datum/hud/proc/update_stamina()
	if(mymob && stamina_bar)
		stamina_bar.invisibility = INVISIBILITY_MAXIMUM
		var/stamina = mymob.get_stamina()
		if(stamina < 100)
			stamina_bar.invisibility = 0
			stamina_bar.icon_state = "prog_bar_[FLOOR(stamina/5)*5][(stamina >= 5) && (stamina <= 25) ? "_fail" : null]"

/datum/hud/proc/hide_inventory()
	inventory_shown = FALSE
	hidden_inventory_update()
	persistant_inventory_update()

/datum/hud/proc/show_inventory()
	inventory_shown = TRUE
	hidden_inventory_update()
	persistant_inventory_update()

/datum/hud/proc/hidden_inventory_update()
	if(!mymob) return
	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob
		for(var/gear_slot in H.species.hud.gear)
			var/list/hud_data = H.species.hud.gear[gear_slot]
			if(inventory_shown && hud_shown)
				switch(hud_data["slot"])
					if(slot_head_str)
						if(H.head)      H.head.screen_loc =      hud_data["loc"]
					if(slot_shoes_str)
						if(H.shoes)     H.shoes.screen_loc =     hud_data["loc"]
					if(slot_l_ear_str)
						if(H.l_ear)     H.l_ear.screen_loc =     hud_data["loc"]
					if(slot_r_ear_str)
						if(H.r_ear)     H.r_ear.screen_loc =     hud_data["loc"]
					if(slot_gloves_str)
						if(H.gloves)    H.gloves.screen_loc =    hud_data["loc"]
					if(slot_glasses_str)
						if(H.glasses)   H.glasses.screen_loc =   hud_data["loc"]
					if(slot_w_uniform_str)
						if(H.w_uniform) H.w_uniform.screen_loc = hud_data["loc"]
					if(slot_wear_suit_str)
						if(H.wear_suit) H.wear_suit.screen_loc = hud_data["loc"]
					if(slot_wear_mask_str)
						if(H.wear_mask) H.wear_mask.screen_loc = hud_data["loc"]
			else
				switch(hud_data["slot"])
					if(slot_head_str)
						if(H.head)      H.head.screen_loc =      null
					if(slot_shoes_str)
						if(H.shoes)     H.shoes.screen_loc =     null
					if(slot_l_ear_str)
						if(H.l_ear)     H.l_ear.screen_loc =     null
					if(slot_r_ear_str)
						if(H.r_ear)     H.r_ear.screen_loc =     null
					if(slot_gloves_str)
						if(H.gloves)    H.gloves.screen_loc =    null
					if(slot_glasses_str)
						if(H.glasses)   H.glasses.screen_loc =   null
					if(slot_w_uniform_str)
						if(H.w_uniform) H.w_uniform.screen_loc = null
					if(slot_wear_suit_str)
						if(H.wear_suit) H.wear_suit.screen_loc = null
					if(slot_wear_mask_str)
						if(H.wear_mask) H.wear_mask.screen_loc = null


/datum/hud/proc/persistant_inventory_update()
	if(!mymob)
		return

	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob
		for(var/gear_slot in H.species.hud.gear)
			var/list/hud_data = H.species.hud.gear[gear_slot]
			if(hud_shown)
				switch(hud_data["slot"])
					if(slot_s_store_str)
						if(H.s_store) H.s_store.screen_loc = hud_data["loc"]
					if(slot_wear_id_str)
						if(H.wear_id) H.wear_id.screen_loc = hud_data["loc"]
					if(slot_belt_str)
						if(H.belt)    H.belt.screen_loc =    hud_data["loc"]
					if(slot_back_str)
						if(H.back)    H.back.screen_loc =    hud_data["loc"]
					if(slot_l_store_str)
						if(H.l_store) H.l_store.screen_loc = hud_data["loc"]
					if(slot_r_store_str)
						if(H.r_store) H.r_store.screen_loc = hud_data["loc"]
			else
				switch(hud_data["slot"])
					if(slot_s_store_str)
						if(H.s_store) H.s_store.screen_loc = null
					if(slot_wear_id_str)
						if(H.wear_id) H.wear_id.screen_loc = null
					if(slot_belt_str)
						if(H.belt)    H.belt.screen_loc =    null
					if(slot_back_str)
						if(H.back)    H.back.screen_loc =    null
					if(slot_l_store_str)
						if(H.l_store) H.l_store.screen_loc = null
					if(slot_r_store_str)
						if(H.r_store) H.r_store.screen_loc = null


/datum/hud/proc/instantiate()
	if(!ismob(mymob)) return 0
	if(!mymob.client) return 0
	var/ui_style = ui_style2icon(mymob.client.prefs.UI_style)
	var/ui_color = mymob.client.prefs.UI_style_color
	var/ui_alpha = mymob.client.prefs.UI_style_alpha
	FinalizeInstantiation(ui_style, ui_color, ui_alpha)

/datum/hud/proc/FinalizeInstantiation(var/ui_style, var/ui_color, var/ui_alpha)
	return

/datum/hud/proc/rebuild_hands(list/adding, list/removing, skip_client_update = FALSE)

	if(isnull(removing))
		if(!skip_client_update)
			mymob?.client?.screen -= hand_hud_objects
		QDEL_NULL_LIST(hand_hud_objects)
	else
		for(var/bp in removing)
			for(var/obj/screen/inventory/inv_box in hand_hud_objects)
				if(inv_box.slot_id == bp)
					if(mymob.client)
						mymob.client.screen -= inv_box
					hand_hud_objects -= inv_box
					qdel(inv_box)

	var/mob/living/target = mymob
	if(!istype(target))
		return

	if(isnull(adding))
		adding = target.held_item_slots

	var/ui_style = ui_style2icon(mymob.client?.prefs.UI_style)
	var/ui_color = mymob.client?.prefs?.UI_style_color
	var/ui_alpha = mymob.client?.prefs?.UI_style_alpha || 255
	for(var/bp in adding)
		var/obj/screen/inventory/inv_box
		for(var/obj/screen/inventory/existing_box in hand_hud_objects)
			if(existing_box.slot_id == bp)
				inv_box = existing_box
				break
		if(!inv_box)
			inv_box = new /obj/screen/inventory()
		var/datum/inventory_slot/inv_slot = target.held_item_slots[bp]
		inv_box.SetName(bp)
		inv_box.icon = ui_style
		inv_box.icon_state = "hand_base"

		inv_box.cut_overlays()
		inv_box.add_overlay("hand_[bp]")
		inv_box.add_overlay("hand_[inv_slot.ui_label]")
		if(target.get_active_held_item_slot() == bp)
			inv_box.add_overlay("hand_selected")
		inv_box.compile_overlays()

		inv_box.screen_loc = inv_slot.ui_loc
		inv_box.slot_id = bp
		inv_box.color = ui_color
		inv_box.alpha = ui_alpha
		inv_box.appearance_flags |= KEEP_TOGETHER

		LAZYADD(hand_hud_objects, inv_box)
		if(!skip_client_update)
			mymob.client?.screen |= inv_box

/mob/verb/minimize_hud(full = FALSE as null)
	set name = "Minimize Hud"
	set hidden = TRUE

	if(!hud_used)
		to_chat(usr, "<span class='warning'>This mob type does not use a HUD.</span>")
		return

	if(!ishuman(src))
		to_chat(usr, "<span class='warning'>Inventory hiding is currently only supported for human mobs, sorry.</span>")
		return

	if(!client) return
	if(client.view != world.view)
		return
	if(hud_used.hud_shown)
		hud_used.hud_shown = 0
		if(src.hud_used.adding)
			src.client.screen -= src.hud_used.adding
		if(src.hud_used.other)
			src.client.screen -= src.hud_used.other
		if(src.hud_used.hotkeybuttons)
			src.client.screen -= src.hud_used.hotkeybuttons

		//Due to some poor coding some things need special treatment:
		//These ones are a part of 'adding', 'other' or 'hotkeybuttons' but we want them to stay
		if(!full)
			src.client.screen += src.hud_used.hand_hud_objects	//we want the hands to be visible
			src.client.screen += src.hud_used.action_intent		//we want the intent swticher visible
			src.hud_used.action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.
		else
			src.client.screen -= src.healths
			src.client.screen -= src.internals
			src.client.screen -= src.gun_setting_icon

		//These ones are not a part of 'adding', 'other' or 'hotkeybuttons' but we want them gone.
		src.client.screen -= src.zone_sel	//zone_sel is a mob variable for some reason.

	else
		hud_used.hud_shown = 1
		if(src.hud_used.adding)
			src.client.screen += src.hud_used.adding
		if(src.hud_used.other && src.hud_used.inventory_shown)
			src.client.screen += src.hud_used.other
		if(src.hud_used.hotkeybuttons && !src.hud_used.hotkey_ui_hidden)
			src.client.screen += src.hud_used.hotkeybuttons
		if(src.healths)
			src.client.screen |= src.healths
		if(src.internals)
			src.client.screen |= src.internals
		if(src.gun_setting_icon)
			src.client.screen |= src.gun_setting_icon

		src.hud_used.action_intent.screen_loc = ui_acti //Restore intent selection to the original position
		src.client.screen += src.zone_sel				//This one is a special snowflake

	hud_used.hidden_inventory_update()
	hud_used.persistant_inventory_update()
	update_action_buttons()

//Similar to minimize_hud() but keeps zone_sel, gun_setting_icon, and healths.
/mob/proc/toggle_zoom_hud()
	if(!hud_used)
		return
	if(!ishuman(src))
		return
	if(!client)
		return
	if(client.view != world.view)
		return

	if(hud_used.hud_shown)
		hud_used.hud_shown = 0
		if(src.hud_used.adding)
			src.client.screen -= src.hud_used.adding
		if(src.hud_used.other)
			src.client.screen -= src.hud_used.other
		if(src.hud_used.hotkeybuttons)
			src.client.screen -= src.hud_used.hotkeybuttons
		src.client.screen -= src.internals
		src.client.screen += src.hud_used.action_intent		//we want the intent swticher visible
	else
		hud_used.hud_shown = 1
		if(src.hud_used.adding)
			src.client.screen += src.hud_used.adding
		if(src.hud_used.other && src.hud_used.inventory_shown)
			src.client.screen += src.hud_used.other
		if(src.hud_used.hotkeybuttons && !src.hud_used.hotkey_ui_hidden)
			src.client.screen += src.hud_used.hotkeybuttons
		if(src.internals)
			src.client.screen |= src.internals
		src.hud_used.action_intent.screen_loc = ui_acti //Restore intent selection to the original position

	hud_used.hidden_inventory_update()
	hud_used.persistant_inventory_update()
	update_action_buttons()

/mob/proc/add_click_catcher()
	client.screen |= get_click_catchers()

/mob/new_player/add_click_catcher()
	return

/obj/screen/stamina
	name = "stamina"
	icon = 'icons/effects/progressbar.dmi'
	icon_state = "prog_bar_100"
	invisibility = INVISIBILITY_MAXIMUM
	screen_loc = ui_stamina
