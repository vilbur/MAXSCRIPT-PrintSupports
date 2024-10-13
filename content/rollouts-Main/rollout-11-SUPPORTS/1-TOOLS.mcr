
/** Toggle support foot
 */
function toggleSupportFoot state =
(
	--format "\n"; print ".toggleSupportFoot()"
	mods = #()

	_objects = selection as Array

	supports = SUPPORT_MANAGER.getObjectsByType _objects type:#SUPPORT

	for mod_name in #( #SELECT_BASE, #BASE_WIDTH, #CHAMFER_BASE ) do
		for obj in supports where obj.modifiers[mod_name] != undefined do
			appendIfUnique mods obj.modifiers[mod_name]

	with redraw off
		for _mod in mods do
			_mod.enabled = state

	redrawViews()
)

/** SUPPORT FOOT
 */
macroscript	_print_support_toggle_foot_true
category:	"_3D-Print"
buttontext:	"Toggle Foot"
tooltip:	""
icon:	"offset:[0,10]"
(
	on execute do
		format "EventFired: %\n" EventFired
		--toggleSupportFoot true
)

/** SUPPORT FOOT
 */
macroscript	_print_support_toggle_foot_false
category:	"_3D-Print"
buttontext:	"Toggle Foot"
tooltip:	""
icon:	""
(
	on execute do
		toggleSupportFoot false
)
