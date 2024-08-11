
global ISLANDS_DATA
global DIALOG_island_manager

filein( getFilenamePath(getSourceFileName()) + "/callbacks.ms" )	--"./callbacks.ms"
filein( getFilenamePath(getSourceFileName()) + "/rcMenu.ms" )	--"./rcMenu.ms"


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


/** Get island item title
 */
function getIslandIndexFromTitle list_item =
(
	--format "\n"; print ".getIslandIndexFromTitle()"
	( substring list_item (( findString list_item "#" )+1) -1 ) as Number
)

/** Get selected islands from list box
 */
function getSelectedIslandsFromListBox =
(
	--format "\n"; print ".getSelectedIslandsFromListBox()"
	selected_islands = #{}

	if DIALOG_island_manager != undefined then
	(
		_listbox = DIALOG_island_manager.ML_island_listbox

		list_items = _listbox.items
		items_count = _listbox.items.count
		items_sel = _listbox.selection

		--format "list_items: %\n" list_items
		/* FLIP INDEX - first item == last siland */

		selected_islands = ( for i = 1 to list_items.count where items_sel[i] collect getIslandIndexFromTitle(list_items[i])) as BitArray
		--format "SELECTED_ISLANDS: %\n" selected_islands

	)


	selected_islands --return
)

/** Get first island from listbox
 */
function getFirstIslandFromListbox =
(
	--format "\n"; print ".getFirstIslandFromListbox()"

	_listbox = DIALOG_island_manager.ML_island_listbox

	getIslandIndexFromTitle (_listbox.items[_listbox.items.count]) --return

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


/*------------------------------------------------------------------------------

	DIALOG

--------------------------------------------------------------------------------*/

/** Create island manager dialog
 */
function createIslandManagerDialog relaunch:false =
(
	--clearListener(); print("Cleared in:\n"+getSourceFileName())
	--format "\n"; print ".createIslandManagerDialog()"
	--format "ISLANDS_DATA: %\n" ISLANDS_DATA

	/** Get heigh island
	 */
	function getHeighIslandX island_data = if island_data[#TOP] != undefined and island_data[#TOP] - island_data[#BOTTOM] > 10  then " ↕" else ""
	function getIslandSizeCharacter island_data = if island_data[#SIZE] != undefined and island_data[#SIZE] > 5  then " ↔" else ""

	/** Get item titile
	 */
	function getItemTitile island_index =
	(
		--format "\n"; print ".getItemTitile()"
		ISLANDS_DATA[island_index][#BOTTOM] as string +  "                          #" + island_index as string
	)

	/*------------------------------------------------------------------------------
		GET ITEMS
	--------------------------------------------------------------------------------*/
	selected_islands = getSelectedIslandsFromListBox()

	islands_to_show = case of
    (
        (relaunch and selected_islands.numberSet >  1):	selected_islands                     -- SHOW ONLY SELECTED ITEMS ON RELAUNCH
        (relaunch and selected_islands.numberSet == 1):	#{(getFirstIslandFromListbox())..(selected_islands as Array )[1]} -- SHOW ISLANDS UP TO SELECTED ITEM ON RELAUNCH IF ONLY SINGLE ISLAND IS SELECTED
        default:		#{1..ISLANDS_DATA.count}             -- SHOW ALL ISLANDS
    )

	items = for i = ISLANDS_DATA.count to 1 by -1 where islands_to_show[i] collect  getItemTitile (i)



	/*------------------------------------------------------------------------------
		DIALOG
	--------------------------------------------------------------------------------*/
    Dialog 	    = Dialog_v "" id:#DIALOG_island_manager --ini:(getSourceFileName()) min_size:[48, -1] max_size:[48, -1]

	_Controls   = Dialog.Controls() --group:"Main Controls"

	pos_y_start = 72

	step_height = 13

	viewport_height = Dialog.getViewportHeight()

	items_count = items.count

	slider_height =  ( items_count +1 ) * step_height + 2

    max_item_length = amax(for i = ISLANDS_DATA.count to 1 by -1 collect (ISLANDS_DATA[i][#BOTTOM] as string ).count)
	--format "MAX_ITEM_LENGTH: %\n" max_item_length
	--width_listbox = 32
	--character_width = 4
	width_listbox = (max_item_length * 10 ) + 28
	slider_width = 32

	if slider_height > viewport_height then
		slider_height = viewport_height - 16

	listbox_height = items_count

	if items_count * step_height > viewport_height then
	(
		listbox_height = ceil( (viewport_height - pos_y_start) / step_height ) + 2

		width_listbox += 16
	)



	pos_listbox = [ 4, pos_y_start ]
	pos_slider  = [ width_listbox + 4, pos_y_start - 4 ]

	/*------------------------------------------------------------------------------
		CONTROLS
	--------------------------------------------------------------------------------*/

	_size_min = _Controls.control #SPINNER "" id:#SPIN_island_size_min across:2 type:#integer range:[0,100,5]  width:48 offset:[ -10, 0]
	_size_max = _Controls.control #SPINNER "" id:#SPIN_island_size_max across:2 type:#integer range:[0,100,10] width:48

	_size_min.Event #CHANGED     "format \"EventFired: %\n\" EventFired"

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
                    range:[0, items_count - 1 ,0]	\
                    params:#(#orient, #vertical, #type, #integer)	\
                    ticks:(items_count - 2)	\
                    width:slider_width	\
                    height:slider_height	\
                    across:2	\
                    pos:pos_slider


	_slider.Event #CHANGED     "selectLayerSlider"
	_slider.Event #RIGHTCLICK  "toggleSelectIslandMode()"


	--Dialog.min_size = [32, -1]
	--Dialog.create width:(width_listbox + slider_width) height:#VIEWPORT --style:#()  --lockWidth:false --bgcolor:( color 60 130 140 )
	Dialog.create width:(96) height:#VIEWPORT --style:#()  --lockWidth:false --bgcolor:( color 60 130 140 )
	--Dialog.create height:#VIEWPORT --bgcolor:( color 60 130 140 )


	Dialog.dock #LEFT

)
