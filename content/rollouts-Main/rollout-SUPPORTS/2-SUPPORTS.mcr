
--DEV
--filein( getFilenamePath(getSourceFileName()) + "/../../../Lib/SupportManager/SupportManager.ms" )	--"./../../../Lib/SupportManager/SupportManager.ms"

/*
*/
macroscript	_print_support_generator
category:	"_3D-Print"
buttontext:	"SUPPORTS"
icon:	"across:2|offset:[0, 6]|height:32|width:128|tooltip:GEENERATE SUPPORTS.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT - All supports of object\n\t2) POINTS\n\t3) SUPPORTS - Rebuild selected supports\n\t4) LAST OBJECT IS USED IF NOTHING SELECTED"
(
	/* https://help.autodesk.com/view/MAXDEV/2021/ENU/?guid=GUID-5A4580C6-B5CF-4104-898B-9313D1AAECD4 */
	on isEnabled return selection.count > 0

	on execute do
		undo "Generate Supports" on
		(
			--clearListener(); print("Cleared in:\n"+getSourceFileName())
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-SUPPORTS\2-SUPPORTS.mcr"

			_selection = for o in selection collect o

			if _selection.count > 0 then
				SUPPORT_MANAGER.generateSupports( _selection[1] )

			if _selection.count > 0 then
				select _selection[1]
		)
)

/*
*/
macroscript	_print_support_generator_rafts
category:	"_3D-Print"
buttontext:	"RAFTS"
icon:	"across:2|offset:[0, 6]|height:32|width:128|tooltip:GEENERATE RAFTS.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT\n\t2) POINTS\n\t3) SUPPORTS - Turn support into raft"
(
	on execute do
		undo "Generate Rafts" on
		(
			--clearListener(); print("Cleared in:\n"+getSourceFileName())

			_selection = for o in selection collect o

			if _selection.count > 0 then
				SUPPORT_MANAGER.generateSupports( _selection[1] ) is_raft:true

			if _selection.count > 0 then
				select _selection[1]
		)
)
