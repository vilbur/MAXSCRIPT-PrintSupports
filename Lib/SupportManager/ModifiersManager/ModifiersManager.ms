filein( getFilenamePath(getSourceFileName()) + "/SupportModifiers/SupportModifiers.ms" )	--"./SupportModifiers/SupportModifiers.ms"

/** Modifiers manage
 */
struct ModifiersManager_v
(
	/* construct */


	/* required */
	supports,


	/* properties */
	SupportModifiers	=  Dictionary #STRING, -- KEY: VALUE:

	/* private */
	/* dependency */
	/* reference */
	/* inhered */


	/** Add modifiers
	  *
	  */
	function addModifiers supports obj_type:#SUPPORT =
	(
		format "\n-----------------------------------------\n"
		format "\n"; print "ModifiersManager_v.addModifiers()"
		format "supports: %\n" supports
		--format "SupportModifiers: %\n" SupportModifiers["default"].mod_names

		this.supports =	supports

		if not this._modifiersAdded() then
		(
			select supports

			modifiers = if obj_type == #SUPPORT then SupportModifiers["default"].mods_support else SupportModifiers["default"].mods_raft
			format "modifiers: %\n" modifiers

			for mod_name in SupportModifiers["default"].mod_names where HasDictValue modifiers mod_name do
				modPanel.addModToSelection ( modifiers[mod_name] ) --ui:on

			--modifiers["Bar Width"].CurrentBuiltInShape = 4 -- Set cylinder
			--redrawViews() -- IMPORTANT TO UPDATE AFTER SETTING SHAPE AND BEFORE EDITING ITS PROPERTIES
			--classOf supports[1]

			SupportModifiers["default"].setSweepRadius()
			--supports[1].modifiers["Bar Width"][#Cylinder_Section].radius = 1
			--modifiers["Bar Width"][#Cylinder_Section].radius = 1
		)
		else
			this._copyModifiers()
	),


	/** Update modifier by value in SUPPORT_OPTIONS
	 */
	function updateModifier supports mod_name =
	(
		format "\n"; print "ModifiersManager_v.updateModifier()"

		format "mod_name: %\n" mod_name

		if supports.count > 0 and ( modi = supports[1].modifiers[mod_name] ) != undefined then
			case mod_name of
			(
				#BAR_WIDTH:	modi[#Cylinder_Section].radius	= SUPPORT_OPTIONS.bar_width
				#BASE_WIDTH:	modi.amount	= SUPPORT_OPTIONS.base_width
				#EXTRUDE_END:	modi.amount	= SUPPORT_OPTIONS.extrude_end

				default: format "\nWARNING -- UPDATE OF UNSUPPORTED MODIER\n\nSupportModifiers_v.updateModifier(): %\n" mod_name -- this should never happen
			)

	),

	/** Convert support type
	 */
	function convertSupportType supports obj_type:#RAFT modifiers: =
	(
		format "\n"; print "ModifiersManager_v.convertSupportType()"
		format "obj_type: %\n" obj_type
		--format "supports: %\n" supports
		--format "obj_type: %\n" obj_type

		mods_support	= #( "Select Base", "Base Width", "Chamfer Base", "Chamfer Bar", "Select Top" )
		mods_raft	= #( "Chamfer Bar", "Select Ends" )

		mod_names_delete	= if obj_type == #RAFT then mods_support else mods_raft
		mod_names_add	= if obj_type == #RAFT then mods_raft	else mods_support

		modifiers_add = case of
		(
			(modifiers != undefined):	modifiers
			(obj_type == #SUPPORT):	SupportModifiers["default"].mods_support
			(obj_type == #RAFT):	SupportModifiers["default"].mods_raft
		)


		for support in supports do
		(
			for mod_name in mod_names_delete do
				deleteModifier support support.modifiers[mod_name]

			for mod_name in mod_names_add do
				addModifier support modifiers_add[mod_name] before:1
		)

	),


	private

	/** Copy modifiers
	 */
	function _copyModifiers =
	(
		format "\n"; print "SupportModifiers_v._copyModifiers()"

		/* DIRTY CODE - TIME RPOEASSURE */

		support_with_modifiers	= (this._getSupportsWithModfiers())[1]
		supports_no_modifiers	= this._getSupportsWithoutModfiers()

		modifiers_of_supports	= support_with_modifiers.modifiers

		max create mode
		for support_no_modifiers in supports_no_modifiers do
			for i = modifiers_of_supports.count to 1 by -1 do
				addModifierWithLocalData support_no_modifiers modifiers_of_supports[i] support_with_modifiers modifiers_of_supports[i] -- instance the modifier

		--for i = modifiers_of_supports.count to 1 by -1 do
		--	try(
		--			addModifier supports_no_modifiers modifiers_of_supports[i]
		--	)catch()

	),

	/** Modifiers exists
	 */
	function _modifiersAdded =
	(
		--format "\n"; print "SupportModifiers_v._modifiersAdded()"
		(this._getSupportsWithModfiers()).count > 0
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

	/**
	 */
	on create do
	(
		--format "\n"; print "ModifiersManager.onCreate()"
		SupportModifiers["default"] = SupportModifiers_v()


	)

)