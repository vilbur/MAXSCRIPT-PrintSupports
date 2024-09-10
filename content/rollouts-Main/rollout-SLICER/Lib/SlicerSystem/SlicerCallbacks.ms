/** Slicer callbacks
 */
struct SlicerCallbacks_v
(
	/* construct */


	/* required */


	/* properties */
	--dialog = DIALOG_slicer_slider,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Slider changed
	 */
	function onSliderChanged slice_index =
	(
		format "\n"; print "SlicerCallbacks_v.sliderChanged()"
		format "SLICER_SYSTEM.slice_start: %\n" SLICER_SYSTEM.slice_start

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
		SLICER_SYSTEM.setSpinnerValue(layer_index)
	),

	/** Spinner changed
	 */
	function onSpinnerChanged layer_index =
	(
		format "\n"; print "SlicerCallbacks_v.spinnerChanged()"
		format "layer_index: %\n" layer_index

		/* UPDATE MODIFIER */
		SLICER_SYSTEM.setSlicePlaneModifier (#SLICE_PLANE_TOP) (#TRUE) (layer_index) (true)

		--slice_index = layer_index - SLICER_SYSTEM.slice_start
		/* UPDATE SLIDER VALUE */
		SLICER_SYSTEM.setSliderValue(layer_index)

	),

	/** Plus minus button
	 */
	function onPlusMinusButton increment =
	(
		format "\n"; print "SlicerCallbacks_v.plusMinusButton()"
		layer_current	= DIALOG_slicer_slider.SPIN_layer_current.value
		format "layer_current: %\n" layer_current
		format "SLICER_SYSTEM.slice_start: %\n" SLICER_SYSTEM.slice_start


		--shift_mode	= #( #LAYERS, #VERTS, #ISLANDS )[DIALOG_slicer_slider.DDL_slider_snaps.selection as integer ]
		shift_mode	= #( #LAYERS, #VERTS )[DIALOG_slicer_slider.DDL_slider_snaps.selection as integer ]

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
			layer_next = ISLANDS_SYSTEM.getLayerOfClosestIsland(layer_current)(increment)

		/* GO 1 layer up\down */
		else
			layer_next = layer_current + increment

		format "LAYER_NEXT: %\n" layer_next

		/* UPDATE MODIFIER */
		SLICER_SYSTEM.setSlicePlaneModifier (#SLICE_PLANE_TOP) (#TRUE) (layer_next) (true)

		/* UPDATE SLIDER VALUE */
		SLICER_SYSTEM.setSliderValue( layer_next - SLICER_SYSTEM.slice_start )

		/* UPDATE SPINNER VALUE */
		SLICER_SYSTEM.setSpinnerValue(layer_next)

		if keyboard.controlPressed and DIALOG_island_manager != undefined then
			ISLANDS_SYSTEM.selectIslandByLayerInListbox #{layer_next}

	),

	/** Desroy slider dialog and delete modifiers
	 */
	function desroySliderDialogAndDeleteModifiers =
	(
		--format "\n"; print "SlicerCallbacks_v.desroySliderDialogAndDeleteModifiers()"

		SLICER_SYSTEM.desroySliderDialog()

		SLICER_SYSTEM.deleteModifiers()
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SlicerCallbacks.onCreate()"
	)
)