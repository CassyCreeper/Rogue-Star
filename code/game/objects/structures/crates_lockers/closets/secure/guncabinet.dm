#define GUNCABINET_SPACER 3


/obj/structure/closet/secure_closet/guncabinet
	name = "gun cabinet"
	icon = 'icons/obj/guncabinet.dmi'
	icon_state = "base"
	req_one_access = list(access_armory)
	closet_appearance = null

/obj/structure/closet/secure_closet/guncabinet/Initialize()
	. = ..()
	update_icon()

/obj/structure/closet/secure_closet/guncabinet/toggle()
	..()
	update_icon()

//VOREStation Add - gun context controls
/obj/structure/closet/secure_closet/guncabinet/open() //Don't dump everything to the floor, why would this be a good idea?
	if(opened)
		return FALSE
	if(!can_open())
		return FALSE
	opened = TRUE
	playsound(src, open_sound, 15, 1, -3)
	update_icon()
	return TRUE

/obj/structure/closet/secure_closet/guncabinet/close() //Don't auto scoop
	if(!opened)
		return FALSE
	if(!can_close())
		return FALSE
	opened = FALSE
	playsound(src, close_sound, 15, 1, -3)
	update_icon()
	return TRUE
//VOREStation Add End

/obj/structure/closet/secure_closet/guncabinet/update_icon()
	cut_overlays()
	if(opened)
		add_overlay("door_openold") //VOREStationEDIT all of these should be considered 'old' sprites, but keep backwards compatability.
	else
		var/lazors = 0
		var/shottas = 0
		for (var/obj/item/weapon/gun/G in contents)
			if (istype(G, /obj/item/weapon/gun/energy))
				lazors++
			if (istype(G, /obj/item/weapon/gun/projectile))
				shottas++
		for (var/i = 0 to 2)
			if(lazors || shottas) // only make icons if we have one of the two types.
				var/image/gun = image(icon(src.icon))
				if (lazors > shottas)
					lazors--
					gun.icon_state = "laserold"
				else if (shottas)
					shottas--
					gun.icon_state = "projectileold"
				gun.pixel_x = i*4
				add_overlay(gun)

		add_overlay("doorold")

		if(sealed)
			add_overlay("sealedold")

		if(broken)
			add_overlay("brokenold")
		else if (locked)
			add_overlay("lockedold")
		else
			add_overlay("openold")

//VOREStation Add Start
/obj/structure/closet/secure_closet/guncabinet/excursion
	name = "expedition weaponry cabinet"
	req_one_access = list(access_explorer,access_armory)

/obj/structure/closet/secure_closet/guncabinet/excursion/New()
	..()
	for(var/i = 1 to 2)
		new /obj/item/weapon/gun/energy/locked/frontier(src)
	for(var/i = 1 to 2)
		new /obj/item/weapon/gun/energy/locked/frontier/holdout(src)

//Fancier guncases
#define RACKONE 1
#define RACKTWO 2
#define RACKTHREE 3
#define RACKFOUR 4

#define GUN_SIDEARM	0
#define GUN_LONGARM	1
#define GUN_HEAVY	2


/obj/structure/closet/secure_closet/guncabinet/fancy
	name = "arms locker"
	icon_state = "shotguncase"
	desc = "A strong cabinet used for securing firearms."
	var/case_type = GUN_LONGARM
	var/welded = FALSE
	var/emagged = FALSE
	anchored = TRUE

	var/obj/item/weapon/gun/rackslot1
	var/obj/item/weapon/gun/rackslot2
	var/obj/item/weapon/gun/rackslot3
	var/obj/item/weapon/gun/rackslot4
	var/list/tgui_icons = list()
	var/list/guninfo = list()

/obj/structure/closet/secure_closet/guncabinet/fancy/proc/setTguiIcon(key, atom/A)
	if(!istype(A) || !key)
		return

	var/icon/F = getFlatIcon(A, defdir = SOUTH, no_anim = TRUE)
	tgui_icons["[key]"] = "'data:image/png;base64,[icon2base64(F)]'"
	SStgui.update_uis(src)

