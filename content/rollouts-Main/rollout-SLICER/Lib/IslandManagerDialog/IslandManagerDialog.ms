
global layers_data

/** Select island verts
 */
function selectIslandVerts verts =
(
	format "\n"; print ".selectIslandVerts()"

	--verts = verts as BitArray

	format "verts: %\n" verts
	format "verts: %\n" (classOF verts)


	--$.EditablePoly.SetSelection #Vertex ( verts as BitArray )
	$.EditablePoly.SetSelection #Vertex verts
)

/** Select layer
 */
function selectLayer slider_val =
(
	--format "\n"; print ".selectLayer()"
	--format "EventFired	= % \n" EventFired
	--format "layer_index: %\n" layer_index
	--format "layers_data: %\n" layers_data

	layer_index = slider_val + 1

	--format "layer_data: %\n" DIALOG_island_manager.layers_data[layer_index]

	layer_data = layers_data[layer_index]
	--format "layer_data: %\n" layer_data
	if layer_data != undefined then
	(
		--verts = layer_data[#WHOLE_ISLAND]
		--verts = layer_data[#NEW_ISLAND]

		verts = if keyboard.controlPressed then layer_data[#WHOLE_ISLAND] else layer_data[#NEW_ISLAND]

		--format "verts: %\n" verts


		if verts != undefined then
			$.EditablePoly.SetSelection #Vertex verts
		else
			$.EditablePoly.SetSelection #Vertex #{}

	)


)


/** Create island manager dialog
 */
function createIslandManagerDialog islands_data =
(
	format "\n"; print ".createIslandManagerDialog()"
	format "islands_data: %\n" islands_data

	slice_layers = makeUniqueArray ( for pos in islands_data[#TOP] collect pos )

	--LayersData	=  Dictionary #INTEGER

	--layers_data = #()
	layers_data = #()

	layers_data[slice_layers.count] = undefined

	for i = 1 to islands_data[#NEW_ISLANDS].count do
	(
		if layers_data[i] == undefined then
		(

			layers_data[i]	=  Dictionary #( #BOTTOM, islands_data[#BOTTOM][i] )  #( #TOP, islands_data[#TOP][i] ) #( #NEW_ISLAND, islands_data[#NEW_ISLANDS][i] )  #( #WHOLE_ISLAND, islands_data[#WHOLE_ISLANDS][i] )




		)


	)

	format "layers_data: %\n" layers_data

	Dialog 	    = Dialog_v ("Island Manager") ini:(getSourceFileName())


	_Controls   = Dialog.Controls group:"Main Controls"

	--Dialog.addlocal #LAYERS_DATA (layers_data as string )
	--Dialog.addlocal #LAYERS_DATA layers_data

	--_slider     = _Controls.control #slider "" range:[0,5000,0] type:#integer ticks:5000 orient:#vertical width:32 height:(viewport_height - 40) pos:[ 10, 22 ] tooltip:"Set positioon of slice plane.\n\nRMB: Circle slice plane on obejct min, center and maximum.\n\nRMB+CTRL: SET SLICE PLANE TO BOTTOM OF OBJECT"
	_slider     = _Controls.control #SLIDER "" range:[0,slice_layers.count,0] height:128 params:#(#orient, #vertical, #type, #integer)

	_slider.Event #CHANGED "selectLayer"


	--for i = 1 to slice_layers.count do
	--(
	--	--_Button     = _Controls.control #button ( "Island " + i as string ) across:1 height:18 offset:[0,-2]
	--	_Button     = _Controls.control #button ( islands_data[#BOTTOM][i] as string + " " + i as string ) across:1 height:18 offset:[0,-4]
	--
	--
	--	_Button.Event #PRESSED "selectIslandVerts" params:(islands_data[#NEW_ISLANDS][i] )
	--
	--
	--	if islands_data[#NEW_ISLANDS][i] != undefined then
	--		_Button.Event #RIGHTCLICK  "selectIslandVerts" params:(islands_data[#NEW_ISLANDS][i] )
	--
	--)




	--Dialog.create()
	Dialog.create height:( (islands_data[#NEW_ISLANDS].count + 1 ) * 20 + 128 )

)
