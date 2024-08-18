		/** Toggle slice plane position
		  * @param #TOP|BOTTOM|CENTER pos
		 */
		function toggleSlicePlanePosition pos: =
		(
			--format "\n"; print ".toggleIcepPlanePosition()"
			--print "createElevationSliderDialog SLIDER_elevation rightClick"
			/** Toggle slice modifiers
			 */
			function toggleSliceModifiers state mod_names:#( #SLICE_PLANE_TOP, #SLICE_PLANE_BOTTOM ) =
			(
				for obj in selection do
					for mod_name in mod_names where ( _mod = obj.modifiers[mod_name] ) != undefined do
						_mod.enabled = state
			)

			/** Get values of wolrd aligned bbox
			  * @return float
			 */
			function getBbox obj minmax axis = getProperty (( nodeGetBoundingBox obj ( Matrix3 1) )[if minmax == #min then 1 else 2 ]) axis

			/** Get next item
			 */
			function getNextItem arr index = if (next_pos = arr[index + 1]) != undefined then next_pos else arr[1]


			if selection.count > 0 then
			(

				if SET_ELEVATION == undefined then
					SET_ELEVATION = Dictionary #("SELECTION", "" ) #("TRANSFROM", Matrix3 1 )

				current_layer	= DIALOG_elevation_slider.SPIN_layer_current.value
				selection_pointer = (for obj in selection collect getHandleByAnim obj) as string


				/* GET OBEJCT DIMENSIONS AND Z POSITIONS OF LAYERS */
				if SET_ELEVATION["SELECTION"] != selection_pointer or SET_ELEVATION["TRANSFROM"] != $.transform then -- get new data if selection or transform of selection changed
				(
					--format "SELECTION CHANGED	= % \n" SET_ELEVATION

					toggleSliceModifiers (false)

					selection_min	= amin(for obj in selection collect getBbox (obj) (#min) (#z) )
					selection_max	= amax(for obj in selection collect getBbox (obj) (#max) (#z) )
					selection_center	= (selection_min + selection_max ) / 2

					layer_index_min = posToLayerIndex( selection_min ) --+1 -- Without 1 then first layer under object is selected
					layer_index_max = posToLayerIndex( selection_max )
					layer_index_center = posToLayerIndex( selection_center )

					--layer_index_min+=10

					layer_positions = #( layer_index_min, layer_index_center, layer_index_max )

					SET_ELEVATION["SELECTION"]	= selection_pointer
					SET_ELEVATION["LAYER_POSITIONS"]	= layer_positions

				)

				layer_positions = SET_ELEVATION["LAYER_POSITIONS"]

				current_pos_index = findItem layer_positions current_layer


				layer_index = case pos of
				(
					(#TOP):	selection_max
					(#BOTTOM):	layer_index_min
					(#CENTER):	layer_index_center

					default: case of
					(
						( keyboard.controlPressed):	layer_positions[1] -- GET SELECOIN  MIN IF CTRL RPESSED
						((next_item = getNextItem(layer_positions)(current_pos_index)) != undefined ):	next_item	-- GET NEXT PREDEFINED POSITION
						default:	layer_positions[2]	-- GET SELECTION CENTER AS DEFAULT
					)
				)




				--format "BBOX	= % \n" ( nodeGetBoundingBox selection[1] ( Matrix3 1))
				--format "Z MIN	= % \n" ( amin(for obj in selection collect getBbox (obj) (#min) (#z) ))
				--format "LAYER_POSITIONS	= % \n" layer_positions
				--format "LAYER_INDEX	= % \n" layer_index
				toggleSliceModifiers (true)


				updateSlicePlaneSystem ( layer_index )


				/* DEVELOP FIXING */
				SET_ELEVATION = undefined
			)
		)