/obj/structure/closet/secure_closet/guncabinet/fancy/proc/nullTguiIcon(key)
	if(!key)
		return
	tgui_icons.Remove(key)
	SStgui.update_uis(src)

/obj/structure/closet/secure_closet/guncabinet/fancy/proc/clearTguiIcons()
	tgui_icons.Cut()
	SStgui.update_uis(src)

/obj/structure/closet/secure_closet/guncabinet/fancy/Destroy()
	QDEL_NULL(rackslot1)
	QDEL_NULL(rackslot2)
	QDEL_NULL(rackslot3)
	QDEL_NULL(rackslot4)
	clearTguiIcons()
	clearGunInfo()
	return ..()

/obj/structure/closet/secure_closet/guncabinet/fancy/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(issilicon(user) || isalien(user))
		return

	if(!Adjacent(user))
		return

	if(istype(W, /obj/item/weapon/gun) && opened)
		tgui_interact(user)

	if(istype(W, /obj/item/weapon/weldingtool) && !opened && locked)
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.remove_fuel(0, user))
			playsound(src, WT.usesound, 50, 1)
			user.visible_message("<span class='danger'>[user] begins cutting through [src]'s lock.</span>", "You start cutting through the lock.", "<span class='notice'>You hear a welder in use.</span>")
			if(do_after(user, (4 SECONDS) * WT.toolspeed))
				welded = TRUE
				opened = TRUE

	if(istype(W, /obj/item/weapon/melee/energy/blade) && !opened && locked)
		if(emag_act(INFINITY, user, "<span class='danger'>\The [src] has been sliced open by [user] with \an [W]</span>!", "<span class='danger'>You hear metal being sliced and sparks flying.</span>"))
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, loc)
			spark_system.start()
			playsound(src, 'sound/weapons/blade1.ogg', 50, 1)
			playsound(src, "sparks", 50, 1)
	else
		tgui_interact(user)

/obj/structure/closet/secure_closet/guncabinet/fancy/attack_hand(mob/user as mob)
	add_fingerprint(user)
	if(locked)
		togglelock(user)
	else
		toggle(user)


/obj/structure/closet/secure_closet/guncabinet/fancy/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GunLocker", name)
		ui.open()

/obj/structure/closet/secure_closet/guncabinet/fancy/tgui_status(mob/user)
	if(broken)
		return STATUS_CLOSE
	return ..()

/obj/structure/closet/secure_closet/guncabinet/fancy/tgui_data()
	var/list/data = list()

	data["welded"] = welded
	data["locked"] = locked
	data["emagged"] = emagged
	data["open"] = opened

	data["rackslot1"] =	rackslot1 ? capitalize(rackslot1.name) : null
	data["rackslot2"] =	rackslot2 ? capitalize(rackslot2.name) : null
	data["rackslot3"] =	rackslot3 ? capitalize(rackslot3.name) : null
	data["rackslot4"] =	rackslot4 ? capitalize(rackslot4.name) : null

	data["icons"] = tgui_icons
	data["guninfo"] = guninfo

	return data

