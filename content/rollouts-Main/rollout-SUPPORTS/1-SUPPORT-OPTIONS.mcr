

-- DEV IMPORT
--filein( getFilenamePath(getSourceFileName()) + "/Lib/SupportManager/getSupportManagerInstance.ms" )	--"./Lib/SupportManager/getSupportManagerInstance.ms"


/*==============================================================================

		COTNROLS ROW 1

================================================================================*/

/**
 */
macroscript	_print_platform_generator_base_width
category:	"_3D-Print"
buttontext:	"Base width"
tooltip:	"Width of base part"
icon:	"across:2|control:spinner|range:[ 0.1, 999, 4 ]|width:64|offset:[ -6, 6]"
(
	format "EventFired:	% \n" EventFired
	SUPPORT_MANAGER.updateModifiers (EventFired.control) (EventFired.val)
)


/**
 */
macroscript	_print_platform_generator_bar_chamfer
category:	"_3D-Print"
buttontext:	"Chamfer Bar"
tooltip:	"Chamfer of support`s top.\n\n\nCHAMFER MIN: 0\nCHAMFER MAX: 10\n\nValue is portion of bar radius.\n\nE.EG: 5 == 50% use of radius"
icon:	"across:2|control:spinner|type:#integer|range:[ 0, 10, 5 ]|width:64|offset:[ 0, 6]"
(
	format "EventFired:	% \n" EventFired
	SUPPORT_MANAGER.updateModifiers (EventFired.control) (EventFired.val)
)


/*==============================================================================

		COTNROLS ROW 2

================================================================================*/

/**
 */
macroscript	_print_platform_generator_base_height
category:	"_3D-Print"
buttontext:	"Base Height"
tooltip:	"Height of support base"
icon:	"across:2|control:spinner|range:[ 0.1, 999, 1 ]|width:64|offset:[ -6, 6]"
(
	format "EventFired:	% \n" EventFired
	SUPPORT_MANAGER.updateModifiers (EventFired.control) (EventFired.val)
)

/** EXTRUDE TOP
 */
macroscript	_print_platform_generator_extrude_top
category:	"_3D-Print"
buttontext:	"Extrude Top"
tooltip:	"Extrude Top part in mm of printed model.\n\nExported scale is used"
icon:	"control:spinner|across:2|width:64|range:[ 0, 99, 0.5 ]|offset:[ -8, 6]"
(
	format "EventFired:	% \n" EventFired
	SUPPORT_MANAGER.updateModifiers (EventFired.control) (EventFired.val)
)

/*==============================================================================

		COTNROLS ROW 3

================================================================================*/



/** BAR WIDTH
 */
macroscript	_print_platform_generator_bar_width
category:	"_3D-Print"
buttontext:	"Bar width"
tooltip:	"Bar width in mm of printed model.\n\nExported scale is used"
icon:	"across:2|control:spinner|range:[ 0.8, 99, 1.0 ]|width:64|offset:[ -8, 6]"
(
	format "EventFired:	% \n" EventFired
	SUPPORT_MANAGER.updateModifiers (EventFired.control) (EventFired.val)
)

/** BAR WIDTH
 */
macroscript	_print_platform_generator_raft_width
category:	"_3D-Print"
buttontext:	"Raft width"
tooltip:	"Raft width in mm of printed model.\n\nExported scale is used"
icon:	"across:2|control:spinner|range:[ 0.3, 99, 0.5 ]|width:64|offset:[ -8, 6]"
(
	format "EventFired:	% \n" EventFired
	SUPPORT_MANAGER.updateModifiers (EventFired.control) (EventFired.val)
)

