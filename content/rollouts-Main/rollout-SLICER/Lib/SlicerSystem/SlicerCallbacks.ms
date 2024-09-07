/** Slicer callbacks
 */
struct SlicerCallbacks_v
(
	/* construct */


	/* required */


	/* properties */
	--dialog = DIALOG_elevation_slider,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Slider changed
	 */
	function sliderChanged slice_index =
	(
		format "\n"; print "SlicerCallbacks_v.sliderChanged()"

		layer_index = slice_index + SLICER_SYSTEM.slice_start

		slice_modes = SLICER_SYSTEM.slice_modes

		--/* SET DEAUFLT SLICE TOP */
		--if not (slice_modes[#SLICE_PLANE_TOP] and slice_modes[#SLICE_PLANE_BOTTOM]) then
		--	slice_modes[#SLICE_PLANE_TOP] = true
		--
		--/* ADD MODIFIERS */
		--if slice_modes[#SLICE_PLANE_TOP] then
			SLICER_SYSTEM.setSlicePlaneModifier (#SLICE_PLANE_TOP) (#TRUE) (layer_index) (true)

		/* UPDATE SPINNER VALUE */
		this._setSpinnerValue(layer_index)
	),

	/** Spinner changed
	 */
	function spinnerChanged layer_index =
	(
		format "\n"; print "SlicerCallbacks_v.spinnerChanged()"
		format "layer_index: %\n" layer_index

		SLICER_SYSTEM.setSlicePlaneModifier (#SLICE_PLANE_TOP) (#TRUE) (layer_index) (true)

		--slice_index = layer_index - SLICER_SYSTEM.slice_start
		/* UPDATE SLIDER VALUE */
		this._setSliderValue(layer_index)

	),

	/** Plus minus button
	 */
	function plusMinusButton increment =
	(
		format "\n"; print "SlicerCallbacks_v.plusMinusButton()"
		layer_current	= DIALOG_elevation_slider.SPIN_layer_current.value

		--shift_mode	= #( #LAYERS, #VERTS, #ISLANDS )[DIALOG_elevation_slider.DDL_slider_snaps.selection as integer ]
		shift_mode	= #( #LAYERS, #VERTS )[DIALOG_elevation_slider.DDL_slider_snaps.selection as integer ]

		/* SHIFT: Go 1mm up\down */
		if keyboard.shiftPressed then
		(
			format "shiftPressed\n"
			layer_next = if not keyboard.controlPressed then
			(
				layers_per_mm = ( 1 * display_units / layer_height ) -- add or remove 1mm of current layer

				(layer_current + increment * layers_per_mm) as integer
			)
			/* CTRL + SHIFT: Go 100 layers up\down */
			else
				increment = layer_current + ( increment * 100 )

		)
		/* CTRL: Go next\previous island - if slider dialog is opened */
		else if keyboard.controlPressed and DIALOG_island_manager != undefined then
			layer_next = this._getLayerOfIsland()

		/* GO 1 layer up\down */
		else
			layer_next = layer_current + increment

		/* UPDATE SLIDER VALUE */
		this._setSliderValue(layer_next - SLICER_SYSTEM.slice_start )

		/* UPDATE SPINNER VALUE */
		this._setSpinnerValue(layer_next)
	),

	private

	/** Get layer of island
	 */
	function _getLayerOfIsland =
	(
		--format "\n"; print "SlicerCallbacks_v._getLayerOfIsland()"
			islands_layers = (for item in DIALOG_island_manager.ML_island_listbox.items collect (filterString item " ")[1] as integer ) as BitArray -- get list items strings to bitarray
			--format "ISLANDS_LAYERS: %\n" islands_layers
			--format "islands_layers.count: %\n" islands_layers.count

			layer_current += slice_start

			layer_next = layer_current + layer_index

			if layer_next < 1 then layer_next = 1

			--format "layer_current: %\n" layer_current
			--format "layer_next: %\n" layer_next
			--format "TEST: %\n" (layer_index > 0 and layer_current < islands_layers.count)
			--format "islands_layers[layer_next]: %\n" islands_layers[layer_next]


			if islands_layers[layer_next] == false then
			(
				/* GO ISLAND UP */
				if layer_index > 0 and layer_current < islands_layers.count then
					for i = layer_next to islands_layers.count while not islands_layers[i] do
						layer_next = i + 1

				/* GO ISLAND DOWN */
				else if layer_index < 0 and layer_current > 1  then
					for i = layer_next to 1 by -1 while not islands_layers[i]  do
						layer_next = i - 1

			)

			--format "LAYER_NEXT: %\n" layer_next
			--format "LAYER_NEXT: %\n" layer_next

			if DIALOG_island_manager != undefined and layer_next > 0 then
				ISLANDS_SYSTEM.selectIslandByLayerInListbox (layer_next)

			layer_next -= slice_start


	),



	/** Set slider value
	 */
	function _setSliderValue val =
	(
		DIALOG_elevation_slider.SLIDER_elevation.value = val
	),

	/** Set spinner value
	 */
	function _setSpinnerValue val =
	(
		DIALOG_elevation_slider.SPIN_layer_current.value = val
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SlicerCallbacks.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
