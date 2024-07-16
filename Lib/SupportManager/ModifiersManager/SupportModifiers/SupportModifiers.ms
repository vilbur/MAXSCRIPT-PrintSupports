/** Support modifiers
 */
struct SupportModifiers_v
(
	/* construct */
	/* properties */
	mod_names = #("Bar Width", "Select Base", "Base Width", "Chamfer Base", "Chamfer Bar", "Select Bottom", "Select Top", "Extrude End"),

	mods_support	=  Dictionary #STRING,
	mods_raft	=  Dictionary #STRING,

	/* options */
	/* dependency */
	/* reference */
	/* inhered */

	/** Sweep radius must be set when modifier is added to object
	 */
	function setSweepRadius =
	(
		--format "\n"; print "SupportModifiers_v.setSweepRadius()"
		mods_support["Bar Width"][#Cylinder_Section].radius = this._getOption #BAR_WIDTH / 2
	),

	/** Init modifiers
	 */
	function _initModifiers =
	(
		format "\n"; print "SupportModifiers_v.initModifiers()"
		--format "SUPPORT_OPTIONS.chamfer_values: %\n" SUPPORT_OPTIONS.chamfer_values
		function renameSupportsByKey mods = for mod_name in mods.keys do mods[mod_name].name = mod_name

		this._sanitizeMaxChamferValue()

		/* SUPPORT MODIFIERS */
		mods_support["Bar Width"]	= this._sweepSetup	(sweep	())	(this._getOption #BAR_WIDTH )
		mods_support["Select Base"]	= this._volSelectSetup	(Vol__Select	())	(this._getMatId  #BASE )
		mods_support["Base Width"]	= this._extrudeSetup	(Face_Extrude	())	(this._getOption #BASE_WIDTH )
		mods_support["Chamfer Base"]	= this._chamferSetup	(Chamfer	())	(this._getChamferVal #BASE )
		mods_support["Chamfer Bar"]	= this._chamferSetup	(Chamfer	())	(this._getChamferVal #TOP )	selection_option:#ALL  materialoption:#DIFFERENT
		mods_support["Select Top"]	= this._volSelectSetup	(Vol__Select	())	(this._getMatId  #TOP )	--
		mods_support["Extrude End"]	= this._extrudeSetup	(Face_Extrude	())	(this._getOption #EXTRUDE_END )

		renameSupportsByKey(mods_support)

		/* RAFT MODIFIERS */
		mods_raft["Bar Width"]	= mods_support["Bar Width"]
		mods_raft["Extrude End"]	= mods_support["Extrude End"]

		--mods_support["Select Bottom"]	= this._volSelectSetup	(Vol__Select	name:"Select Bottom")	(this._getMatId  #BASE )

		mods_raft["Chamfer Bar"]	= this._chamferSetup	(copy mods_support["Chamfer Bar"])	(this._getChamferVal #TOP )	material_ID:(this._getMatId #MIDDLE ) materialoption:#OFF
		mods_raft["Select Top"]	= this._volSelectSetup	(copy mods_support["Select Top"])	(this._getMatId #MIDDLE )	invert_sel:true

		renameSupportsByKey(mods_raft)
	),

	/** Copy modifier
	 */
	function _copyModifier from_name to_name =
	(
		--format "\n"; print "SupportModifiers_v._vopyModifier()"
		modi = copy mods_support[from_name]

		modi.name = to_name

		modi --return
	),




	/** SWEEP Modifier
	  *
	  */
	function _sweepSetup sweep_mod diameter =
	(
		format "\n"; print "SupportModifiers_v._sweep()"
		format "diameter: %\n" diameter

		/** Reset mod propertis -- sweep mpdofoer keeps its settings if newly created, i dont know why.. oteh modifiers dont do that :D

			QUICK SOLUTION - FOR MORE MODIFIERS OR PROPERTIES SHOULD COMPLEX SOLUTUION EXISTS

		 */
		function resetSweepModProperties sweep_mod =
		(
			sweep_mod.MirrorXZPlane = off
			sweep_mod.MirrorXYPlane = off

			sweep_mod.XOffset = 0
			sweep_mod.yOffset = 0

			sweep_mod.angle = 0
			sweep_mod.SmoothSection = off
			sweep_mod.SmoothPath = off
			sweep_mod.PivotAlignment = 4


			sweep_mod.GenMatIDs = on
			sweep_mod.UseSectionIDs = off
			sweep_mod.UsePathIDs = off
		)

		--sweep_mod = if superClassOf modi == modifier then modi else sweep name:modi

		--format "selection: %\n" (selection as Array )
		--format "SWEEP_MOD: %\n" sweep_mod
		--format "sweep_mod: %\n" (classOf sweep_mod)

		--if superClassOf mod_or_name != modifier then -- if not update mode
		--(
			resetSweepModProperties(sweep_mod)

			--modPanel.addModToSelection ( sweep_mod ) --ui:on
			sweep_mod.CurrentBuiltInShape = 4 -- Set cylinder





			--redrawViews() -- IMPORTANT TO UPDATE AFTER SETTING SHAPE AND BEFORE EDITING ITS PROPERTIES
			--sweep_mod[#Cylinder_Section].steps	= 6 -- Interpolation
			--
			----sweep_mod[#Bar_Section].cornerRadius = 0
			--/* GENERATE MATERIAL ID */
			sweep_mod.UseSectionIDs	= false
			sweep_mod.UsePathIDs	= true
		--)

		--sweep_mod[#Cylinder_Section].radius	= diameter / 2

		sweep_mod --return
	),



	/** Add edit spline
	  *
	  */
	function _addEditSpline =
	(
		format "\n"; print "SupportModifiers_v._addEditSpline()"
		modPanel.addModToSelection (Edit_Spline ())
	),

	/** Add SELECT modifier
	  *
	  */
	function _volSelectSetup vol_sel_mod mat_id invert_sel:false =
	(
		--format "\n"; print "SupportModifiers_v._selectSetup()"
		--format "Adding Volume Select\n"

		--vol_sel_mod = Vol__Select name:name

		vol_sel_mod.level	= 2	-- select face
		vol_sel_mod.volume	= 5	-- select by material ID
		vol_sel_mod.matID	= mat_id	-- select face by mat ID
		vol_sel_mod.invert	= invert_sel	-- select face by mat ID

		--for support in supports do
			--addModifier support volume_sel_mod

		--modPanel.addModToSelection ( volume_sel_mod ) --ui:on
		vol_sel_mod --return
	),

	/** Chamfer
	  *
	  * @param #DIFFERENT|#OFF materialoption
	  */
	function _chamferSetup chamfer_mod amount selection_option:#STACK materialoption:#OFF material_ID: /* minangle:  */ =
	(
		--format "\n"; print "SupportModifiers_v._chamfer()"
		--format "mod_or_name: %\n" mod_or_name
		--format "mod_or_name: %\n" (getHandleByAnim mod_or_name)
		--format "amount: %\n" amount
		--chamfer_mod = if superClassOf mod_or_name == modifier then mod_or_name else Chamfer name:mod_or_name

		--if superClassOf mod_or_name != modifier then -- if not update mode
		--(
			--chamfer_mod = Chamfer name:mod_or_name

			chamfer_mod.selectionoption = case selection_option of
			(
				#STACK:	0 -- from stack
				#ALL:	5 -- all edges
			)

			/* SET CHAMFER VALUES */
			chamfer_mod.amount 	 = amount

			chamfer_mod.segments = 0

			/* UNSMOOTH OBJECT */
			chamfer_mod.smooth 	= true

			chamfer_mod.SmoothType = 0

			chamfer_mod.smooththreshold = 0

			chamfer_mod.materialoption = case materialoption of -- CHAMFER MATERIAL
										(
											#OFF:	0 -- mat_ids off
											#DIFFERENT:	1 -- different mat_ids
										)
			/* ALLOW MATERIAL */
			chamfer_mod.setmaterial	= classOf material_ID == integer


			/* ASSIGN CHAMFER MATERIAL */
			if classOf material_ID == integer then
				chamfer_mod.materialID	= material_ID

			--modPanel.addModToSelection ( chamfer_mod ) --ui:on

		--	for support in supports do
		--		addModifier support chamfer_mod
		--)
		--else
		--	mod_or_name.amount = amount

		chamfer_mod --return
	),

	/** Add extrude modifier
	  *
	  */
	function _extrudeSetup extrude_mod amount scale: =
	(
		--format "\n"; print "SupportModifiers_v._extrudeBase()"
		--extrude_mod = if superClassOf mod_or_name == modifier then mod_or_name else Face_Extrude name:mod_or_name

		extrude_mod.amount	= amount

		--if scale != unsupplied then
			--extrude_mod.scale	= scale

		--if classOf mod_or_name == string then -- if not update mode
		--	for support in supports do
		--		addModifier support extrude_mod

			--modPanel.addModToSelection ( extrude_mod ) --ui:on
		extrude_mod --return
	),
	/** Make sure that chamfer value is less then radius
	  */
	function _sanitizeMaxChamferValue =
	(
		--format "\n"; print "SupportModifiers_v._sanitizeMaxChamferValue()"
		if SUPPORT_OPTIONS.bar_width / 2 == SUPPORT_OPTIONS.chamfer_bar then
			SUPPORT_OPTIONS.chamfer_bar -= 0.05
	),


	/** Get chamfer val
	 */
	function _getChamferVal dict_key =
	(
		--format "\n"; print "SupportOptions_v.getChamferVal()"
		--dict_key = dict_key as name

		SUPPORT_OPTIONS.chamfer_values[dict_key]
	),

	/** Get prop of this
	 */
	function _getOption prop_key dict_key:"" =
	(
		--format "\n"; print "SupportOptions_v.getProp()"
		prop_key = prop_key as string
		dict_key = dict_key as name

		val = getProperty SUPPORT_OPTIONS prop_key

		if classOf val == Dictionary then
			val = val[dict_key]

		val --return
	),

	/** Get mat id
	 */
	function _getMatId mat_key =
	(
		--format "\n"; print "SupportModifiers_v._getMatId()"
		mat_ids = getProperty SUPPORT_OPTIONS "MAT_IDS"

		mat_ids[mat_key] --return
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SupportModifiers_v.onCreate()"
		this._initModifiers()
	)
)