

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
		Menu.item "Select All"	"ISLANDS_SYSTEM.selectAllIslandsInListbox()"

	if (verts_sel = polyop.getVertSelection selection[1]).numberSet > 0 then
		Menu.item "Select Islands by verts"	"ISLANDS_SYSTEM.selectIslandsByVerts()"

	--Menu.item "Select Lowest Verts"	"ISLANDS_SYSTEM.selectVertsOfIslands(#LOWEST_VERT)"
	--Menu.item "Select New Islands"	"ISLANDS_SYSTEM.selectVertsOfIslands(#NEW_ISLAND)"

	Menu.separator()

	Menu.item "Select SMALL Islands"	"ISLANDS_SYSTEM.selectIslandsBySize(#SMALL)"
	Menu.item "Select MEDIUM Islands"	"ISLANDS_SYSTEM.selectIslandsBySize(#MEDIUM)"
	Menu.item "Select BIG Islands"	"ISLANDS_SYSTEM.selectIslandsBySize(#BIG)"

	Menu.separator()

	Menu.item "Select whole Islands"	"ISLANDS_SYSTEM.selectVertsOfIslands(#WHOLE_ISLAND)"
	Menu.item "Remove selected islands"	"ISLANDS_SYSTEM.removeSelectedIslands()"

	Menu.separator()

	if listbox_selection.numberSet > 1 and listbox_items_count > 0 then
		Menu.item "SHOW SELECTED" "createIslandManagerDialog relaunch:true"


	if listbox_items_count < ISLANDS_SYSTEM.islands_data.count then
		Menu.item "SHOW ALL" "createIslandManagerDialog()"

	popUpMenu (Menu.create())
)