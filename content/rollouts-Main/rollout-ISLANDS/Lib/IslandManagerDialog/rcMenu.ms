


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
		Menu.item "Select All"	"(DIALOG_island_manager.ML_island_listbox.selection = #{1..DIALOG_island_manager.ML_island_listbox.items.count};updateListbox())"

	if (verts_sel = polyop.getVertSelection selection[1]).numberSet > 0 then
		Menu.item "Select Islands by verts"	"selectIslandsByVerts()"

	Menu.item "Select Lowest Verts"	"selectFirstVerts(#LOWEST_VERT)"
	Menu.item "Select New Islands"	"selectFirstVerts(#NEW_ISLAND)"

	Menu.item "Select SMALL Islands"	"selectIslandsBySize(#SMALL)"
	Menu.item "Select MEDIUM Islands"	"selectIslandsBySize(#MEDIUM)"
	Menu.item "Select BIG Islands"	"selectIslandsBySize(#BIG)"

	Menu.item "Select Islands"	"selectFirstVerts(#WHOLE_ISLAND)"


	format "listbox_items_count: %\n" listbox_items_count
	format "ISLANDS_DATA.count: %\n" ISLANDS_DATA.count


	if listbox_selection.numberSet > 1 and listbox_items_count > 0 then
		Menu.item "SHOW SELECTED" "createIslandManagerDialog relaunch:true"


	if listbox_items_count < ISLANDS_DATA.count then
		Menu.item "SHOW ALL" "createIslandManagerDialog()"

	popUpMenu (Menu.create())
)