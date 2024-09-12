--filein( getFilenamePath(getSourceFileName()) + "/Lib/PinsGenerator.ms" )	--"./Lib/PinsGenerator.ms"


/*
*/
macroscript	_print_generator_holes
category:	"_3D-Print"
buttontext:	"DRAINS"
icon:	"across:3|offset:[ 0, 0 ]|height:32|width:96|tooltip:GEENERATE PINS for selected verts"
(
	on execute do
		undo "Generate DRAINS" on
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-PINS & DRAINS\DRAINS.mcr"
			SUPPORT_MANAGER.generateDrainHoles()


		)
)

/**
 */
macroscript	_print_platform_generator_drain_width
category:	"_3D-Print"
buttontext:	"WIDTH"
tooltip:	"Bar width in mm of printed model.\n\nExported scale is used"
icon:	"control:spinner|id:SPIN_drain_width|across:3|range:[ 0.5, 10, 1.0 ]|width:64|offset:[ -8, 12 ]"
(
	--format "EventFired:	% \n" EventFired
	on execute do
		SUPPORT_MANAGER.updateModifiers (EventFired.control) (EventFired.val)
)


--/**
-- */
--macroscript	_print_platform_generator_drain_display_as_box
--category:	"_3D-Print"
--buttontext:	"Dsiplay as box"
--tooltip:	"Bar width in mm of printed model.\n\nExported scale is used"
--icon:	"control:spinner|id:SPIN_drain_width|across:3|range:[ 0.5, 10, 1.0 ]|width:64|offset:[ -8, 12 ]"
--(
--	--format "EventFired:	% \n" EventFired
--	on execute do
--		SUPPORT_MANAGER.updateModifiers (EventFired.control) (EventFired.val)
--)
