
--DEV
--print("DEV IMPORT in:\n"+getSourceFileName())
--filein( getFilenamePath(getSourceFileName()) + "/../../../Lib/SupportManager/SupportManager.ms" )	--"./../../../Lib/SupportManager/SupportManager.ms"

/** Generate support or raft
 */
function generateSupportsOrRafts obj_type: =
(
	format "\n"; print ".generateSupportsOrRafts()"

	format "obj_type: %\n" obj_type

	_selection = for obj in selection collect obj

	--source_objects  = SUPPORT_MANAGER.searchObjectsByType _selection type:#SOURCE
	source_objects = for obj in _selection where SUPPORT_MANAGER.isType #SOURCE obj != false collect obj

	if source_objects.count == 0 then
		source_objects = for obj in _selection where not SUPPORT_MANAGER.isManaged(obj) collect obj
	--supports_exists = for obj in _selection where findItem source_objects obj == 0 collect obj

	if source_objects.count > 0 then
		new_nodes = SUPPORT_MANAGER.generateSupports source_objects[1] obj_type:obj_type


	(
		--selected_supports_and_rafts = for obj in _selection where SUPPORT_MANAGER.isType #SUPPORT obj != false collect obj
		--format "SELECTED_SUPPORTS_AND_RAFTS: %\n" selected_supports_and_rafts

		selected_supports = for obj in _selection where SUPPORT_MANAGER.isType #SUPPORT obj != false collect obj
		selected_rafts    = for obj in _selection where SUPPORT_MANAGER.isType #RAFT    obj != false collect obj
		format "SELECTED_SUPPORTS: %\n" selected_supports
		format "SELECTED_RAFTS:    %\n" selected_rafts
		--format "raft_mode: %\n" raft_mode

		/* CONVERT SELECTED SUPPORTS TO RAFTS */
		if obj_type == #RAFT and selected_supports.count > 0 then
			SUPPORT_MANAGER.convert(selected_supports) to_type:#RAFT

		/* CONVERT SELECTED RAFTS TO SUPPORTS */
		if obj_type == #SUPPORT and selected_rafts.count > 0 then
			SUPPORT_MANAGER.convert(selected_rafts) to_type:#SUPPORT

	)

	select (if new_nodes != undefined and new_nodes.count > 0 then new_nodes else _selection)

	--format "SOURCE_OBJECTS: %\n" source_objects
	----format "COUNT: %\n" source_objects.count
	--format "\n"
	--format "SELECTED_SUPPORTS: %\n" selected_supports
	--format "COUNT: %\n" selected_supports.count
	--format "\n"
	--format "SUPPORTS_EXISTS: %\n" supports_exists
	--format "COUNT: %\n" supports_exists.count


	--if _selection.count > 0 then
	--	new_nodes = SUPPORT_MANAGER.generateSupports( _selection[1] )
	--

)

/*
*/
macroscript	_print_support_generator
category:	"_3D-Print"
buttontext:	"SUPPORTS"
icon:	"across:3|offset:[0, 6]|height:32|width:128|tooltip:GEENERATE SUPPORTS.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT - All supports of object\n\t2) POINTS\n\t3) SUPPORTS - Rebuild selected supports\n\t4) LAST OBJECT IS USED IF NOTHING SELECTED"
(
	/* https://help.autodesk.com/view/MAXDEV/2021/ENU/?guid=GUID-5A4580C6-B5CF-4104-898B-9313D1AAECD4 */
	on isEnabled return selection.count > 0

	on execute do
		undo "Generate Supports" on
		(
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-SUPPORTS\2-SUPPORTS.mcr"
			generateSupportsOrRafts obj_type:#SUPPORT
		)
)

/*
*/
macroscript	_print_support_generator_rafts
category:	"_3D-Print"
buttontext:	"RAFTS"
icon:	"across:3|offset:[0, 6]|height:32|width:128|tooltip:GEENERATE RAFTS.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT\n\t2) POINTS\n\t3) SUPPORTS - Turn support into raft"
(
	on execute do
		undo "Generate Rafts" on
		(

			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-SUPPORTS\2-SUPPORTS.mcr"
			generateSupportsOrRafts obj_type:#RAFT
		)
)


/*
*/
macroscript	_print_support_generator_live_update
category:	"_3D-Print"
buttontext:	"UPDATE"
tooltip:	"Live update supports on their transfrom"
icon:	"control:#checkbutton|across:3|offset:[0, 6]|height:32|width:128|tooltip:"
(
	on execute do
		--undo "Generate Rafts" on
		(
			SUPPORT_OPTIONS.live_update_supports = EventFired.val
		)
)
/*
*/
macroscript	_print_support_generator_update
category:	"_3D-Print"
buttontext:	"UPDATE"
tooltip:	"Update selected supports"
icon:	"control:#checkbutton"
(
	on execute do
		--undo "Generate Rafts" on
		(
			--SUPPORT_OPTIONS.live_update_supports = EventFired.val
			print "update"
		)
)