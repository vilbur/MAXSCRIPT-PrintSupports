
global ISLANDS_DATA
global DIALOG_island_manager

/** Select island verts
 */
function selectIslandVerts verts layer_index =
(
	format "\n"; print ".selectIslandVerts()"

	--verts = verts as BitArray

	format "verts: %\n" verts
	format "verts: %\n" (classOF verts)

	DIALOG_island_manager.SLIDER_island_select.value = layer_index - 1

	--$.EditablePoly.SetSelection #Vertex ( verts as BitArray )
	$.EditablePoly.SetSelection #Vertex verts
)

/** Select layer
 */
function selectLayer slider_val =
(
	--format "\n"; print ".selectLayer()"
	format "EventFired	= % \n" EventFired
	format "slider_val: %\n" slider_val
	format "ISLANDS_DATA: %\n" ISLANDS_DATA

	if slider_val == undefined then
		slider_val = DIALOG_island_manager.SLIDER_island_select.value

	obj	= selection[1]

	layer_index = slider_val + 1

	--format "ISLANDS_DATA: %\n" DIALOG_island_manager.layers_data[layer_index]

	--ISLANDS_DATA = ISLANDS_DATA[#NEW_ISLANDS][layer_index]

	if ISLANDS_DATA[#NEW_ISLANDS][layer_index] != undefined then
	(
		--verts = ISLANDS_DATA[#WHOLE_ISLAND]
		--verts = ISLANDS_DATA[#NEW_ISLAND]

		verts = if keyboard.controlPressed and ISLANDS_DATA[#NEW_ISLANDS][layer_index] != undefined then ISLANDS_DATA[#NEW_ISLANDS][layer_index] else ISLANDS_DATA[#NEW_ISLANDS][layer_index]

		/* ADD TO CURRENT SELECTION */
		if keyboard.shiftPressed then
			verts += getVertSelection obj.mesh

		else if keyboard.altPressed then
			verts -= getVertSelection obj.mesh

		if verts != undefined then
			obj.EditablePoly.SetSelection #Vertex verts
		--else
			--$.EditablePoly.SetSelection #Vertex #{}

	)


)


/** Create island manager dialog
 */
function createIslandManagerDialog =
(
	format "\n"; print ".createIslandManagerDialog()"
	format "ISLANDS_DATA: %\n" ISLANDS_DATA

	--slice_layers = makeUniqueArray ( for pos in ISLANDS_DATA[#TOP] collect pos )

	--LayersData	=  Dictionary #INTEGER

	--layers_data = #()
	--layers_data = #()
	--
	--layers_data[slice_layers.count] = undefined
	--
	--for i = 1 to ISLANDS_DATA[#NEW_ISLANDS].count do
	--(
	--	if layers_data[i] == undefined then
	--	(
	--
	--		bottom_layer = ISLANDS_DATA[#BOTTOM][i]
	--		format "BOTTOM_LAYER: %\n" bottom_layer
	--
	--		layers_data[i]	=  Dictionary #( #BOTTOM, bottom_layer )  #( #TOP, ISLANDS_DATA[#TOP][i] ) #( #NEW_ISLAND, ISLANDS_DATA[#NEW_ISLANDS][i] )  #( #WHOLE_ISLAND, ISLANDS_DATA[#WHOLE_ISLANDS][i] )
	--
	--	)
	--)

	--format "layers_data: %\n" layers_data
	--format "layers_data.count: %\n" layers_data.count
	--format "slice_layers.count: %\n" slice_layers.count

	Dialog 	    = Dialog_v ("Island Manager") --ini:(getSourceFileName())


	_Controls   = Dialog.Controls() --group:"Main Controls"

	--Dialog.addlocal #LAYERS_DATA (layers_data as string )
	--Dialog.addlocal #LAYERS_DATA layers_data

	--_slider     = _Controls.control #slider "" range:[0,5000,0] type:#integer ticks:5000 orient:#vertical width:32 height:(viewport_height - 40) pos:[ 10, 22 ] tooltip:"Set positioon of slice plane.\n\nRMB: Circle slice plane on obejct min, center and maximum.\n\nRMB+CTRL: SET SLICE PLANE TO BOTTOM OF OBJECT"

	pos_y_start = 9

	step_height = 18

	viewport_height = Dialog.getViewportHeight()

	islands_count = ISLANDS_DATA[#NEW_ISLANDS].count

	--steps_count = islands_count

	slider_height =  (islands_count ) * step_height
	--format "slider_height: %\n" slider_height

	btn_pos = -step_height + pos_y_start

	--format "btn_pos: %\n" btn_pos

	items = for i = ISLANDS_DATA[#NEW_ISLANDS].count to 1 by -1 collect ISLANDS_DATA[#BOTTOM][i] as string



	_multilistbox     = _Controls.control #MULTILISTBOX "TEST" items:items width:96 height:islands_count

	_multilistbox.Event #selected  "selectLayer"

	--for i = islands_count to 1 by -1 do
	----for i = 1 to ISLANDS_DATA[#NEW_ISLANDS].count do
	--(
	--	--_Button     = _Controls.control #button ( "Island " + i as string ) across:1 height:18 offset:[0,-2]
	--
	--	_Button     = _Controls.control #button ( ISLANDS_DATA[#BOTTOM][i] as string + " " + i as string ) across:1 height:step_height  pos:[ 42, btn_pos += step_height ]
	--
	--
	--	_Button.Event #PRESSED "selectIslandVerts" params:#(ISLANDS_DATA[#NEW_ISLANDS][i], i )
	--
	--
	--	if ISLANDS_DATA[#WHOLE_ISLANDS][i] != undefined then
	--		_Button.Event #RIGHTCLICK  "selectIslandVerts" params:#(ISLANDS_DATA[#WHOLE_ISLANDS][i], i )
	--)
	--
	--/*------ SLIDER ------*/
	--_slider     = _Controls.control #SLIDER "" id:#SLIDER_island_select range:[0, islands_count - 1 ,0] pos:[ pos_y_start, pos_y_start ] height:slider_height params:#(#orient, #vertical, #type, #integer) border:true width:32 ticks:(islands_count - 2)
	--
	--_slider.Event #CHANGED "selectLayer"

	Dialog.create width:48 height:#VIEWPORT --bgcolor:( color 60 130 140 )

	Dialog.min_size = [32, -1]

	Dialog.dock #LEFT

)
