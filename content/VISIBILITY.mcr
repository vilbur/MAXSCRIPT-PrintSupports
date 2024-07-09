/*
*/
macroscript	_print_support_visibility_show
category:	"_3D-Print"
buttontext:	"• Supports"
icon:	"id:BTN_visibility_Supports|across:4|height:32|width:96|tooltip:GEENERATE SUPPORTS.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT - All supports of object\n\t2) POINTS\n\t3) SUPPORTS - Rebuild selected supports"
(
	on execute do
		undo "Show\Hide Supports" on
			SUPPORT_MANAGER.setVisibility type:#SUPPORT visibility:true
)

/*
*/
macroscript	_print_support_visibility_hide
category:	"_3D-Print"
buttontext:	"• Supports"
icon:	"id:BTN_visibility_Supports|across:4|height:32|width:96|tooltip:GEENERATE SUPPORTS.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT - All supports of object\n\t2) POINTS\n\t3) SUPPORTS - Rebuild selected supports"
(
	on execute do
		undo "Show\Hide Supports" on
			SUPPORT_MANAGER.setVisibility type:#SUPPORT visibility:false
)



--/*
--*/
--macroscript	_print_support_visibility_rafts
--category:	"_3D-Print"
--buttontext:	"• Rafts"
--icon:	"id:BTN_visibility_Rafts|across:4|height:32|width:96|tooltip:GEENERATE RAFTS.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT\n\t2) POINTS\n\t3) SUPPORTS - Turn support into raft"
--(
--	on execute do
--		undo "Show\Hide Supports" on
--		(
--			SUPPORT_MANAGER.setVisibility type:#SUPPORT visibility:false
--
--		)
--)


/*
*/
macroscript	_print_support_visibility_beams_show
category:	"_3D-Print"
buttontext:	"• Beams"
icon:	"id:BTN_visibility_beams|across:4|height:32|width:96|tooltip:GEENERATE BEAMS between supports.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT\n\t2) POINTS\n\t3) SUPPORTS"
(
	on execute do
		undo "Show\Hide Beams" on
			SUPPORT_MANAGER.setVisibility type:#BEAM visibility:true
)

/*
*/
macroscript	_print_support_visibility_beams_hide
category:	"_3D-Print"
buttontext:	"• Beams"
icon:	"id:BTN_visibility_beams|across:4|height:32|width:96|tooltip:GEENERATE BEAMS between supports.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT\n\t2) POINTS\n\t3) SUPPORTS"
(
	on execute do
		undo "Show\Hide Beams" on
			SUPPORT_MANAGER.setVisibility type:#BEAM visibility:false
)








/** GENERATE POINTS
 */
macroscript	_print_support_visibility_all
category:	"_3D-Print"
buttontext:	"✅All"
icon:	"id:BTN_visibility_all|across:4|height:32|width:96|tooltip:GENERATE POINTS From selected object.\n\nLAST OBEJCT IS USED IF NOTHING SELECTED"
(
	on execute do
		undo "Show\Hide Points" on
		--undo off
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\SUPPORT GENERATOR.mcr"

			(SupportManager_v()).toggleVisibility (#POINT) (true)


	--		if ( points_created = (getSupportManagerInstance()).generatePointHelpers( selection ) reset_helpers: keyboard.controlPressed ).count > 0 then
	--			select points_created
	--		--	--format "POINTS_CREATED	= % \n" POINTS_CREATED
		)
)

/** GENERATE POINTS
 */
macroscript	_print_support_outline
category:	"_3D-Print"
buttontext:	"Outline"
icon:	"across:4|height:32|width:96|tooltip:GENERATE POINTS From selected object.\n\nLAST OBEJCT IS USED IF NOTHING SELECTED"
(
	on execute do
		undo "Show\Hide Points" on
		--undo off
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			actionMan.executeAction 0 "470"  -- Views: Selection/Preview Highlights Toggle
			actionMan.executeAction 0 "63565"  -- Views: Selection Highlight Outlines Toggle
			actionMan.executeAction 0 "63563"  -- Views: Preview Highlight Outlines Toggle


		)
)