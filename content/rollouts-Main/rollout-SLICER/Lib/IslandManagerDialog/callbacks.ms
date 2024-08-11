

/** Select layer
 */
function selectLayerSlider slider_val =
(
	--format "\n"; print ".selectLayerSlider()"
	--format "slider_val: %\n" slider_val

	if slider_val == undefined then
		slider_val = DIALOG_island_manager.SLIDER_island_select.value

	obj	= selection[1]

	layer_index = slider_val + 1
	--format "layer_index: %\n" layer_index
	select_whole_island = DIALOG_island_manager.RB_slider_mode.state
	--format "select_whole_island: %\n" select_whole_island
	--format "BOTTOM: %\n" ISLANDS_DATA[#BOTTOM][layer_index]
	--format "NEW_ISLAND:   %\n" ISLANDS_DATA[#NEW_ISLAND][layer_index]
	--format "WHOLE_ISLAND: %\n" ISLANDS_DATA[#WHOLE_ISLAND][layer_index]

	island_data = ISLANDS_DATA[layer_index]
	format "island_data: %\n" island_data
	--format "island_data[#WHOLE_ISLAND]: %\n" island_data[#WHOLE_ISLAND]

	if island_data[#NEW_ISLAND] != undefined then
	(
		--verts = ISLANDS_DATA[#WHOLE_ISLAND]
		--verts = ISLANDS_DATA[#NEW_ISLAND]
		verts = getVertsFromIslandData (island_data)

		if keyboard.shiftPressed then
			verts += polyop.getVertSelection obj/** Toggle select island mode
 */
function toggleSelectIslandMode =
(
	format "\n"; print ".toggleSelectIslandMode()"
	--format "DIALOG_island_manager.RB_slider_mode.state: %\n" DIALOG_island_manager.RB_slider_mode.state
	--DIALOG_island_manager.RB_slider_mode.state = not DIALOG_island_manager.RB_slider_mode.state
	--format "DIALOG_island_manager.RB_slider_mode_last_state: %\n" DIALOG_island_manager.RB_slider_mode_last_state
	format "DIALOG_island_manager.RB_slider_mode.state: %\n" DIALOG_island_manager.RB_slider_mode.state

	DIALOG_island_manager.RB_slider_mode.state = case DIALOG_island_manager.RB_slider_mode.state of
	(
		0:	1
		1:	2
		2:	0
	)
)



		--format "VERTS: %\n" verts
		selectIslandsVerts (verts)

	)

	selectLayerItemListbox (layer_index)

)

/** Select layer
 */
function updateListbox =
(
	format "\n"; print ".updateListbox()"
	--format "EventFired	= % \n" EventFired

	obj	= selection[1]

	--_listbox = DIALOG_island_manager.ML_island_listbox
	--
	--list_items = _listbox.items
	--items_count = _listbox.items.count
	--items_sel = _listbox.selection

	/* FLIP INDEX - first item == last siland */
	selected_islands = ( getSelectedIslandsFromListBox() ) as Array
	format "SELECTED_ISLANDS: %\n" selected_islands

	--shift_pressed = keyboard.shiftPressed

	verts = #{1..(getNumVerts obj.mesh)} * #{}

	for layer_index in selected_islands do
	(
		--verts += if select_whole_island == 2 and ISLANDS_DATA[layer_index][#WHOLE_ISLAND] != undefined  then ISLANDS_DATA[layer_index][#WHOLE_ISLAND] else ISLANDS_DATA[layer_index][#NEW_ISLAND]
		verts += getVertsFromIslandData (ISLANDS_DATA[layer_index])

	)

	format "VERTS: %\n" verts

	selectIslandsVerts (verts)


	--if items_sel.numberSet == 1 then

	if selected_islands.count > 0 then
		DIALOG_island_manager.SLIDER_island_select.value = selected_islands[selected_islands.count] - 1
)


/** Select islands by size
 */
function selectIslandsBySize size =
(
	format "\n"; print ".selectIslandsBySize()"

	--islands_by_size = for i = ISLANDS_DATA.count to 1 by -1 where ISLANDS_DATA[i][#SIZE] != undefined and  ISLANDS_DATA[i][#SIZE] > 2 collect i
	_listbox = DIALOG_island_manager.ML_island_listbox
	list_items = _listbox.items


	islands_by_size = (for i = 1 to ISLANDS_DATA.count where ISLANDS_DATA[i][#SIZE] != undefined and  ISLANDS_DATA[i][#SIZE] > 10 collect i) as BitArray

	items_of_islands = for i = 1 to  list_items.count where islands_by_size[ getIslandIndexFromTitle list_items[i] ] collect i

	DIALOG_island_manager.ML_island_listbox.selection = items_of_islands as BitArray
)
/** Toggle select island mode
 */
function toggleSelectIslandMode =
(
	format "\n"; print ".toggleSelectIslandMode()"
	--format "DIALOG_island_manager.RB_slider_mode.state: %\n" DIALOG_island_manager.RB_slider_mode.state
	--DIALOG_island_manager.RB_slider_mode.state = not DIALOG_island_manager.RB_slider_mode.state
	--format "DIALOG_island_manager.RB_slider_mode_last_state: %\n" DIALOG_island_manager.RB_slider_mode_last_state
	format "DIALOG_island_manager.RB_slider_mode.state: %\n" DIALOG_island_manager.RB_slider_mode.state

	DIALOG_island_manager.RB_slider_mode.state = case DIALOG_island_manager.RB_slider_mode.state of
	(
		0:	1
		1:	2
		2:	0
	)
)
