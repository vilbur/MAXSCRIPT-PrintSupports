
global ISLANDS_DATA
global DIALOG_island_manager

filein( getFilenamePath(getSourceFileName()) + "/methods.ms" )	--"./methods.ms"
filein( getFilenamePath(getSourceFileName()) + "/callbacks.ms" )	--"./callbacks.ms"
filein( getFilenamePath(getSourceFileName()) + "/rcMenu.ms" )	--"./rcMenu.ms"

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

		/* FLIP INDEX - first item == last siland */

		selected_islands = ( for i = 1 to list_items.count where items_sel[i] collect _getIslandIndexFromTitle(list_items[i])) as BitArray
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

	_getIslandIndexFromTitle (_listbox.items[_listbox.items.count]) --return
)

/** Create island manager dialog
 */
function createIslandManagerDialog relaunch:false =
(
	--clearListener(); print("Cleared in:\n"+getSourceFileName())
	format "\n"; print ".createIslandManagerDialog()"
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
    Dialog 	    = Dialog_v "" id:#DIALOG_island_manager ini:(getSourceFileName()) --min_size:[48, -1] max_size:[48, -1]

	_Controls   = Dialog.Controls() --group:"Main Controls"

	pos_y_start = 92

	step_height = 13

	viewport_height = Dialog.getViewportHeight()

	items_count = items.count
	format "items_count: %\n" items_count

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

	_size_min = _Controls.control #SPINNER "" id:#SPIN_island_size_min across:2 type:#integer range:[0,100,2]  width:48 offset:[ -10, 0]
	_size_max = _Controls.control #SPINNER "" id:#SPIN_island_size_max across:2 type:#integer range:[0,100,5] width:48

	_size_min.Event #CHANGED     "format \"EventFired: %\n\" EventFired"

	/*------ CECKBUTTON ------*/
	_button = _Controls.control #CHECKBUTTON "ISOLATE" id:#CBTN_isolate height:32
    --_button.Event #CHANGED 	"EventFired.control.text = \"XXX\"" -- called when select action ends


	/*------ RADIOBUTTONS ------*/
	_radio = _Controls.control #RADIOBUTTONS "" id:#RB_slider_mode items:#("   ↓   ","   ↑   ") params:#( #UNSELECT, true ) across:1 offset:[ 4, 2 ] --align:#center  --width:96

	/*------ MULTILISTBOX ------*/
	_multilistbox = _Controls.control #MULTILISTBOX "" id:#ML_island_listbox \
						width:width_listbox	\
						height:listbox_height	\
						items:items	\
						across:2	\
						ini:false	\
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
                    ini:false	\
                    pos:pos_slider


	_slider.Event #CHANGED     "selectLayerBySlider"
	_slider.Event #RIGHTCLICK  "toggleSelectIslandMode()"


	--Dialog.min_size = [32, -1]
	--Dialog.create width:(width_listbox + slider_width) height:#VIEWPORT --style:#()  --lockWidth:false --bgcolor:( color 60 130 140 )
	Dialog.create width:(96) height:#VIEWPORT --style:#()  --lockWidth:false --bgcolor:( color 60 130 140 )
	--Dialog.create height:#VIEWPORT --bgcolor:( color 60 130 140 )


	Dialog.dock #LEFT

)
