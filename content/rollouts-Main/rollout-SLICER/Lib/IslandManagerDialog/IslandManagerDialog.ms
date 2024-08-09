
global ISLANDS_DATA
global DIALOG_island_manager

/** Select island verts
 */
function selectIslandVerts verts layer_index =
(
	--format "\n"; print ".selectIslandVerts()"

	--verts = verts as BitArray

	--format "verts: %\n" verts
	--format "verts: %\n" (classOF verts)

	DIALOG_island_manager.ML_island_listbox.value = layer_index - 1

	--$.EditablePoly.SetSelection #Vertex ( verts as BitArray )
	$.EditablePoly.SetSelection #Vertex verts
)

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

		hidden_verts =	polyop.getHiddenVerts obj - verts

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
function selectLayerItemListbox layer =
(
	format "\n"; print ".selectLayerListbox()"
	format "layer: %\n" layer
	_listbox = DIALOG_island_manager.ML_island_listbox

	items = _listbox.items
	items_count = _listbox.items.count
	items_sel = _listbox.selection

	new_index = DIALOG_island_manager.ML_island_listbox.items.count - layer_index + 1



	DIALOG_island_manager.ML_island_listbox.selection = if keyboard.shiftPressed then items_sel + #{new_index} else new_index


)

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
			verts += polyop.getVertSelection obj


		--format "VERTS: %\n" verts
		selectIslandsVerts (verts)

	)

	selectLayerItemListbox (layer_index)

)

/** Get selected islands from list box
 */
function getSelectedIslandsFromListBox =
(
	--format "\n"; print ".getSelectedIslandsFromListBox()"
	_listbox = DIALOG_island_manager.ML_island_listbox

	list_items = _listbox.items
	items_count = _listbox.items.count
	items_sel = _listbox.selection

	format "list_items: %\n" list_items
	/* FLIP INDEX - first item == last siland */

	selected_islands = ( for i = 1 to list_items.count where items_sel[i] collect (substring list_items[i] (( findString list_items[i] "#" )+1) -1 ) as Number ) as BitArray


	selected_islands --return
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

/** Open new islands menu
 */
function openNewIslandsMenu =
(
	--format "\n"; print ".openNewIslandsMenu()"
	/* DEFINE MAIN MENU */
	Menu = RcMenu_v name:"TestMenu"

	Menu.item "Select Lowest Verts" "selectFirstVerts(#LOWEST_VERT)"
	Menu.item "Select New Islands" "selectFirstVerts(#NEW_ISLAND)"
	Menu.item "Select Islands" "selectFirstVerts(#WHOLE_ISLAND)"

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


/** Create island manager dialog
 */
function createIslandManagerDialog =
(
	--format "\n"; print ".createIslandManagerDialog()"
	--format "ISLANDS_DATA: %\n" ISLANDS_DATA

	/** Get heigh island
	 */
	function getHeighIsland island_data = if island_data[#TOP] != undefined and island_data[#TOP] - island_data[#BOTTOM] > 10  then " ↕" else ""
	function getIslandSizeCharacter island_data = if island_data[#SIZE] != undefined and island_data[#SIZE] > 5  then " ↔" else ""
	--function getHeighIsland island_data = if island_data[#TOP] - island_data[#BOTTOM] > 10  then " ↕ " else ""

	Dialog 	    = Dialog_v "" id:#DIALOG_island_manager --ini:(getSourceFileName()) min_size:[48, -1] max_size:[48, -1]

	_Controls   = Dialog.Controls() --group:"Main Controls"


	pos_y_start = 52

	step_height = 13

	viewport_height = Dialog.getViewportHeight()

	islands_count = ISLANDS_DATA.count

	--steps_count = islands_count


	slider_height =  ( islands_count +1 ) * step_height + 2

    max_item_length = amax(for i = ISLANDS_DATA.count to 1 by -1 collect (ISLANDS_DATA[i][#BOTTOM] as string ).count)
	format "MAX_ITEM_LENGTH: %\n" max_item_length
	--width_listbox = 32
	--character_width = 4
	width_listbox = max_item_length * 10
	slider_width = 32

	if slider_height > viewport_height then
		slider_height = viewport_height - 16

	listbox_height = islands_count

	if islands_count * step_height > viewport_height then
	(
		listbox_height = ceil( (viewport_height - pos_y_start) / step_height ) + 2

		width_listbox += 14
	)



	pos_listbox = [ 0, pos_y_start ]
	pos_slider  = [ width_listbox, pos_y_start - 4 ]



    items = for i = ISLANDS_DATA.count to 1 by -1 collect ISLANDS_DATA[i][#BOTTOM] as string + "      #" + i as string --+ (getHeighIsland(ISLANDS_DATA[i])) + (getIslandSizeCharacter(ISLANDS_DATA[i]))

	/*------ CECKBUTTON ------*/
	_button = _Controls.control #CHECKBUTTON "ISOLATE" id:#CBTN_isolate

	/*------ RADIOBUTTONS ------*/
	_radio = _Controls.control #RADIOBUTTONS "" id:#RB_slider_mode items:#("↓","↑") params:#( #UNSELECT, true ) across:1 offset:[ 12, 0]

	/*------ MULTILISTBOX ------*/
	_multilistbox = _Controls.control #MULTILISTBOX "" id:#ML_island_listbox \
						width:width_listbox	\
						height:listbox_height	\
						items:items	\
						across:2	\
						pos:pos_listbox

    _multilistbox.Event #SELECTIONEND 	"updateListbox()" -- called when select action ends
    --_multilistbox.Event #SELECTED 	"updateListbox()" -- called when select action ends
    _multilistbox.Event #RIGHTCLICK 	"openNewIslandsMenu()" -- called when select action ends


	--/*------ SLIDER ------*/
    _slider = _Controls.control #SLIDER "" id:#SLIDER_island_select	\
                    range:[0, islands_count - 1 ,0]	\
                    params:#(#orient, #vertical, #type, #integer)	\
                    ticks:(islands_count - 2)	\
                    width:slider_width	\
                    height:slider_height	\
                    across:2	\
                    pos:pos_slider


	_slider.Event #CHANGED     "selectLayerSlider"
	_slider.Event #RIGHTCLICK  "toggleSelectIslandMode()"

	--Dialog.min_size = [32, -1]
	Dialog.create width:(width_listbox + slider_width) height:#VIEWPORT --style:#()  --lockWidth:false --bgcolor:( color 60 130 140 )
	--Dialog.create height:#VIEWPORT --bgcolor:( color 60 130 140 )


	Dialog.dock #LEFT

)
