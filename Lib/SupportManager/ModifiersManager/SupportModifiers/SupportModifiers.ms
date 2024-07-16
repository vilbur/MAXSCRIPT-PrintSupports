/** Support modifiers
 */
struct SupportModifiers_v
(
	/* construct */
	/* properties */
	mod_names = #("Bar Width", "Select Base", "Base Width", "Chamfer Base", "Chamfer Bar", "Select Ends", "Select Top", "Extrude End"),

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
		mods_support["Bar Width"][#Cylinder_Section].radius = SUPPORT_OPTIONS.getOption #BAR_WIDTH
	),

	/** Init modifiers
	 */
	function _initModifiers =
	(
		--format "\n"; print "SupportModifiers_v.initModifiers()"
		--format "SUPPORT_OPTIONS.chamfer_values: %\n" SUPPORT_OPTIONS.chamfer_values
		function renameSupportsByKey mods = for mod_name in mods.keys do mods[mod_name].name = mod_name

		OPTIONS = SUPPORT_OPTIONS


		/* SUPPORT MODIFIERS */
		mods_support["Bar Width"]	= this._sweepSetup	(sweep	())	(OPTIONS.getOption #BAR_WIDTH )
		mods_support["Select Base"]	= this._volSelectSetup	(Vol__Select	())	(OPTIONS.getMatId  #BASE )
		mods_support["Base Width"]	= this._extrudeSetup	(Face_Extrude	())	(OPTIONS.getOption #BASE_WIDTH )
		mods_support["Chamfer Base"]	= this._chamferSetup	(Chamfer	())	(OPTIONS.getOption #CHAMFER_BASE )
		mods_support["Chamfer Bar"]	= this._chamferSetup	(Chamfer	())	(OPTIONS.getOption #CHAMFER_BAR )	selection_option:#ALL  materialoption:#DIFFERENT
		mods_support["Select Top"]	= this._volSelectSetup	(Vol__Select	())	(OPTIONS.getMatId  #TOP )
		mods_support["Extrude End"]	= this._extrudeSetup	(Face_Extrude	())	(OPTIONS.getOption #EXTRUDE_END )

		renameSupportsByKey(mods_support)

		/* RAFT MODIFIERS */
		mods_raft["Bar Width"]	= mods_support["Bar Width"]
		mods_raft["Extrude End"]	= mods_support["Extrude End"]


		mods_raft["Chamfer Bar"]	= this._chamferSetup	(copy mods_support["Chamfer Bar"])	(OPTIONS.getOption #CHAMFER_BAR )	material_ID:(OPTIONS.getMatId #MIDDLE ) materialoption:#OFF
		mods_raft["Select Ends"]	= this._volSelectSetup	(copy mods_support["Select Top"])	(OPTIONS.getMatId #MIDDLE )	invert_sel:true
		--mods_raft["Select Bottom"]	= this._volSelectSetup	(copy mods_support["Select Bottom"])	(this._getMatId #MIDDLE )	invert_sel:true

		renameSupportsByKey(mods_raft)
	),

	/** SWEEP Modifier
	  *
	  */
	function _sweepSetup sweep_mod diameter =
	(
		--format "\n"; print "SupportModifiers_v._sweep()"

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

		resetSweepModProperties(sweep_mod)

		sweep_mod.CurrentBuiltInShape = 4 -- Set cylinder

		/* GENERATE MATERIAL ID */
		sweep_mod.UseSectionIDs	= false
		sweep_mod.UsePathIDs	= true

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

		vol_sel_mod.level	= 2	-- select face
		vol_sel_mod.volume	= 5	-- select by material ID
		vol_sel_mod.matID	= mat_id	-- select face by mat ID
		vol_sel_mod.invert	= invert_sel	-- select face by mat ID

		vol_sel_mod --return
	),

	/** Chamfer
	  *
	  * @param #DIFFERENT|#OFF materialoption
	  */
	function _chamferSetup chamfer_mod amount selection_option:#STACK materialoption:#OFF material_ID: /* minangle:  */ =
	(
		--format "\n"; print "SupportModifiers_v._chamfer()"

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

		chamfer_mod --return
	),

	/** Add extrude modifier
	  *
	  */
	function _extrudeSetup extrude_mod amount scale: =
	(
		--format "\n"; print "SupportModifiers_v._extrudeBase()"
		extrude_mod.amount	= amount

		extrude_mod --return
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SupportModifiers_v.onCreate()"
		this._initModifiers()
	)
)