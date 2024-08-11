
/** Open new islands menu
 */
function openNewIslandsMenu =
(
	--format "\n"; print ".openNewIslandsMenu()"
	/* DEFINE MAIN MENU */
	Menu = RcMenu_v name:"TestMenu"

	Menu.item "Select Lowest Verts" "selectFirstVerts(#LOWEST_VERT)"
	Menu.item "Select New Islands" "selectFirstVerts(#NEW_ISLAND)"
	Menu.item "Select Big Islands" "selectIslandsBySize(#BIG)"
	Menu.item "Select Islands" "selectFirstVerts(#WHOLE_ISLAND)"
	Menu.item "SHOW SELECTED" "createIslandManagerDialog relaunch:true"

	--if method != #SET then
	--	Menu.item item_title	( "macros.run" + "\"" + category + "\"" + "\"" + macro_name + "\""	) -- macros.run "_Epoly-Vertex-Color" "color_set_by_selection"
	--
	--Menu.item "&RED"	( call_fn + "red"	)
	--Menu.item "&GREEN"	( call_fn + "green"	)
	--Menu.item "&BLUE"	( call_fn + " " + COLOR_NAMES[#BLUE] as string	)
	--Menu.item "&ORANGE"	( call_fn + "orange"	)
	--Menu.item "&PINK"	( call_fn + " " + COLOR_NAMES[#PINK] as string	)
	--Menu.item "&WHITE"	( call_fn + "white"	)


	popUpMenu (Menu.create())

)

