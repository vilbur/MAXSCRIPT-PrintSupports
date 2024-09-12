
/** Open new islands menu
 */
function islandsRcMenu =
(
	--format "\n"; print ".openNewIslandsMenu()"

	/* DEFINE MAIN MENU */
	Menu = RcMenu_v name:"IslandsMenu"

	listbox_items_count = DIALOG_island_manager.ML_island_listbox.items.count
	listbox_selection = DIALOG_island_manager.ML_island_listbox.selection


	/*------------------------------------------------------------------------------
		SELECTIOJN
	--------------------------------------------------------------------------------*/


	if (verts_sel = getVertSelection selection[1].mesh ).numberSet > 0 then
		Menu.item "Select Islands by verts"	"::IslandsRcMenuCallbacks_v.selectIslandsByVerts()"

	--Menu.item "Select Lowest Verts"	"::IslandsRcMenuCallbacks_v.selectVertsOfIslands(#LOWEST_VERT)"
	--Menu.item "Select New Islands"	"::IslandsRcMenuCallbacks_v.selectVertsOfIslands(#NEW_ISLAND)"
	Menu.item "Select whole Islands"	"::IslandsRcMenuCallbacks_v.selectVertsOfIslands(#WHOLE_ISLAND)"

	Menu.separator()

	/* ADD ITEMS */
	if listbox_selection.numberSet != listbox_items_count then
		Menu.item "Select All"	"::IslandsRcMenuCallbacks_v.selectAllIslandsInListbox()"

	if listbox_selection.numberSet > 0 then
		Menu.item "Invert selection"	"::IslandsRcMenuCallbacks_v.invertSelection()"

	/*------------------------------------------------------------------------------
		SELECT BY SIZE
	--------------------------------------------------------------------------------*/

	Menu.separator()

	Menu.item "Select SMALL Islands"	"::IslandsRcMenuCallbacks_v.selectIslandsBySize(#SMALL)"
	Menu.item "Select MEDIUM Islands"	"::IslandsRcMenuCallbacks_v.selectIslandsBySize(#MEDIUM)"
	Menu.item "Select BIG Islands"	"::IslandsRcMenuCallbacks_v.selectIslandsBySize(#BIG)"

	Menu.separator()

	if listbox_selection.numberSet > 0 then
		--Menu.item "Show ONLY selected" "::IslandsRcMenuCallbacks_v.createIslandManagerDialogOnlySelectedIslands()"
		Menu.item "Show ONLY selected" "createIslandManagerDialog islands_to_show:(ISLANDS_SYSTEM.getIslandsToShowBySlection())"


	if listbox_items_count < ISLANDS_SYSTEM.islands_data.count then
		Menu.item "Show ALL" "createIslandManagerDialog islands_to_show:#{}"


	if DIALOG_slicer_slider != undefined then
	(
		Menu.separator()

		Menu.item "Slice here"	"::IslandsRcMenuCallbacks_v.sliceAtIsland()"
	)


	/*------------------------------------------------------------------------------
		MANAGE ISALNDS
	--------------------------------------------------------------------------------*/

	Menu.separator()

	Menu.item "Remove selected islands"	"::IslandsRcMenuCallbacks_v.removeSelectedIslands()"



	popUpMenu (Menu.create())
)