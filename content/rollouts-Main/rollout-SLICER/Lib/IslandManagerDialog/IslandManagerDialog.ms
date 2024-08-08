
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

	DIALOG_island_manager.ML_island_select.value = layer_index - 1

	--$.EditablePoly.SetSelection #Vertex ( verts as BitArray )
	$.EditablePoly.SetSelection #Vertex verts
)

/** Get verts from island data
 */
function getVertsFromIslandData island_data =
(
	format "\n"; print ".getVertsFromIslandData()"
	format "STATE: %\n" (DIALOG_island_manager.RB_slider_mode.state)
	case DIALOG_island_manager.RB_slider_mode.state of
	(
		0:	island_data[#NEW_ISLAND]
		1:	#{island_data[#LOWEST_VERT]}
		2:	if island_data[#WHOLE_ISLAND] != undefined then island_data[#WHOLE_ISLAND] else island_data[#NEW_ISLAND]
	)

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
	format "island_data: %\n" island_data\
	--format "island_data[#WHOLE_ISLAND]: %\n" island_data[#WHOLE_ISLAND]

	if island_data[#NEW_ISLAND] != undefined then
	(
		--verts = ISLANDS_DATA[#WHOLE_ISLAND]
		--verts = ISLANDS_DATA[#NEW_ISLAND]

		verts = getVertsFromIslandData (island_data)

		format "verts: %\n" verts
		--/* PLUS TO SELECTION */
		--if keyboard.controlPressed then
		--	verts += getVertSelection obj.mesh
		--
		--/* MINUS FROM SELECTION */
		--else if keyboard.altPressed then
		--	verts -= getVertSelection obj.mesh

		subObjectLevel = 1

		if verts != undefined then
			obj.EditablePoly.SetSelection #Vertex verts

	)

)



/** Select layer
 */
function selectLayerListbox =
(
	--format "\n"; print ".selectLayerListbox()"
	--format "EventFired	= % \n" EventFired
	----format "slider_val: %\n" slider_val
	--format "ISLANDS_DATA: %\n" ISLANDS_DATA

	--select_whole_island = DIALOG_island_manager.RB_slider_mode.state

	_listbox = DIALOG_island_manager.ML_island_select

	list_items = _listbox.items
	items_count = _listbox.items.count
	items_sel = _listbox.selection
	--items_sel_arr = items_sel as Array
	--format "items_sel.count: %\n" items_sel.count
	--format "items_sel.numberSet: %\n" items_sel.numberSet

	/* FLIP INDEX - first item == last siland */
	selected_islands = (for item in items_sel collect items_count - item + 1) as BitArray
	--format "selected_islands: %\n" selected_islands

	--format "items_sel: %\n" (items_sel )
	obj	= selection[1]

	shift_pressed = keyboard.shiftPressed

	verts = #{1..(getNumVerts obj.mesh)} * #{}

	for layer_index in selected_islands do
	(
		verts += if select_whole_island == 2 and ISLANDS_DATA[layer_index][#WHOLE_ISLAND] != undefined  then ISLANDS_DATA[layer_index][#WHOLE_ISLAND] else ISLANDS_DATA[layer_index][#NEW_ISLAND]
		verts += getVertsFromIslandData (ISLANDS_DATA[layer_index])

	)

	subObjectLevel = 1

	if verts.numberSet > 0 then
		obj.EditablePoly.SetSelection #Vertex verts


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

	--slice_layers = makeUniqueArray ( for pos in ISLANDS_DATA[#TOP] collect pos )

	--LayersData	=  Dictionary #INTEGER

	--layers_data = #()
	--layers_data = #()
	--
	--layers_data[slice_layers.count] = undefined
	--
	--for i = 1 to ISLANDS_DATA[#NEW_ISLAND].count do
	--(
	--	if layers_data[i] == undefined then
	--	(
	--
	--		bottom_layer = ISLANDS_DATA[#BOTTOM][i]
	--		--format "BOTTOM_LAYER: %\n" bottom_layer
	--
	--		layers_data[i]	=  Dictionary #( #BOTTOM, bottom_layer )  #( #TOP, ISLANDS_DATA[#TOP][i] ) #( #NEW_ISLAND, ISLANDS_DATA[#NEW_ISLAND][i] )  #( #WHOLE_ISLAND, ISLANDS_DATA[#WHOLE_ISLAND][i] )
	--
	--	)
	--)

	--format "layers_data: %\n" layers_data
	--format "layers_data.count: %\n" layers_data.count
	--format "slice_layers.count: %\n" slice_layers.count

	Dialog 	    = Dialog_v "" id:#DIALOG_island_manager --ini:(getSourceFileName()) min_size:[48, -1] max_size:[48, -1]


	_Controls   = Dialog.Controls() --group:"Main Controls"

	--Dialog.addlocal #LAYERS_DATA (layers_data as string )
	--Dialog.addlocal #LAYERS_DATA layers_data

	--_listbox     = _Controls.control #slider "" range:[0,5000,0] type:#integer ticks:5000 orient:#vertical width:32 height:(viewport_height - 40) pos:[ 10, 22 ] tooltip:"Set positioon of slice plane.\n\nRMB: Circle slice plane on obejct min, center and maximum.\n\nRMB+CTRL: SET SLICE PLANE TO BOTTOM OF OBJECT"

	pos_y_start = 12

	step_height = 13

	viewport_height = Dialog.getViewportHeight()

	islands_count = ISLANDS_DATA.count

	--steps_count = islands_count

	slider_height =  ( islands_count +1 ) * step_height + 2

	if slider_height > viewport_height then
		slider_height = viewport_height

	format "viewport_height: %\n" viewport_height
	format "slider_height: %\n" slider_height

	--btn_pos = -step_height + pos_y_start

	width_listbox = 32
	pos_listbox = [ 0, pos_y_start ]
	pos_slider = [ 32, pos_y_start + 4 ]

	items = for i = ISLANDS_DATA.count to 1 by -1 collect ISLANDS_DATA[i][#BOTTOM] as string

	/*------ CECKBUTTON ------*/
	--_button = _Controls.control #CHECKBUTTON "ISLAND" id:#RB_slider_mode
	_radio =	_Controls.control #RADIOBUTTONS "" id:#RB_slider_mode items:#("↓","↑") params:#( #UNSELECT, true )


	/*------ MULTILISTBOX ------*/
	_multilistbox = _Controls.control #MULTILISTBOX "" id:#ML_island_select \
						width:width_listbox	\
						height:islands_count	\
						items:items	\
						across:2	\
						pos:[0, 32 ]

	_multilistbox.Event #SELECTIONEND 	"selectLayerListbox()" -- called when select action ends
	--_multilistbox.Event #SELECTED 	"selectLayerListbox()" -- called when select action ends
	_multilistbox.Event #RIGHTCLICK 	"selectLayerListbox()" -- called when select action ends


	--/*------ SLIDER ------*/
	_slider     = _Controls.control #SLIDER "" id:#SLIDER_island_select \
						range:[0, islands_count - 1 ,0]	\
						params:#(#orient, #vertical, #type, #integer)	\
						ticks:(islands_count - 2)	\
						width:32	\
						height:slider_height	\
						across:2	\
						pos:[ 32, 27 ]


	_slider.Event #CHANGED     "selectLayerSlider"
	_slider.Event #RIGHTCLICK  "toggleSelectIslandMode()"

	--Dialog.min_size = [32, -1]
	Dialog.create width:64 height:#VIEWPORT --style:#()  --lockWidth:false --bgcolor:( color 60 130 140 )
	--Dialog.create height:#VIEWPORT --bgcolor:( color 60 130 140 )


	Dialog.dock #LEFT

)