/obj/structure/closet/secure_closet/guncabinet/fancy/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return TRUE

	usr.set_machine(src)
	add_fingerprint(usr)

	var/obj/item/I = usr.get_active_hand()
	var/obj/item/weapon/gun/W = I //Really just in case + helper.

	switch(action)
		if("open")
			toggle_open(usr)
			return TRUE
		if("lock")
			toggle_lock(usr)
			return TRUE

		if("rackslot1")
			if(!opened)
				to_chat(usr, "<span class='notice'[src] doors are closed.</span>")
				return
			if(rackslot1) //pull out the clicked slot, if there is one
				usr.put_in_hands(rackslot1)
				to_chat(usr, "<span class='notice'>You take [rackslot1.name] from [src].</span>")
				rackslot1 = null
				nullTguiIcon("rackslot1")
				nullGunInfo("rackslot1")
			else
				if(check_weapon(W)) //ain't one? try to shove the weapon in. Only returns true if it's a suitable gun
					usr.drop_from_inventory(W, src)
					rackslot1 = W
					setTguiIcon("rackslot1", rackslot1)
					get_ammo_status("rackslot1", rackslot1)
					update_icon()
					to_chat(usr, "<span class='notice'>You place [rackslot1.name] into [src]'s first slot.</span>")

		if("rackslot2")
			if(!opened)
				to_chat(usr, "<span class='notice'[src] doors are closed.</span>")
				return

			if(rackslot2)
				usr.put_in_hands(rackslot2)
				to_chat(usr, "<span class='notice'>You take [rackslot2.name] from [src].</span>")
				rackslot2 = null
				nullTguiIcon("rackslot2")
				nullGunInfo("rackslot2")
			else
				if(check_weapon(W))
					usr.drop_from_inventory(W, src)
					rackslot2 = W
					setTguiIcon("rackslot2", rackslot2)
					get_ammo_status("rackslot2", rackslot2)
					update_icon()
					to_chat(usr, "<span class='notice'>You place [rackslot2.name] into [src]'s second slot.</span>")

		if("rackslot3")
			if(!opened)
				to_chat(usr, "<span class='notice'[src] doors are closed.</span>")
				return
			if(rackslot3)
				usr.put_in_hands(rackslot3)
				to_chat(usr, "<span class='notice'>You take [rackslot3.name] from [src].</span>")
				rackslot3 = null
				nullTguiIcon("rackslot3")
				nullGunInfo("rackslot3")
			else
				if(check_weapon(W))
					usr.drop_from_inventory(W, src)
					rackslot3 = W
					setTguiIcon("rackslot3", rackslot3)
					get_ammo_status("rackslot3", rackslot3)
					update_icon()
					to_chat(usr, "<span class='notice'>You place [rackslot3.name] into [src]'s third slot.</span>")

		if("rackslot4")
			if(!opened)
				to_chat(usr, "<span class='notice'[src] doors are closed.</span>")
				return
			if(rackslot4)
				usr.put_in_hands(rackslot4)
				to_chat(usr, "<span class='notice'>You take [rackslot4.name] from [src].</span>")
				rackslot4 = null
				nullTguiIcon("rackslot4")
				nullGunInfo("rackslot4")
			else
				if(check_weapon(W))
					usr.drop_from_inventory(W, src)
					rackslot4 = W
					setTguiIcon("rackslot4", rackslot4)
					get_ammo_status("rackslot4", rackslot4)
					update_icon()
					to_chat(usr, "<span class='notice'>You place [rackslot4.name] into [src]'s fourth slot.</span>")
		else
			return FALSE

	update_icon()
	return TRUE

/obj/structure/closet/secure_closet/guncabinet/fancy/proc/toggle_open(mob/user as mob)
	if(locked)
		to_chat(user, "<font color='red'>It's locked.</font>")
		return
	opened = !opened
	SStgui.update_uis(src)
	return

/obj/structure/closet/secure_closet/guncabinet/fancy/proc/toggle_lock(mob/user as mob)
	if(opened || welded || emagged) //All of these states nullify the ability to lock the doors.
		return
	locked = !locked
	SStgui.update_uis(src)
	return

/obj/structure/closet/secure_closet/guncabinet/fancy/CtrlClick(mob/user)
	if(anchored)
		tgui_interact(user)
	else
		return

/obj/structure/closet/secure_closet/guncabinet/fancy/proc/nullGunInfo(key)
	if(!key)
		return
	guninfo.Remove(key)
	SStgui.update_uis(src)

/obj/structure/closet/secure_closet/guncabinet/fancy/proc/clearGunInfo()
	guninfo.Cut()
	SStgui.update_uis(src)

/obj/structure/closet/secure_closet/guncabinet/fancy/proc/check_weapon(atom/A)
	if(!istype(A))
		return FALSE
	var/obj/item/weapon/gun/W = A

	if(!istype(W))
		to_chat(usr, "<span class='notice'>You can't seem to fit [W] into [src].</span>")
		return FALSE

	if(W && (W.locker_class != case_type))
		to_chat(usr, "<span class='notice'>You can't seem to fit [W] into [src].</span>")
		return FALSE

	if(!opened)
		to_chat(usr, "<span class='notice'>You need to open the doors first.</span>")
		return FALSE

	return TRUE

