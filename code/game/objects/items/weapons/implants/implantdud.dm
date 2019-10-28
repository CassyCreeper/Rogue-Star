/obj/item/weapon/implant/dud
	name = "unknown implant"
	desc = "A small device with small connector wires."
	icon = 'icons/obj/device.dmi'
	icon_state = "implant"
	initialize_loc = BP_HEAD
	var/roundstart = TRUE

/obj/item/weapon/implant/dud/torso
	name = "unknown implant"
	desc = "A small device with small connector wires."
	icon = 'icons/obj/device.dmi'
	icon_state = "implant"
	initialize_loc = BP_TORSO

/obj/item/weapon/implant/dud/old
	name = "old implant"
	desc = "A small device with small connector wires."
	icon = 'icons/obj/device.dmi'
	icon_state = "implant"
	roundstart = FALSE

/obj/item/weapon/implant/dud/Initialize()
	..()
	if(roundstart)
		invisibility = 100
		..()
		spawn(3)
			if(!ishuman(loc) && !QDELETED(src))
				qdel(src)
