

/** Slice plane dialog
 */
struct SlicerSystem_v
(
	/* construct */
	/* required */
	_objects,

	export_size = DIALOG_content.SPIN_export_size.value,
	layer_height	= DIALOG_content.SPIN_layer_height.value,

	/* properties */
	layers_count,

	min_max_z = #(),

	/* private */
	slice_modes = Dictionary #( #SLICE_PLANE_TOP, true ) #( #SLICE_PLANE_BOTTOM, false ),


	modifiers = Dictionary #NAME,

	linked_to_obj,

	viewport_height,

	/* dependency */
	/* reference */
	/* inhered */

	/** Set obejcts
	 */
	function setObejctsBySelection =
	(
		--format "\n"; print "SlicerSystem_v.setObejctsBySelection()"
		_objects = for obj in selection where superClassOf obj == GeometryClass collect obj

		linked_to_obj = getHandleByAnim _objects[1]

		viewport_height = this.getViewportHeight()

		this.toggleMofifiers(false)

		min_max_z = #( selection.min.z, selection.max.z )

		this.toggleMofifiers(true)

		select _objects

		layers_count = (( min_max_z[2] - min_max_z[1] ) / layer_height ) as integer

	),

	/** Add modifiers
	 */
	function addModifiers =
	(
		--format "\n"; print "SlicerSystem_v.addModifiers()"
		/** Add slice mod
		 */
		function addSliceMod obj slice_mod =
		(
			--format "\n"; print "SlicerSystem_v.addSliceMod()"
			addModifier obj slice_mod

			mod_TM =	(getModContextTM obj slice_mod)	* (  obj.transform )
			--format "mod_TM	= % \n" mod_TM
			setModContextTM obj slice_mod mod_TM
		)

		this._setModifiers()

		for slice_mode_data in slice_modes where slice_mode_data.value do
		(
			slice_modifier = modifiers[slice_mode_data.key]

			/* GET OBJECTS WITH MODIFIER INS */
			objects_with_modifier = refs.dependentNodes slice_modifier

			--format "OBJECTS_WITH_MODIFIER: %\n" objects_with_modifier
			/* ADD MODIIFER WHERE IS NOT */
			for obj in _objects where findItem objects_with_modifier obj == 0 do
			(
				addModifier obj  (Poly_Select name:"SLICE_SELECT_OBJ" )

				addSliceMod (obj)	(slice_modifier)
			)
		)
	),

	/** Toggle mofifiers
	 */
	function toggleMofifiers state =
	(
		--format "\n"; print "SlicerSystem_v.toggleMofifiers()"
		for slice_mode_data in slice_modes where slice_mode_data.value do
		(
			/* GET ALL INSANCES OF MODIFIER IN SCENE */
			modifiers_in_scene = this._getModifiersInScene( slice_mode_data.key )

			/* GET NEW INSANCE MODIFIER */
			if ( slice_modifier = modifiers_in_scene[1] ) != undefined and slice_modifier.enabled != state then
				slice_modifier.enabled = state
		)
	),

	/** Set print elevation
	  *
	  */
	function updateSlicePlaneSystem layer_index incremental:false =
	(
		--format "\n"; print "SlicerSystem_v.updateSlicePlaneSystem()"
		--format "layer_index:	% \n" layer_index
		--format "incremental: %\n" incremental

		/* TODO: ACCESS TO UI VALUES SHOULD BE OUTSIDE FUNCTION

		*/
		layer_current	= DIALOG_elevation_slider.SLIDER_elevation.value

		/* SETUP BY UI
			cap_slice	= ROLLOUT_slicer.CBX_cap_slice.state
			select_plane	= ROLLOUT_slicer.CBX_slice_select_plane.state
			slice_top	= ROLLOUT_slicer.CBX_slice_top.state
			slice_bottom	= ROLLOUT_slicer.CBX_slice_bottom.state
		*/
		cap_slice	= true
		select_plane	= false
		slice_top	= true
		slice_bottom	= false

		/* SET DEAUFLT SLICE TOP */
		if not (slice_top and slice_bottom) then
			slice_top = true

		/* GET INCREMENTAL LAYER INDEX */
		if incremental then
			layer_index += layer_current

		--
		--objects_with_modifier = refs.dependentNodes modifiers[#SLICE_PLANE_TOP]
		----format "objects_with_modifier: %\n" objects_with_modifier
		--
		----reset_slider = false
		--
		--update_selection = for obj in selection where findItem objects_with_modifier obj > 0 and findItem _objects obj == 0 collect obj
		--
		--if update_selection.count > 0 then
		--(
			--format "UPDATE_SELECTION: %\n" update_selection
		--	format "this.layers_count: %\n" this.layers_count
		--
		--	select update_selection
		--
		--	this.setObejctsBySelection()
		--
		--	range = DIALOG_elevation_slider.SPIN_layer_current.range
		--	format "RANGE: %\n" DIALOG_elevation_slider.SPIN_layer_current.range
		--	range.y = this.layers_count
		--
		--	DIALOG_elevation_slider.SPIN_layer_current.range = range
		--	format "RANGE: %\n" DIALOG_elevation_slider.SPIN_layer_current.range
		--	--this._setSliderParams()
		--)


		/* ADD MODIFIERS */
		if slice_top then
			this.setSlicePlaneModifier (#SLICE_PLANE_TOP) (#TRUE) (layer_index) (cap_slice)

		if slice_bottom then
			this.setSlicePlaneModifier (#SLICE_PLANE_BOTTOM) (#TRUE) (layer_index - 1) (cap_slice)

		----format "select_plane	= % \n" select_plane
		--if select_plane then
		--	setSelectPlaneModifier(layer_index) slice_top:slice_top slice_bottom:slice_bottom

		/* UPDATE UI */
		this._updateUi(layer_index)


		--if update_selection.count > 0 then
		--(
		--	select update_selection
		--
		--	this.setObejctsBySelection()
		--
		--	createElevationSliderDialog()
		--)

	),

	/** Set slice plane modifier
	  *
	  * @param int|float layer_index_or_z_pos position where slice plane is elevated
	  *		1) FLOAT:	z pozition in world units
	  *		2) INTEGER:	index of print layer
	  *
	  */
	function setSlicePlaneModifier mode state layer_index_or_z_pos cap_state =
	(
		--format "\n"; print ("SlicerSystem_v.setSlicePlaneModifier()")
		--format "state:	% \n" state
		--format "mode:	% \n" mode
		--format "layer_index_or_z_pos:	% \n" layer_index_or_z_pos

		--mod_name = "SLICE_PLANE_" + toUpper (mode as string )


		if ( slice_mod = modifiers[mode] ) == undefined then
			return false


		--mods_in_scene = this._getModifiersInScene( mod_name )
		--format "MODS_IN_SCENE: %\n" mods_in_scene


		z_pos = if classOf layer_index_or_z_pos == integer then this.getPlaneZpozition (layer_index_or_z_pos) else layer_index_or_z_pos

		--format "z_pos: %\n" z_pos

		/* SET SLICE PLANE POSITION */
		final_TM = Matrix3 1

		final_TM.position.z = z_pos


		--pos01 = [ 0,	0,	z_pos ]
		--pos02 = [ 10,	0,	z_pos ]
		--pos03 = [ 0,	10,	z_pos ]
		--
		--vect1 = normalize (pos02 - pos01)
		--vect2 = normalize (pos03 - pos02)
		--vect3 = normalize (cross vect2 vect1)
		--
		--vect2 = cross vect3 vect1
		--
		--final_TM =  (( Matrix3 vect1 vect2 vect3 ((pos01 + pos02 + pos03) / 3) ))

		/*  UPDATE MODIFIER PROPERTIES */
		slice_mod.slice_plane.transform = final_TM

		slice_mod.Slice_Type = (if mode == #SLICE_PLANE_TOP then 2 else 3 )

		slice_mod.cap = cap_state

	),

	/** Set slider by modifier
	 */
	function setSliderByModifier =
	(
		format "\n"; print "SlicerSystem_v.setSliderByModifier()"

		slice_pos = modifiers[#SLICE_PLANE_TOP].slice_plane.transform.position.z
		format "slice_pos: %\n" slice_pos

		layer_index = this.posToLayerIndex(slice_pos)

		this._updateUi(layer_index)

	),

	/** Desroy
	 */
	function desroySliderDialog =
	(
		--format "\n"; print ".desroy()"
		--removeSlicePlaneModifiers( selection )

		for key in modifiers.keys do
		(
			slice_modifier = modifiers[key]

			/* GET OBJECTS WITH MODIFIER INS */
			if (objects_with_modifier = refs.dependentNodes modifiers[key]).count > 0 then
				for obj in objects_with_modifier do
				deleteModifier obj modifiers[key]

		)

		for obj in objects where (select_mod = obj.modifiers[#SLICE_SELECT_OBJ]) != undefined do
			deleteModifier obj select_mod

		cui.UnRegisterDialogBar DIALOG_elevation_slider

		destroyDialog DIALOG_elevation_slider
	),

	/** Get Layer index by position in world
	 */
	function posToLayerIndex pos =
	(
		--format "\n"; print "SlicerSystem_v.posToLayerIndex()"

		/*  Round float to iteger
		*/
		fn roundToInteger val = floor (val  + 0.5)  as integer

		display_units = case units.SystemType of -- convert to milimeters
		(
			#millimeters:	1
			#centimeters:	10
			#meters:	1000
			#kilometers:	1000000
			default:	1 -- non metric units
		)

		--export_size = DIALOG_content.SPIN_export_size.value
		--layer_height	= DIALOG_content.SPIN_layer_height.value
		--current_layer = DIALOG_elevation_slider.SPIN_layer_current.value

		--format "pos: %\n" pos
		--format "display_units: %\n" display_units
		--format "layer_height: %\n" layer_height
		--format "export_size: %\n" export_size
		/* MOVE SLICE PLANE TO SELCTION BOTTOM */
		layer_index = roundToInteger ((pos * display_units) / layer_height	/ export_size)
		--format "layer_index: %\n" layer_index
		layer_index --return
	),

	/** Toggle slice plane position
	  * @param #TOP|BOTTOM|CENTER pos
	 */
	function toggleSlicePlanePosition pos: =
	(
		--format "\n"; print "SlicerSystem_v.toggleIcepPlanePosition()"
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

			toggleSliceModifiers (true)

			updateSlicePlaneSystem ( layer_index )

			/* DEVELOP FIXING */
			SET_ELEVATION = undefined
		)
	),


	private

	/** Set modifiers
	 */
	function _setModifiers =
	(
		--format "\n"; print "SlicerSystem_v._setModifiers()"
		for slice_mode_data in slice_modes where slice_mode_data.value do
		(
			mod_name = slice_mode_data.key

			mods_in_scene = this._getModifiersInScene( mod_name )

			this.modifiers[mod_name] = if ( slice_mod = mods_in_scene[1] ) != undefined then
				mods_in_scene[1]
			else
				SliceModifier name:( mod_name as string ) Faces___Polygons_Toggle:1 setmaterial:on materialID:3
		)
	),

	/** Set slider params
	 */
	function _setSliderParams =
	(
		--_slider = DIALOG_elevation_slider.SPIN_layer_current

		--DIALOG_elevation_slider.SPIN_layer_current.range.y = this.layers_count
	),

	/** Get height of maximized viewport to find out height of docked dialog
	 */
	function getViewportHeight =
	(
		--print "Dialog_v._getViewportHeight()"
		is_maximized	= viewport.numViews == 1

		height_of_ui	= 0 -- Add heigh
		dialog_title_height	= 30

		--if( trackbar.visible ) then
		--	height_of_ui	+= 27
		--
		--if( timeSlider.isVisible() ) then
		--	height_of_ui	+= 18

		if not( is_maximized ) then
			actionMan.executeAction 0 "50026"  -- Tools: Maximize Viewport Toggle

		viewport_area_size = getViewSize()
		--format "viewport_area_size	= % \n" viewport_area_size
		if not( is_maximized ) then
			actionMan.executeAction 0 "50026"  -- Tools: Maximize Viewport Toggle

		(viewport_area_size[2] as integer) + height_of_ui - dialog_title_height --return
	),

	/** Set print elevation
	  *
	  */
	function getPlaneZpozition layer_index =
	(
		--format "\n"; print "SlicerSystem_v.getPlaneZpozition()"
		--volume_height	= (PrinterVolume_v(DIALOG_content.SPIN_export_size.value)).printer_size.z
		--layer_height	= DIALOG_content.SPIN_layer_height.value
		--layer_current	= DIALOG_elevation_slider.SLIDER_elevation.value
		--layers_count	= volume_height / layer_height

		if layer_index < 0 or layer_index > layers_count then
			layer_index = 	if layer_index < 0  then 0 else layers_count

		layer_index * layer_height + min_max_z[1] --return z poz
	),


	/** Get modifiers in scene
	 */
	function _getModifiersInScene mod_name =
	(
		--format "\n"; print "SlicerSystem_v._getModifiersInScene()"
		--format "mod_name: %\n" mod_name

		--for mod_in_scene in getClassInstances ( SliceModifier ) do
		--format "mod_in_scene.name: %\n" mod_in_scene.name

		mod_name = mod_name as name

		for mod_in_scene in getClassInstances ( SliceModifier ) where mod_in_scene.name as name == mod_name collect mod_in_scene
	),

	/** Compare arrays
	 */
	function _objectsChanged =
	(
		--format "\n"; print "SlicerSystem_v.compareArrays()"
		with PrintAllElements on _objects as string == ( selection as Array ) as string
	),

	/** Update ui
	 */
	function _updateUi layer_index =
	(
		--format "\n"; print "SlicerSystem_v._updateUi()"
		--format "layer_index: %\n" layer_index
		DIALOG_elevation_slider.SPIN_layer_current.value	= layer_index
		DIALOG_elevation_slider.SLIDER_elevation.value	= layer_index
		--DIALOG_elevation_slider.SPIN_layer_current.value	= DIALOG_elevation_slider.SLIDER_elevation.value
	),
	/**
	 */
	on create do
	(
		--format "\n"; print "SlicerSystem.onCreate()"

	)
)