/** Support options
  *
  *
  * IMPORTANT: Control id, SupportOptions.porp and Modifiers names MUST HAVE SAME NAME
  *
  *		UI Control id	-> #cbx_bar_width
  *		SupportOptions.prop	-> #bar_width
  *		Modifier.prop	-> #bar_width
  *
 */
struct SupportOptions_v
(
	/* construct */
	_rollout, -- rollout where values are store in UI
	export_size = 1,

	_DO_NOT_MODIFY_PROPERTIES = #( #DISPLAY_UNITS, #EXPORT_SIZE, #USE_NTH_VERTEX , #CHAMFER_TOP, #BEAMS_COUNT, #SECOND_POINT_DIRECTION ),

	/* POINT GENERATOR OPTIONS */
	use_normals	= true,
	normal_length	= 1,
	----normal_limit	= false, -- obsolete
	--keep_down	= true, -- obsolete
	----keep_down_limit	= 1, -- obsolete

	second_point_direction	= 1,

	use_nth_vertex	= 1,

	live_update_supports = false,

	/* SUPPORT OBJECT OPTIONS */
	layer_height = 0.05,

	bottom_layers_count = 15,


	/* SUPPORT MODIFIERS */
	bar_width 	= 1.5, -- default width is 1.5mm

	base_height	= 1.0,
	base_width	= 4.0,

	extrude_top	= 0.5,

	chamfer_base = 2,
	chamfer_bar	= 5,	-- CHAMFER MIN: 0 - CHAMFER MAX: 10

	/* support prop */
	chamfer_values = Dictionary(),

	/* RAFT OPTIONS */
	raft_width 	= 0.5,

	/* BEAMS OPTIONS */
	beams_count = 2,
	max_distance	= 20,	-- max distance between supports
	min_height	= 10,	-- generate beams only if support is higher than this number=
	max_height	= 20,	-- gmax height between of beam split
	--same_height	= false,



	/* PINS OPTIONS */
	pin_width	= 3.0, -- outter diametter of outter pin
	pin_height	= 5.0, -- outter diametter of outter pin
	pin_gap 	= 0.2, -- size of gap between inner and outter pin


	/* PRIVATE PROPERTIES */
	display_units = 1, -- correct size of platforms, E.g.: IF MODEL IS MADE IN METERS BUT IT IS PRINTED SCALED DOWN TO MILIMETERS

	quiet_mode = false,

	mat_ids	= Dictionary #( #TOP, 1 /* READ-ONLY */ ) #( #NORMAL, 7 ) #( #MIDDLE, 3 ) #( #BASE, 4 ) #( #BOTTOM, 2 /* READ-ONLY */ ) #( #CHMAFER, 5 ) #( #BEAM, 6 ), -- #top and #bottom are read-only and they are default by Edit Spline

	/** GET INSTANCE OF SUPPORT GENERATOR
	  *
	  */
	function getValuesFroUi =
	(
		format "\n"; print "SupportOptions_v.getValuesFroUi()"
		/** Reg ex replace
		 */
		function regExReplace _string search _replace = ( dotNetObject "System.Text.RegularExpressions.Regex" search ).Replace ( _string as string ) _replace

		export_size = if ROLLOUT_export == undefined then
		(
			format "\n============= WARNING =============\n"

			print "VilTools Exporter does not exists"
			print "Export Size 1 is used"

			1 --return
		)
		else
		  ROLLOUT_export.SPIN_export_size.value


		control_type_to_fetch_values = "SPIN|CBX|RB"

		/** FILL SupportManager PROPERTIES WITH DATA FROM UI
		  *
		  * Perform kind of this in loop:
		  *   Options.base_extrude	= roll.SPIN_base_width.value
		  */
		--for ctrl in ROLLOUT_supports.controls where (prop_key = regExReplace ctrl.name ("^("+control_type_to_fetch_values+")_") "") != undefined and hasProperty SUPPORT_OPTIONS prop_key do
		for ctrl in this._rollout.controls where (prop_key = regExReplace ctrl.name ("^("+control_type_to_fetch_values+")_") "") != undefined and hasProperty SUPPORT_OPTIONS prop_key do
		--for ctrl in _rollout.controls where (prop_key = regExReplace ctrl.name ("^("+control_type_to_fetch_values+")_") "") != undefined and hasProperty SUPPORT_OPTIONS prop_key do
			this.setOptionValue prop_key ( if classOf ctrl == CheckBoxControl or classOf ctrl == RadioControl  then ctrl.state else ctrl.value )

		this.init()
	),

	/** Init
	  *
	  */
	function init =
	(
		--format "\n"; print "SupportOptions_v.init()"
		this._setUnitsMuliplier()

		this._setDimensions()

		this._setChamferValues()
	),

	/** Set property value of this struct
	 */
	function setOptionValue prop_key val =
	(
		--format "\n"; print "SupportOptions_v.setOptionValue()"
		--format "key: %\n" prop_key
		--format "val: %\n" val

		setProperty this prop_key val
	),

	/** Get node prop data
	 */
	function _getUserProp obj prop_key as_string:false =
	(
		--format "\n"; print "SupportOptions_v._getUserProp()"

		key = ( toLower ( prop_key as string ))

		getUserPropVal obj key asString:as_string --return
	),

	/** Set node prop data
	 */
	function _setUserProp obj prop_key val =
	(
		--format "\n"; print "SupportOptions_v._setUserProp()"
		key = ( toLower ( prop_key as string ))

		setUserPropVal obj key val --return
	),

	/** Set node prop data from node to node
	 */
	function syncProp from_object to_object from_key destination_key: =
	(
		--format "\n"; print "SupportOptions_v._setUserProp()"
		if destination_key == unsupplied then
			destination_key = from_key

		from_key =	( toLower ( from_key as string ))
		destination_key = 	( toLower ( destination_key as string ))

		setUserPropVal to_object from_key ( getUserPropVal from_object destination_key )
	),

	/** Get this pointer
	 */
	function getThisPointer obj =
	(
		--format "\n"; print "SupportOptions_v.getThisPointer()"
		local this_pointer

		if ( this_pointer = this._getUserProp obj #THIS ) == undefined then
		(
			this_pointer = getHandleByAnim obj

			this._setUserProp obj #THIS this_pointer
		)

		this_pointer
	),


	private

	/** Set units muliplier
	  *
	  */
	function _setUnitsMuliplier =
	(
		--format "\n"; print "SupportOptions_v.setUnitsMuliplier()"

		display_units = case units.SystemType of -- convert to milimeters
		--this.display_units = case units.MetricType of -- convert to dispaly units
		(
			#millimeters:	1
			#centimeters:	10
			#meters:	1000
			#kilometers:	1000000
			default:	1 -- non metric units
		)
	),

	/** Set dimensions
	  *
	  */
	function _setDimensions =
	(
		--format "\n"; print "SupportOptions_v._setDimensions()"
		--format "DISPLAY_UNITS:	% \n" display_units
		--format "EXPORT_SIZE:	% \n" export_size

		for prop in getPropNames this where ( superClassOf (val = getProperty this prop )) == Number do
			if val != undefined and findItem _DO_NOT_MODIFY_PROPERTIES prop == 0  then
			(
				--format "\n\n"
				format "%: %\n" prop val
				modified_val = (val / display_units	/ export_size)
				--format "modified_val: %\n" modified_val
				setProperty this prop modified_val
			)
	),

	/** Set base height
	  *
	  */
	function _setBaseHeight =
	(
		--format "\n"; print "SupportOptions_v._setBaseHeight()"
		base_height = this.bottom_layers_count * this.layer_height / export_size
	),

	/** Set chamfer values, derivated from bar width
	  *
	  */
	function _setChamferValues =
	(
		--format "\n"; print "SupportOptions_v._setChamferValues()"
		this.chamfer_values[#BASE]	= base_height / 2
		this.chamfer_values[#TOP]	= (bar_width  / 2 / 10) * chamfer_bar -- chamfer in steps between 0-10
		this.chamfer_values[#RAFT]	= (raft_width / 2 / 10) * chamfer_bar
		--format "CHAMFER_VALUES: %\n" this.chamfer_values
	),

	/**
	 *
	 */
	on create do
	(
		--format "\n"; print "SupportOptions_v.create()"
		--format "\nIMPORTANT\n"
		--format "EXPORT_SIZE:	% \n" export_size
		--this.getValuesFroUi()
	)
)
