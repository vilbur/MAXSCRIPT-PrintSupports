filein( getFilenamePath(getSourceFileName()) + "/SupportModifiers/SupportModifiers.ms" )	--"./SupportModifiers/SupportModifiers.ms"

/** Modifiers manage
 */
struct ModifiersManager_v
(
	/* construct */


	/* required */
	_objects,
	--_objects_exists,


	/* properties */
	SupportModifiers	=  Dictionary #STRING, -- KEY: VALUE:

	/* private */
	/* dependency */
	/* reference */
	/* inhered */


	/** Add modifiers
	  *
	  */
	function addModifiers _objects obj_type:#SUPPORT _objects_exists:#() =
	(
		format "\n-----------------------------------------\n"
		format "\n"; print "ModifiersManager_v.addModifiers()"
		format "_objects: %\n" _objects
		format "_objects_exists: %\n" _objects_exists
		--format "SupportModifiers: %\n" SupportModifiers["default"].mod_names

		_objects_exists = for obj in _objects_exists where isValidNode obj collect obj

		this._objects =	_objects
		--this._objects_exists =	_objects_exists
		support_with_modifiers	= (this._getSupportsWithModfiers(_objects_exists))[1]

		if _objects_exists.count == 0 then
		(
			select _objects

			modifiers = if obj_type == #SUPPORT then SupportModifiers["default"].mods_support else SupportModifiers["default"].mods_raft
			format "modifiers: %\n" modifiers

			--max create mode

			for i = modifiers.count to 1 by -1 do
			--for _mod in modifiers do
				modPanel.addModToSelection ( modifiers[i] ) --ui:on

			/* SET SWEEP VALUE WHEN MODIFIER IS ADDED */
			this._setSweepRadius (_objects[1])
		)
		else
			this._copyModifiers _objects_exists[1] ((this._getSupportsWithModfiers(_objects_exists))[1].modifiers)
	),

	/** Sweep radius must be set when modifier is added to object
	 */
	function _setSweepRadius obj =
	(
		--format "\n"; print "SupportModifiers_v.setSweepRadius()"
		max modify mode

		try(
		obj.modifiers[#BAR_WIDTH][#Cylinder_Section].radius = SUPPORT_OPTIONS.getOption #BAR_WIDTH

			)catch()
	),

	/** Update modifier by value in SUPPORT_OPTIONS
	 */
	function updateModifier _objects mod_name =
	(
		--format "\n"; print "ModifiersManager_v.updateModifier()"
		--format "mod_name: %\n" mod_name
		--format "_objects: %\n" _objects

		mods = #()

		for obj in _objects where obj.modifiers[mod_name] != undefined do
			appendIfUnique mods obj.modifiers[mod_name]

		--format "mods.count: %\n" mods.count
		if mods.count > 0 then
		(
			val = SUPPORT_OPTIONS.getOption mod_name

			classof_mod = classOf mods[1]

			for _mod in mods do
				case classof_mod of
				(
					(sweep):	_mod[#Cylinder_Section].radius	= val

					(Chamfer or Face_Extrude ):	_mod.amount	= val


					--#EXTEND_END:	_mod.amount	= SUPPORT_OPTIONS.extend_end
					--#EXTEND_TOP:	_mod.amount	= SUPPORT_OPTIONS.extend_top

					default: format "\nWARNING -- UPDATE OF UNSUPPORTED MODIER\n\nSupportModifiers_v.updateModifier(): %\n" mod_name -- this should never happen
				)
		)
	),

	/** Convert obj type
	 */
	function convertSupportType _objects obj_type:#RAFT modifiers:undefined =
	(
		format "\n"; print "ModifiersManager_v.convertSupportType()"
		format "obj_type: %\n" obj_type
		format "modifiers: %\n" modifiers
		format "_objects: %\n" _objects

		--mods_support	= #( "Select Base", "Base Width", "Chamfer Base", "Chamfer Bar", "Select Top" )
		--mods_raft	= #( "Chamfer Bar", "Select Ends" )
		--
		--mod_names_delete	= if obj_type == #RAFT then mods_support else mods_raft
		--mod_names_add	= if obj_type == #RAFT then mods_raft	else mods_support

		modifiers_add = case of
		(
			(modifiers != undefined):	modifiers
			(obj_type == #SUPPORT):	SupportModifiers["default"].mods_support
			(obj_type == #RAFT):	SupportModifiers["default"].mods_raft
		)

			for _mod in modifiers_add do
				format "modifier add: %\n" _mod

		for obj in _objects do
		(
			for i = obj.modifiers.count to 1 by -1 do
			--for i = 1 to obj.modifiers.count do
				deleteModifier obj 1


			--if obj_type == #SUPPORT then
			for i = modifiers_add.count to 1 by -1 do
					addModifier obj modifiers_add[i]
			--else
			--	for _mod in modifiers_add do
			--		addModifier obj _mod
		)


		/* SET SWEEP VALUE WHEN MODIFIER IS ADDED */
		this._setSweepRadius (_objects[1])

	),


	private

	/** Copy modifiers
	 */
	function _copyModifiers support_exists modifiers =
	(
		format "\n"; print "SupportModifiers_v._copyModifiers()"

		/* DIRTY CODE - TIME RPOEASSURE */
		--support_with_modifiers	= (this._getSupportsWithModfiers(_objects_exists))[1]
		--_objects_no_modifiers	= this._getSupportsWithoutModfiers()

		--modifiers_of__objects	= support_with_modifiers.modifiers

		max create mode
		--
		--for obj in _objects do
		--	for _mod in modifiers do
		--		addModifierWithLocalData support_no_modifiers modifiers_of__objects[i] support_with_modifiers modifiers_of__objects[i] -- instance the modifier


		for obj in this._objects do
			for i = modifiers.count to 1 by -1 do
				addModifierWithLocalData obj modifiers[i] support_exists modifiers[i] -- instance the modifier

		--for i = modifiers_of__objects.count to 1 by -1 do
		--	try(
		--			addModifier _objects_no_modifiers modifiers_of__objects[i]
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
	function _getSupportsWithModfiers nodes =
	(
		for obj in nodes where isValidNode obj and obj.modifiers.count > 0 collect obj
	),

	/** Get obejcts with modfiers
	 */
	function _getSupportsWithoutModfiers =
	(
		for obj in _objects where obj.modifiers.count == 0 collect obj
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "ModifiersManager.onCreate()"
		SupportModifiers["default"] = SupportModifiers_v()


	)

)
