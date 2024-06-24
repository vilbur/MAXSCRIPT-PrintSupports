/** Support modifiers
 */
struct SupportModifiers_v
(

	/* construct */
	--Options,
	--mat_ids,

	/* properties */
	supports,
	raft_mode = false,
	update_mode = false,


	/* options */
	chamfer_values = Dictionary(),


	/* dependency */
	/* reference */
	/* inhered */

	/** Add modifiers
	  *
	  */
	function addModifiers supports raft_mode:false =
	(
		--format "\n-----------------------------------------\n"
		format "\n"; print "SupportModifiers_v.addModifiers()"
		format "supports	= % \n" supports
		format "supports.count	= % \n" supports.count
		format "raft_mode: %\n" raft_mode
		format "SUPPORT_OPTIONS: %\n" SUPPORT_OPTIONS
		--if raft_mode == unsupplied then
		_selection = for o in selection  collect o


		if supports.count == 0 then
			return false

		max modify mode

		this.raft_mode = raft_mode

		--supports_with_modifiers = for support_input in supports_input where support_input.modifiers.count == 0 collect support_input

		this.supports = supports

		this._setChamferValues()

		if not this._modifiersAdded() then
		(
			select supports

			this._sanitizeMaxChamferValue()


			this._sweep("Bar Width") ( if raft_mode then SUPPORT_OPTIONS.raft_width else SUPPORT_OPTIONS.bar_width )

			--format "RAFT_MODE	= % \n" raft_mode
			--format "not raft_mode	= % \n" (not raft_mode)
			if not raft_mode then
			(
				this._selectFace("Select Base")(SUPPORT_OPTIONS.mat_ids[#BASE])

				this._extrude("Base Width") (SUPPORT_OPTIONS.base_width)

				this._chamfer("Chamfer Base") (this.chamfer_values[#BASE])
			)


			this._chamfer("Chamfer Bar")  (this.chamfer_values[ if raft_mode then #RAFT else #TOP]) selection_option:#ALL materialoption:( if raft_mode then #OFF else #DIFFERENT )  material_ID:( if raft_mode then SUPPORT_OPTIONS.mat_ids[#MIDDLE] )

			this._selectFace("Select Top Face")(SUPPORT_OPTIONS.mat_ids[ if raft_mode then #MIDDLE else #TOP ]) invert_sel:raft_mode

			this._extrude("Extrude Top")(SUPPORT_OPTIONS.extrude_top)

		)
		else
			this._copyModifiers()

		select _selection
	),

	/** Update modifier by value in SUPPORT_OPTIONS
	 */
	function updateModifier supports mod_name =
	(
		clearListener(); print("Cleared in:\n"+getSourceFileName())
		format "\n"; print "SupportModifiers_v.updateModifier()"
		format "supports: %\n" supports
		format "count: %\n" supports.count
		mod_name = mod_name as name
		format "mod_name: %\n" mod_name

		mods = makeUniqueArray (for support in supports where ( _mod = support.modifiers[mod_name]) != undefined collect _mod)

		format "mods: %\n" mods
		format "mods: %\n" ( superClassOf mods[1] )
		format "makeUniqueArray mods: %\n" (makeUniqueArray mods)
		--for obj in nodes do
		--   for _mod in obj.modifiers where refhierarchy.IsRefTargetInstanced _mod do
		--		if _mod == _modifier then
		--			append objects_with_mod obj
		this._setChamferValues()

		for _mod in mods do
			case classOf _mod of
			(
				(Face_Extrude):	this._extrude(_mod)	(SUPPORT_OPTIONS.base_width)
				(Chamfer):	this._chamfer(_mod)	(this.chamfer_values[ if raft_mode then #RAFT else #TOP])
				(sweep):	this._sweep(_mod)	(if raft_mode then SUPPORT_OPTIONS.raft_width else SUPPORT_OPTIONS.bar_width)
				--default:
			)


	),

	private

	/** Modifiers exists
	 */
	function _modifiersAdded =
	(
		--format "\n"; print "SupportModifiers_v._modifiersAdded()"
		(this._getSupportsWithModfiers()).count > 0
	),

	/** Copy modifiers
	 */
	function _copyModifiers =
	(
		--format "\n"; print "SupportModifiers_v._copyModifiers()"

		/* DIRTY CODE - TIME RPOEASSURE */

		support_with_modifiers	= (this._getSupportsWithModfiers())[1]
		supports_no_modifiers	= this._getSupportsWithoutModfiers()

		modifiers_of_supports	= support_with_modifiers.modifiers

		for support_no_modifiers in supports_no_modifiers do
			for i = modifiers_of_supports.count to 1 by -1 do
				addModifierWithLocalData support_no_modifiers modifiers_of_supports[i] support_with_modifiers modifiers_of_supports[i] -- instance the modifier


		--for i = modifiers_of_supports.count to 1 by -1 do
		--	try(
		--			addModifier supports_no_modifiers modifiers_of_supports[i]
		--	)catch()

	),



	/** SWEEP Modifier
	  *
	  */
	function _sweep mod_or_name diameter =
	(
		format "\n"; print "SupportModifiers_v._sweep()"

		/** Reset mod prpertis -- sweep mpdofoer keeps its settings if newly created, i dont know why.. oteh modifiers dont do that :D

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

		sweep_mod = if superClassOf mod_or_name == modifier then mod_or_name else sweep name:mod_or_name

		format "selection: %\n" (selection as Array )
		format "SWEEP_MOD: %\n" sweep_mod
		format "sweep_mod: %\n" (classOf sweep_mod)

		if classOf mod_or_name == string then -- if not update mode
		(
			resetSweepModProperties(sweep_mod)

			modPanel.addModToSelection ( sweep_mod ) --ui:on
			sweep_mod.CurrentBuiltInShape = 4 -- Set cylinder

			redrawViews() -- IMPORTANT TO UPDATE AFTER SETTING SHAPE AND BEFORE EDITING ITS PROPERTIES
			sweep_mod[#Cylinder_Section].steps	= 6 -- Interpolation

			--sweep_mod[#Bar_Section].cornerRadius = 0
			/* GENERATE MATERIAL ID */
			sweep_mod.UseSectionIDs	= false
			sweep_mod.UsePathIDs	= true

		)

		sweep_mod[#Cylinder_Section].radius	= diameter / 2
	),

	/** Add edit spline
	  *
	  */
	function _addEditSpline =
	(
		format "\n"; print "PlatformModifiers_v._addEditSpline()"
		modPanel.addModToSelection (Edit_Spline ())
	),

	/** Add SELECT modifier
	  *
	  */
	function _selectFace name mat_id invert_sel:false =
	(
		format "\n"; print "SupportModifiers_v._selectFace()"
		--format "Adding Volume Select\n"

		volume_sel_mod = Vol__Select name:name

		volume_sel_mod.level	= 2	-- select face
		volume_sel_mod.volume	= 5	-- select by material ID
		volume_sel_mod.matID	= mat_id	-- select face by mat ID
		volume_sel_mod.invert	= invert_sel	-- select face by mat ID

		modPanel.addModToSelection ( volume_sel_mod ) --ui:on
	),

	/** Chamfer
	  *
	  *
	  * @param #DIFFERENT|#OFF materialoption
	  */
	function _chamfer mod_or_name amount selection_option:#STACK materialoption:#OFF material_ID: /* minangle:  */ =
	(
		format "\n"; print "SupportModifiers_v._chamfer()"
		format "mod_or_name: %\n" mod_or_name
		format "amount: %\n" amount

		chamfer_mod = if superClassOf mod_or_name == modifier then mod_or_name else Chamfer name:mod_or_name

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

		/* BACKUP MAYBE IT WILL BE NEEDE NEEDED

			--chamfer_mod.minangle = minangle

		*/
		if classOf mod_or_name == string then -- if not update mode
			modPanel.addModToSelection ( chamfer_mod ) --ui:on
	),

	/** Set chamfer values, derivated from bar width
	  *
	  */
	function _setChamferValues =
	(
		--format "\n"; print "SupportOptions_v._setChamferValues()"
		this.chamfer_values[#BASE]	= SUPPORT_OPTIONS.base_height / 2
		this.chamfer_values[#TOP]	= (SUPPORT_OPTIONS.bar_width / 2 / 10) * SUPPORT_OPTIONS.chamfer_bar -- chamfer in steps between 0-10
		this.chamfer_values[#RAFT]	= (SUPPORT_OPTIONS.raft_width / 2 / 10) * SUPPORT_OPTIONS.chamfer_bar
		--format "this.chamfer_values: %\n" this.chamfer_values
	),

	/** Add extrude modifier
	  *
	  */
	function _extrude mod_or_name amount scale: =
	(
		format "\n"; print "SupportModifiers_v._extrudeBase()"

		extrude_mod = if superClassOf mod_or_name == modifier then mod_or_name else Face_Extrude name:mod_or_name

		extrude_mod.amount	= amount

		--if scale != unsupplied then
			--extrude_mod.scale	= scale

		if classOf mod_or_name == string then -- if not update mode
			modPanel.addModToSelection ( extrude_mod ) --ui:on
	),

	/** Get obejcts with modfiers
	 */
	function _getSupportsWithModfiers =
	(
		for obj in supports where obj.modifiers.count > 0 collect obj
	),

	/** Get obejcts with modfiers
	 */
	function _getSupportsWithoutModfiers =
	(
		for obj in supports where obj.modifiers.count == 0 collect obj
	),

	/** Make sure that chamfer value is less then radius
	  */
	function _sanitizeMaxChamferValue =
	(
		--format "\n"; print "PlatformModifiers_v._sanitizeMaxChamferValue()"

		if SUPPORT_OPTIONS.bar_width / 2 == SUPPORT_OPTIONS.chamfer_bar then
			SUPPORT_OPTIONS.chamfer_bar -= 0.05
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "PlatformModifiers.onCreate()"
	)
)