
/** Get verts from island data
 */
function getVertsFromIslandData island_data =
(
	--format "\n"; print ".getVertsFromIslandData()"
	--format "STATE: %\n" (DIALOG_island_manager.RB_slider_mode.state)
	case DIALOG_island_manager.RB_slider_mode.state of
	(
		0:	island_data[#NEW_ISLAND]
		1:	#{island_data[#LOWEST_VERT]}
		2:	if island_data[#WHOLE_ISLAND] != undefined then island_data[#WHOLE_ISLAND] else island_data[#NEW_ISLAND]
	)

)

/** Select islands verts
 */
function selectIslandsVerts verts =
(
	format "\n"; print ".selectIslandsVerts()"
	format "verts: %\n" verts
	obj	= selection[1]

	if verts != undefined then
	(
		subObjectLevel = 1

		hidden_verts =	( polyop.getHiddenVerts obj) - verts

		polyop.unHideAllVerts obj

		if DIALOG_island_manager.CBTN_isolate.state == 1 then
		(
			all_verts = #{1..(getNumVerts obj.mesh)}

			polyop.setHiddenVerts obj (all_verts - verts)
		)
		else
			polyop.setHiddenVerts obj (hidden_verts - verts)

		--else
		obj.EditablePoly.SetSelection #Vertex verts
	)
)

/** Select layer listbox
 */
function selectLayerItemInListbox layer_index =
(
	format "\n"; print ".selectLayerItemInListbox()"
	format "layer_index: %\n" layer_index
	_listbox = DIALOG_island_manager.ML_island_listbox

	items = _listbox.items
	items_count = _listbox.items.count
	items_sel = _listbox.selection

	new_index = DIALOG_island_manager.ML_island_listbox.items.count - layer_index + 1

	--format "TEST: %\n" (if keyboard.shiftPressed then items_sel + #{new_index} else new_index)

	DIALOG_island_manager.ML_island_listbox.selection = if keyboard.shiftPressed then items_sel + #{new_index} else #{new_index}
)

/** Select islands by size
 */
function selectIslandsBySize size =
(
	format "\n"; print ".selectIslandsBySize()"

	/** Is island matchin size
	 */
	function isIslandMatchinSize island_size size =
	(
		--format "\n"; print ".isIslandMatchinSize()"
		--format "island_size: %\n" island_size
		--format "size: %\n" size
		size_min = DIALOG_island_manager.SPIN_island_size_min.value
		size_max = DIALOG_island_manager.SPIN_island_size_max.value

		case size of
		(
			(#SMALL):	island_size.x <= size_min or  island_size.y <= size_min
			(#MEDIUM):	(island_size.x > size_min and island_size.x < size_max) or (island_size.y > size_min and island_size.y < size_max)
			(#BIG):	island_size.x >= size_max or  island_size.y >= size_max
		)

	)

	--islands_by_size = for i = ISLANDS_DATA.count to 1 by -1 where ISLANDS_DATA[i][#SIZE] != undefined and  ISLANDS_DATA[i][#SIZE] > 2 collect i

	/* GET ISLANDS MATHING SIZE */
	islands_by_size = (for i = 1 to ISLANDS_DATA.count where ISLANDS_DATA[i][#SIZE] != undefined and isIslandMatchinSize(ISLANDS_DATA[i][#SIZE])(size) collect i) as BitArray

	DIALOG_island_manager.ML_island_listbox.selection = _getListboxItemsByIslandsIndex (islands_by_size)

	updateListbox()
)

/** Select islands by verts
 */
function selectIslandsByVerts =
(
	--format "\n"; print ".selectIslandsByVerts()"
	verts_sel = polyop.getVertSelection selection[1]

	verts_of_islands = #{}

	islands_of_verts = ( for i = 1 to ISLANDS_DATA.count where not (ISLANDS_DATA[i][#NEW_ISLAND] * verts_sel ).isEmpty collect i) as BitArray

	for index in islands_of_verts do verts_of_islands += ISLANDS_DATA[index][#NEW_ISLAND]


	if classOf (_mod = modPanel.getCurrentObject()) == Edit_Poly then
		_mod.Select #VERTEX verts_of_islands

	else if classOf _mod  == Editable_Poly then
		_mod.SetSelection #VERTEX verts_of_islands


	DIALOG_island_manager.ML_island_listbox.selection = _getListboxItemsByIslandsIndex (islands_of_verts)

)

/** Get island item title
 */
function _getIslandIndexFromTitle list_item =
(
	--format "\n"; print "._getIslandIndexFromTitle()"
	( substring list_item (( findString list_item "#" )+1) -1 ) as Number
)


/** Select first verts
 */
function selectFirstVerts vertex_type =
(
	format "\n"; print ".selectFirstVerts()"
	format "vertex_type: %\n" (classOf vertex_type)
	_listbox = DIALOG_island_manager.ML_island_listbox

	selected_islands = getSelectedIslandsFromListBox()

	if selected_islands.count == 0 then
		selected_islands = #{1..ISLANDS_DATA.count} as Array

	format "SELECTED_ISLANDS: %\n" selected_islands

	verts = #{}

	for layer_index in selected_islands collect
	(

		if vertex_type == #LOWEST_VERT then
			verts[ISLANDS_DATA[layer_index][vertex_type]] = true

		else if ( island_verts = ISLANDS_DATA[layer_index][vertex_type] ) != undefined then
			verts += island_verts
	)

	selectIslandsVerts( verts as BitArray )

)


/** Get listbox items by island index
 */
function _getListboxItemsByIslandsIndex island_indexes =
(
	--format "\n"; print "._getListboxItemsByIslandIndex()"
	--_listbox = DIALOG_island_manager.ML_island_listbox

	list_items = DIALOG_island_manager.ML_island_listbox.items


	( for i = 1 to  list_items.count where island_indexes[ _getIslandIndexFromTitle list_items[i] ] collect i ) as BitArray
)















