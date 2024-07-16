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

	),


	/** Update modifier by value in SUPPORT_OPTIONS
	 */
	function updateModifier supports mod_name =
	(
		format "\n"; print "ModifiersManager_v.updateModifier()"

		format "mod_name: %\n" mod_name

		if ( modi = supports[1].modifiers[mod_name] ) != undefined then
			case mod_name of
			(
				#BAR_WIDTH:	modi[#Cylinder_Section].radius	= SUPPORT_OPTIONS.bar_width / 2
				#BASE_WIDTH:	modi.amount	= SUPPORT_OPTIONS.base_width
				#EXTRUDE_END:	modi.amount	= SUPPORT_OPTIONS.extrude_end

				default: format "\nWARNING -- UPDATE OF UNSUPPORTED MODIER\n\nSupportModifiers_v.updateModifier(): %\n" mod_name -- this should never happen
			)

	),

	/** Switch support type
	 */
	function switchSupportType supports to_type:#RAFT =
	(
		format "\n"; print "ModifiersManager_v.switchSupportType()"
		format "to_type: %\n" to_type
		--format "supports: %\n" supports
		--format "to_type: %\n" to_type

		mods_support	= #( "Select Base", "Base Width", "Chamfer Base", "Chamfer Bar", "Select Top" )
		mods_raft	= #( "Chamfer Bar", "Select Top" )

		mods_delete	= if to_type == #RAFT then mods_support else mods_raft
		mods_add	= if to_type == #RAFT then mods_raft	else mods_support
		format "mods_delete: %\n" mods_delete
		format "mods_add: %\n" mods_add

		mods = if obj_type == #RAFT then SupportModifiers["default"].mods_raft else SupportModifiers["default"].mods_support

		for support in supports do
		(
			for mod_name in mods_delete do
				deleteModifier support support.modifiers[mod_name]

			for mod_name in mods_add do
				addModifier support mods[mod_name] before:1
		)

	),


	private


	/**
	 */
	on create do
	(
		--format "\n"; print "ModifiersManager.onCreate()"
		SupportModifiers["default"] = SupportModifiers_v()


	)

)