/obj/structure/closet/secure_closet/guncabinet/fancy/proc/get_ammo_status(key, atom/A)
	var/list/gun = list()
	var/obj/item/weapon/gun/W = A
	if(W)
		gun.Add(list(list(
			"name" = capitalize(W.name),
			"charge" = W.get_ammo_count()
		)))
	guninfo["[key]"] = gun
	SStgui.update_uis(src)
	return TRUE

/obj/structure/closet/secure_closet/guncabinet/fancy/update_icon()
	cut_overlays()
	if(contents)
		for(var/i in 1 to contents.len)
			var/obj/item/weapon/gun/G = contents[i]
			var/mutable_appearance/gun_overlay = mutable_appearance(icon, G.overlay_type)
			gun_overlay.pixel_x = 0 //reset, just in case.
			if(rackslot1 && rackslot1 == G)
				gun_overlay.pixel_x = GUNCABINET_SPACER * (RACKONE - 1)
				add_overlay(gun_overlay)
			else if(rackslot2 && rackslot2 == G)
				gun_overlay.pixel_x = GUNCABINET_SPACER * (RACKTWO - 1)
				add_overlay(gun_overlay)
			else if(rackslot3 && rackslot3 == G)
				gun_overlay.pixel_x = GUNCABINET_SPACER * (RACKTHREE - 1)
				add_overlay(gun_overlay)
			else if(rackslot4 && rackslot4 == G)
				gun_overlay.pixel_x = GUNCABINET_SPACER * (RACKFOUR - 1)
				add_overlay(gun_overlay)
				//Probably a better way of doing this but my brain's smooth.

	if(welded && opened)
		add_overlay("[icon_state]_cut")
		layer = OBJ_LAYER
		return
	else if(welded && !opened)
		add_overlay("[icon_state]_doorcut")
		layer = OBJ_LAYER
		return
	else if(!welded && opened)
		add_overlay("[icon_state]_open")
		layer = OBJ_LAYER
		return
	else
		add_overlay("[icon_state]_door")
		if(emagged)
			add_overlay("[icon_state]_off")
			return
		else if(locked)
			add_overlay("[icon_state]_locked")
		else
			add_overlay("[icon_state]_unlocked")
		return

/obj/structure/closet/secure_closet/guncabinet/fancy/emag_act(var/remaining_charges, var/mob/user, var/feedback)
	if(!emagged)
		emagged = TRUE
		flick("[icon_state]_sparking",src)
		sleep(3)
		locked = FALSE
		to_chat(user, (feedback ? feedback : "You short out the lock of \the [src]."))
		update_icon()
		return TRUE

/obj/structure/closet/secure_closet/guncabinet/fancy/shotgun
	name = "long arms locker"
	icon_state = "shotguncase"

/obj/structure/closet/secure_closet/guncabinet/fancy/rifle
	name = "long arms locker"
	icon_state = "riflecase"
	desc = "A strong cabinet used for securing firearms. This one is for long arms such as rifles and shotguns."


/obj/structure/closet/secure_closet/guncabinet/fancy/rifle/wood
	icon_state = "riflefancy"


/obj/structure/closet/secure_closet/guncabinet/fancy/pistol
	name = "small arms locker"
	icon_state = "pistolcase"
	desc = "A strong cabinet used for securing firearms. This one is for hand-held sidearms."
	case_type = GUN_SIDEARM

/obj/structure/closet/secure_closet/guncabinet/fancy/pistol/wood
	icon_state = "fancypistol"

#undef RACKONE
#undef RACKTWO
#undef RACKTHREE
#undef RACKFOUR

#undef GUN_SIDEARM
#undef GUN_LONGARM
#undef GUN_HEAVY

#undef GUNCABINET_SPACER
//VOREStation Add End