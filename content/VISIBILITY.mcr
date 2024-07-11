
/** Select hide unhide supports
 */
function selectHideUnhideSupports type: state: =
(
	format "\n"; print ".selectHideUnhideSupports()"

	ctrl = keyboard.controlPressed;
	alt = keyboard.altPressed;
	shift = keyboard.shiftPressed

	_objects = if selection.count > 0 then selection as Array else objects as Array

	nodes = SUPPORT_MANAGER.getObjectsByType _objects type:type hierarchy:shift
	--format "NODES: %\n" nodes
	--select nodes


	case of
	(
		--( ctrl and shift ): selectmore nodes
		--( alt  and shift):
		--( ctrl and alt ):
		--( shift ): selectmore nodes
		( ctrl ): for obj in nodes do obj.isHidden = not state
		--( alt ):

		default: ( clearSelection(); select nodes )
	)

)


/*------------------------------------------------------------------------------
	SOURCE OBJECT
--------------------------------------------------------------------------------*/

/*
*/
macroscript	_print_support_visibility_source_show
category:	"_3D-Print"
buttontext:	"SOURCE"
icon:	"id:BTN_visibility_source|across:5|height:32|width:96|tooltip:GEENERATE SUPPORTS.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT - All supports of object\n\t2) POINTS\n\t3) SUPPORTS - Rebuild selected supports"
(
	on execute do
		undo "Show\Hide Source" on
			selectHideUnhideSupports type:#SOURCE state:false
)

/*
*/
macroscript	_print_support_visibility_source_hide
category:	"_3D-Print"
buttontext:	"SOURCE"
icon:	"id:BTN_visibility_source|across:5|height:32|width:96|tooltip:GEENERATE SUPPORTS.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT - All supports of object\n\t2) POINTS\n\t3) SUPPORTS - Rebuild selected supports"
(
	on execute do
		undo "Show\Hide Source" on
			selectHideUnhideSupports type:#SOURCE state:true
)

/*------------------------------------------------------------------------------
	SUPPORTS
--------------------------------------------------------------------------------*/

/*
*/
macroscript	_print_support_visibility_show
category:	"_3D-Print"
buttontext:	"SUPPORTS"
icon:	"id:BTN_visibility_Supports|across:5|height:32|width:96|tooltip:GEENERATE SUPPORTS.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT - All supports of object\n\t2) POINTS\n\t3) SUPPORTS - Rebuild selected supports"
(
	on execute do
		undo "Show\Hide Supports" on
			selectHideUnhideSupports type:#SUPPORT state:false
)

/*
*/
macroscript	_print_support_visibility_hide
category:	"_3D-Print"
buttontext:	"SUPPORTS"
icon:	"id:BTN_visibility_Supports"
(
	on execute do
		undo "Show\Hide Supports" on
			selectHideUnhideSupports type:#SUPPORT state:true
)


/*------------------------------------------------------------------------------
	RAFTS
--------------------------------------------------------------------------------*/
/*
*/
macroscript	_print_support_visibility_rafts
category:	"_3D-Print"
buttontext:	"RAFTS"
icon:	"id:BTN_visibility_Rafts|across:5|height:32|width:96|tooltip:GEENERATE RAFTS.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT\n\t2) POINTS\n\t3) SUPPORTS - Turn support into raft"
(
	on execute do
		undo "Show\Hide Supports" on
		(
			selectHideUnhideSupports type:#SUPPORT state:false

		)
)

/*------------------------------------------------------------------------------
	BEAMS
--------------------------------------------------------------------------------*/
/*
*/
macroscript	_print_support_visibility_beams_show
category:	"_3D-Print"
buttontext:	"BEAMS"
icon:	"id:BTN_visibility_beams|across:5|height:32|width:96|tooltip:GEENERATE BEAMS between supports.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT\n\t2) POINTS\n\t3) SUPPORTS"
(
	on execute do
		undo "Show\Hide Beams" on
			selectHideUnhideSupports type:#BEAM state:false
)

/*
*/
macroscript	_print_support_visibility_beams_hide
category:	"_3D-Print"
buttontext:	"BEAMS"
icon:	"id:BTN_visibility_beams|across:5|height:32|width:96|tooltip:GEENERATE BEAMS between supports.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT\n\t2) POINTS\n\t3) SUPPORTS"
(
	on execute do
		undo "Show\Hide Beams" on
			selectHideUnhideSupports type:#BEAM state:true
)



/*------------------------------------------------------------------------------
	ALL
--------------------------------------------------------------------------------*/

/**
 */
macroscript	_print_support_visibility_all
category:	"_3D-Print"
buttontext:	"✅All"
icon:	"id:BTN_visibility_all|across:5|height:32|width:96|tooltip:GENERATE POINTS From selected object.\n\nLAST OBEJCT IS USED IF NOTHING SELECTED"
(
	on execute do
		undo "Show\Hide Points" on
		--undo off
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\SUPPORT GENERATOR.mcr"

			selectHideUnhideSupports type:#ALL state:true


	--		if ( points_created = (getSupportManagerInstance()).generatePointHelpers( selection ) reset_helpers: keyboard.controlPressed ).count > 0 then
	--			select points_created
	--		--	--format "POINTS_CREATED	= % \n" POINTS_CREATED
		)
)

