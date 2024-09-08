filein( getFilenamePath(getSourceFileName()) + "/islandsRcMenuCallbacks.ms" )	--"./islandsRcMenuCallbacks.ms"

/** Open new islands menu
 */
function openNewIslandsMenu =
(
	--format "\n"; print ".openNewIslandsMenu()"

	/* DEFINE MAIN MENU */
	Menu = RcMenu_v name:"IslandsMenu"

	listbox_items_count = DIALOG_island_manager.ML_island_listbox.items.count
	listbox_selection = DIALOG_island_manager.ML_island_listbox.selection


	/* ADD ITEMS */
	if listbox_selection.numberSet != listbox_items_count then
		Menu.item "Select All"	"::IslandsRcMenuCallbacks_v.selectAllIslandsInListbox()"

	if (verts_sel = getVertSelection selection[1].mesh ).numberSet > 0 then
		Menu.item "Select Islands by verts"	"::IslandsRcMenuCallbacks_v.selectIslandsByVerts()"

	--Menu.item "Select Lowest Verts"	"::IslandsRcMenuCallbacks_v.selectVertsOfIslands(#LOWEST_VERT)"
	--Menu.item "Select New Islands"	"::IslandsRcMenuCallbacks_v.selectVertsOfIslands(#NEW_ISLAND)"

	Menu.separator()

	Menu.item "Select whole Islands"	"::IslandsRcMenuCallbacks_v.selectVertsOfIslands(#WHOLE_ISLAND)"
	Menu.item "Remove selected islands"	"::IslandsRcMenuCallbacks_v.removeSelectedIslands()"

	Menu.separator()

	Menu.item "Select SMALL Islands"	"::IslandsRcMenuCallbacks_v.selectIslandsBySize(#SMALL)"
	Menu.item "Select MEDIUM Islands"	"::IslandsRcMenuCallbacks_v.selectIslandsBySize(#MEDIUM)"
	Menu.item "Select BIG Islands"	"::IslandsRcMenuCallbacks_v.selectIslandsBySize(#BIG)"

	Menu.separator()

	if listbox_selection.numberSet > 1 and listbox_items_count > 0 then
		Menu.item "Show ONLY selected" "createIslandManagerDialog relaunch:true"


	if listbox_items_count < ISLANDS_SYSTEM.islands_data.count then
		Menu.item "Show ALL" "createIslandManagerDialog()"

	popUpMenu (Menu.create())
)