//Giant Beds
/obj/structure/bed/double/big

/obj/structure/bed/double/huge

/obj/structure/bed/double/mega

/obj/structure/bed/double/big/Initialize()
    ..()
    transform = transform.Scale(2)
    update_icon()

/obj/structure/bed/double/huge/Initialize()
    ..()
    transform = transform.Scale(3)
    update_icon()

// /obj/structure/bed/double/mega/Initialize()
//     ..()
//     transform = matrix(9,0,0,0,9,0)
//     update_icon()

/obj/structure/bed/double/big/post_buckle_mob(mob/living/M as mob)
    if(M.buckled == src)
        M.pixel_y = (25 + pixel_y)
        M.old_y = (25 + pixel_y)
        M.pixel_x = (pixel_x)
        M.old_x = (pixel_x)
    else
        M.pixel_y = 0
        M.old_y = 0
        M.pixel_x = 0
        M.old_x = 0

/obj/structure/bed/double/huge/post_buckle_mob(mob/living/M as mob)
    if(M.buckled == src)
        M.pixel_y = (37 + pixel_y)
        M.old_y = (37 + pixel_y)
        M.pixel_x = (pixel_x)
        M.old_x = (pixel_x)
    else
        M.pixel_y = 0
        M.old_y = 0
        M.pixel_x = 0
        M.old_x = 0

// /obj/structure/bed/double/mega/post_buckle_mob(mob/living/M as mob)
//     if(M.buckled == src)
//         M.pixel_y = (109 + pixel_y)
//         M.old_y = (109 + pixel_y)
//         M.pixel_x = (pixel_x)
//         M.old_x = (pixel_x)
//     else
//         M.pixel_y = 0
//         M.old_y = 0
//         M.pixel_x = 0
//         M.old_x = 0

//Bed sheets


/obj/item/bedsheet/big/Initialize()
	. = ..()
	transform = transform.Scale(2)
	update_icon()

/obj/item/bedsheet/huge/Initialize()
	. = ..()
	transform = transform.Scale(3)
	update_icon()

/obj/item/bedsheet/big/deerdouble
	name = "deer bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "deer_double"

/obj/item/bedsheet/huge/deerdouble
	name = "deer bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "deer_double"

/obj/item/bedsheet/big/doubletranspride
	name = "transpride bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doubletranspride"

/obj/item/bedsheet/huge/doubletranspride
	name = "transpride bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doubletranspride"

/obj/item/bedsheet/big/doublepanpride
	name = "panpride bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublepanpride"

/obj/item/bedsheet/huge/doublepanpride
	name = "panpride bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublepanpride"

/obj/item/bedsheet/big/doublebipride
	name = "bipride bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublebipride"

/obj/item/bedsheet/huge/doublebipride
	name = "bipride bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublebipride"

/obj/item/bedsheet/big/doublenonbinpride
	name = "NBpride bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublenonbinpride"

/obj/item/bedsheet/huge/doublenonbinpride
	name = "NBpride bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublenonbinpride"

/obj/item/bedsheet/big/doublesheetcaptain
	name = "royal blue bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetcaptain"

/obj/item/bedsheet/huge/doublesheetcaptain
	name = "royal blue bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetcaptain"

/obj/item/bedsheet/big/doublesheetce
	name = "fancy yellow bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetce"

/obj/item/bedsheet/huge/doublesheetce
	name = "fancy yellow bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetce"

/obj/item/bedsheet/big/doublesheethop
	name = "fancy blue bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheethop"

/obj/item/bedsheet/huge/doublesheethop
	name = "fancy blue bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheethop"

/obj/item/bedsheet/big/doublesheetorange
	name = "orange bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetorange"

/obj/item/bedsheet/huge/doublesheetorange
	name = "orange bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetorange"

/obj/item/bedsheet/big/doublesheetrainbow
	name = "rainbow bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetrainbow"

/obj/item/bedsheet/huge/doublesheetrainbow
	name = "rainbow bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetrainbow"

/obj/item/bedsheet/big/doublesheethos
	name = "fancy red bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheethos"

/obj/item/bedsheet/huge/doublesheethos
	name = "fancy red bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheethos"

/obj/item/bedsheet/big/doublesheet
	name = "white bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheet"

/obj/item/bedsheet/huge/doublesheet
	name = "white bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheet"

/obj/item/bedsheet/big/doublesheetgreen
	name = "green bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetgreen"

/obj/item/bedsheet/huge/doublesheetgreen
	name = "green bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetgreen"

/obj/item/bedsheet/big/doublesheetpurple
	name = "purple bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetpurple"

/obj/item/bedsheet/huge/doublesheetpurple
	name = "purple bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetpurple"

/obj/item/bedsheet/big/doublesheetclown
	name = "clown bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetclown"

/obj/item/bedsheet/huge/doublesheetclown
	name = "clown bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetclown"

/obj/item/bedsheet/big/doublesheetian
	name = "ian bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetian"

/obj/item/bedsheet/huge/doublesheetian
	name = "ian bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetian"

/obj/item/bedsheet/big/doublesheetrd
	name = "royal red bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetrd"

/obj/item/bedsheet/huge/doublesheetrd
	name = "royal red bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetrd"

/obj/item/bedsheet/big/doublesheetmime
	name = "mime bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetmime"

/obj/item/bedsheet/huge/doublesheetmime
	name = "mime bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetmime"

/obj/item/bedsheet/big/doublesheetblue
	name = "blue bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetblue"

/obj/item/bedsheet/huge/doublesheetblue
	name = "blue bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetblue"

/obj/item/bedsheet/big/doublesheetred
	name = "red bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetred"

/obj/item/bedsheet/huge/doublesheetred
	name = "red bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetred"

/obj/item/bedsheet/big/doublesheetbrown
	name = "brown bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetbrown"

/obj/item/bedsheet/huge/doublesheetbrown
	name = "brown bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetbrown"

/obj/item/bedsheet/big/doublesheetyellow
	name = "yellow bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetyellow"

/obj/item/bedsheet/huge/doublesheetyellow
	name = "yellow bedsheet"
	icon = 'modular_coyote/icons/objects/bedsheets.dmi'
	icon_state = "doublesheetyellow"
