
global DIALOG_island_manager

filein( getFilenamePath(getSourceFileName()) + "/islandsRcMenu.ms" )	--"./rcMenu.ms"


/** Create island manager dialog
 */
function createIslandManagerDialog relaunch:false =
(
	--clearListener(); print("Cleared in:\n"+getSourceFileName())
	format "\n"; print ".createIslandManagerDialog()"
	--format "ISLANDS_SYSTEM.islands_data: %\n" ISLANDS_SYSTEM.islands_data

	/** Get item titile
	 */
	function getItemTitile island_index =
	(

		/** Get heigh island
		 */
		function getHeighIslandX island_data        = if island_data[#TOP] != undefined and island_data[#TOP] - island_data[#BOTTOM] > 10  then "↕" else ""
		function getIslandSizeCharacter island_data = if island_data[#SIZE] != undefined and (island_data[#SIZE].x > 5 or island_data[#SIZE].y > 5)  then "↔" else ""
		--format "\n"; print ".getItemTitile()"
		island_data = ISLANDS_SYSTEM.islands_data[island_index]

		whitespace = "                          "

		size_marks = getHeighIslandX(island_data) + getIslandSizeCharacter(island_data)

		if size_marks.count > 0 then
			size_marks = " " + size_marks

		--ISLANDS_SYSTEM.islands_data[island_index][#BOTTOM] as string +  "                          #" + island_index as string
		ISLANDS_SYSTEM.islands_data[island_index][#BOTTOM] as string + size_marks + whitespace+ "#" + island_index as string
	)


	/*------------------------------------------------------------------------------
		GET ITEMS
	--------------------------------------------------------------------------------*/
	selected_islands = ISLANDS_SYSTEM.getSelectedIslandsFromListBox()

	islands_to_show = case of
    (
        (relaunch and selected_islands.numberSet >  1):	selected_islands                     -- SHOW ONLY SELECTED ITEMS ON RELAUNCH
        (relaunch and selected_islands.numberSet == 1):	#{(getFirstIslandFromListbox())..(selected_islands as Array )[1]} -- SHOW ISLANDS UP TO SELECTED ITEM ON RELAUNCH IF ONLY SINGLE ISLAND IS SELECTED
        default:		#{1..ISLANDS_SYSTEM.islands_data.count}             -- SHOW ALL ISLANDS
    )

	items = for i = ISLANDS_SYSTEM.islands_data.count to 1 by -1 where islands_to_show[i] collect  getItemTitile (i)



	/*------------------------------------------------------------------------------
		DIALOG
	--------------------------------------------------------------------------------*/
    Dialog 	    = Dialog_v "" id:#DIALOG_island_manager ini:(getSourceFileName()) --min_size:[48, -1] max_size:[48, -1]

	_Controls   = Dialog.Controls() --group:"Main Controls"

	--pos_y_start = 92
	--pos_y_start = 32

	item_height = 13

	viewport_height = Dialog.getViewportHeight()

	items_count = items.count
	format "items_count: %\n" items_count

	--slider_height =  ( items_count +1 ) * item_height + 2

	--pos_y_start = viewport_height - ( items_count * item_height ) - 76

	pos_y_start = 24

    max_item_length = amax(for i = ISLANDS_SYSTEM.islands_data.count to 1 by -1 collect (ISLANDS_SYSTEM.islands_data[i][#BOTTOM] as string ).count)
	--format "MAX_ITEM_LENGTH: %\n" max_item_length
	--width_listbox = 32
	--character_width = 4
	width_listbox = (max_item_length * 10 ) + 16

	slider_width = 32

	height_other_controls = 84

	slider_height = viewport_height - height_other_controls

	listbox_height = (slider_height / item_height) as integer
	--format "LISTBOX_HEIGHT: %\n" listbox_height
	--slider_height = 512
	slider_height = (listbox_height + 1) * item_height

	--listbox_height = 60


	--if slider_height > viewport_height then
		--slider_height = viewport_height - 16

	--listbox_height = items_count

	if items_count > listbox_height then
	(
		--listbox_height = ceil( (viewport_height - pos_y_start) / item_height ) + 2

		width_listbox += 20
	)

	pos_listbox = [ 4, pos_y_start ]
	pos_slider  = [ width_listbox + 4, pos_y_start - 4 ]

	/*------------------------------------------------------------------------------
		CONTROLS
	--------------------------------------------------------------------------------*/
    btn_exit = _Controls.control #BUTTON "Exit" width:42 height:24 offset:[ 12, -4 ] tooltip:"Exit and remove slicer from all objects"
    --btn_exit = _Controls.control #BUTTON "Exit" width:42 height:24

	/*------ MULTILISTBOX ------*/
	_multilistbox = _Controls.control #MULTILISTBOX "" id:#ML_island_listbox \
						width:width_listbox	\
						height:listbox_height	\
						items:items	\
						across:2	\
						ini:false	\
								        pos:pos_listbox

	/*------ SLIDER ------*/
    _slider = _Controls.control #SLIDER "" id:#SLIDER_island_select	\
                    range:[0, items_count - 1 ,0]	\
                    params:#(#orient, #vertical, #type, #integer)	\
                    ticks:(items_count - 2)	\
                    width:slider_width	\
                    height:slider_height	\
                    across:2	\
                    ini:false	\
                    pos:pos_slider

	/*------ CECKBUTTON ------*/
	btn_isloate = _Controls.control #CHECKBUTTON "ISOLATE" id:#CBTN_isolate height:32


	/*------ RADIOBUTTONS ------*/
	_radio = _Controls.control #RADIOBUTTONS "" id:#RB_slider_mode items:#("   ↓   ","   ↑   ") params:#( #UNSELECT, true ) across:1 offset:[ 4, 2 ] --align:#center  --width:96

	/*------ SPINNER ------*/
	_size_min = _Controls.control #SPINNER "" id:#SPIN_island_size_min across:2 type:#integer range:[0,100,2] width:48 offset:[ -10, 0]
	_size_max = _Controls.control #SPINNER "" id:#SPIN_island_size_max across:2 type:#integer range:[0,100,5] width:48


	/*------------------------------------------------------------------------------
		EVENTS
	--------------------------------------------------------------------------------*/
	btn_isloate.Event #CHANGED "ISLANDS_SYSTEM.isolateSlectedIslands"

	_radio.Event #CHANGED "ISLANDS_SYSTEM.updateIslandSelectionByRadiobuttonsState()"
	_radio.Event #RIGHTCLICK "ISLANDS_SYSTEM.updateIslandSelectionByRadiobuttonsState()"

	_size_min.Event #CHANGED "format \"EventFired: %\n\" EventFired"

	_multilistbox.Event #SELECTIONEND "ISLANDS_SYSTEM.updateListboxCallback()" -- called when select action ends
    _multilistbox.Event #RIGHTCLICK "openNewIslandsMenu()" -- called when select action ends

	_slider.Event #CHANGED     "ISLANDS_SYSTEM.selectLayerBySlider"
	_slider.Event #RIGHTCLICK  "ISLANDS_SYSTEM.toggleSelectIslandMode()"


	--Dialog.min_size = [32, -1]
	--Dialog.create width:(width_listbox + slider_width) height:#VIEWPORT --style:#()  --lockWidth:false --bgcolor:( color 60 130 140 )
	Dialog.create width:(96) height:#VIEWPORT --style:#()  --lockWidth:false --bgcolor:( color 60 130 140 )
	--Dialog.create height:#VIEWPORT --bgcolor:( color 60 130 140 )

	/* KEEP SLICER AND ISLAND DILOGS IN SAME ORDER HWEN DILAG IS DOCKED #RIGHT */
	if DIALOG_elevation_slider != undefined and GetDialogPos DIALOG_elevation_slider != [0,0] and cui.getDockState DIALOG_elevation_slider == #CUI_DOCK_RIGHT then
	(
		cui.FloatDialogBar DIALOG_elevation_slider

		Dialog.dock #RIGHT

		cui.DockDialogBar DIALOG_elevation_slider #CUI_DOCK_RIGHT
	)
	else
		Dialog.dock #RIGHT


)
