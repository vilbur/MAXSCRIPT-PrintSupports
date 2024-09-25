--filein( getFilenamePath(getSourceFileName()) + "/Lib/PinsGenerator.ms" )	--"./Lib/PinsGenerator.ms"


/*
*/
macroscript	_print_generator_holes
category:	"_3D-Print"
buttontext:	"DRAINS"
icon:	"across:4|offset:[ 0, 0 ]|height:32|width:96|tooltip:GEENERATE PINS for selected verts"
(
	on execute do
		undo "Generate DRAINS" on
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\Lib\SupportManager\SupportManager.ms"
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-PINS_&_DRAINS\DRAINS.mcr"
			SUPPORT_MANAGER.generateDrainHoles()


		)
)

/**
 */
macroscript	_print_platform_generator_drain_width
category:	"_3D-Print"
buttontext:	"WIDTH"
tooltip:	"Bar width in mm of printed model.\n\nExported scale is used"
icon:	"control:spinner|id:SPIN_drain_width|across:4|range:[ 0.5, 10, 1.0 ]|width:64|offset:[ 12, 12 ]"
(
	--format "EventFired:	% \n" EventFired
	on execute do
	(


		SUPPORT_MANAGER.updateModifiers ( EventFired )
	)
)

/**
 */
macroscript	_print_platform_generator_drain_bottom
category:	"_3D-Print"
buttontext:	"↓"
tooltip:	"How low is drain dummy is placed bellow vertex"
icon:	"control:spinner|id:SPIN_drain_bottom|range:[ 1, 10, 2 ]|width:64|offset:[ 0, 12 ]"
(
	--format "EventFired:	% \n" EventFired
	on execute do
		SUPPORT_MANAGER.updateModifiers ( EventFired )
)

/**
 */
macroscript	_print_platform_generator_drain_top
category:	"_3D-Print"
buttontext:	"↑"
tooltip:	"How high is drain dummy is placed above vertex"
icon:	"control:spinner|id:SPIN_drain_top|range:[ 0.1, 10, 0.1 ]|width:64|offset:[ 0, 12 ]"
(
	--format "EventFired:	% \n" EventFired
	on execute do
		SUPPORT_MANAGER.updateModifiers ( EventFired )
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
--		SUPPORT_MANAGER.updateModifiers ( EventFired )
--)
