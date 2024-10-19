/** OFFSET SEEP MODIFIER
 */
macroscript	_print_platform_offset_x
category:	"_3D-Print"
buttontext:	"Offset x"
tooltip:	"Bar width in mm of printed model.\n\nExported scale is used"
icon:	"control:spinner|across:4|range:[ -100, 100, 0 ]|width:78|offset:[ 0, 0 ]|ini:false"
(
	on execute do
	(
		format "\n"
		--format "EventFired:	% \n" EventFired

		_selection = selection as Array



		supports = SUPPORT_MANAGER.getObjectsByType _selection type:#SUPPORT
		rafts    = SUPPORT_MANAGER.getObjectsByType _selection type:#RAFT
		beams    = SUPPORT_MANAGER.getObjectsByType _selection type:#BEAM

		mods = #()

		for obj in supports do
			appendIfUnique mods obj.modifiers[#BAR_WIDTH]


		for _mod in mods do
		(
			objs_with_mod = #()
			mods_new = #()

			for obj in objects do
				for _modifier in obj.modifiers where _mod == _modifier and ( refhierarchy.isRefTargetInstanced _modifier ) do
					append objs_with_mod obj

			format "objs_with_mod.count: %\n" objs_with_mod.count

			objects_with_mod_unselected = for obj in objs_with_mod where findItem _selection obj == 0 collect obj
			format "objects_with_mod_unselected.count: %\n" objects_with_mod_unselected.count
			if objects_with_mod_unselected.count > 0 then
			(
				InstanceMgr.MakeModifiersUnique supports mods #GROUP

				for obj in _selection do
					appendIfUnique mods_new obj.modifiers[#SWEEP]

				format "mods_new.count: %\n" mods_new.count

				for _mod in mods_new do
					_mod.name = "BAR_WIDTH"
			)

			for obj in supports do
				obj.modifiers[#BAR_WIDTH].xOffset = EventFired.val

		)

	)
		--SUPPORT_MANAGER.updateModifiers ( EventFired )
)
