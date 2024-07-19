--DEV
--filein( getFilenamePath(getSourceFileName()) + "/../../../Lib/SupportManager/SupportManager.ms" )	--"./../../../Lib/SupportManager/SupportManager.ms"


/*
*/
macroscript	_print_support_generator_beams
category:	"_3D-Print"
buttontext:	"B E A M S"
tooltip:	"Generate beams with AUTOSORT and MAX DISTANCE"
icon:	"across:4|offset:[ 0, 6 ]|width:96|height:32|tooltip:GEENERATE BEAMS between supports.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT\n\t2) POINTS\n\t3) SUPPORTS"
(
	on execute do
		undo "Generate Beams" on
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-SUPPORTS\BEAMS.mcr"
			_selection = for o in selection collect o

			if _selection.count > 0 then
				new_nodes = SUPPORT_MANAGER.generateBeams( _selection)

			select (if new_nodes.count > 0 then new_nodes else _selection)

		)
)

/*
*/
macroscript	_print_support_generator_beams_max_distance_off
category:	"_3D-Print"
buttontext:	"B E A M S"
tooltip:	"Generate beams SORTED BY SELECTION WITHOUT MAX DISTANCE"
icon:	""
(
	on execute do
		undo "Generate Beams" on
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-SUPPORTS\BEAMS.mcr"
			_selection = for o in selection collect o

			if _selection.count > 0 then
				new_nodes = SUPPORT_MANAGER.generateBeams( _selection) auto_sort:false use_max_distance:false

			select (if new_nodes.count > 0 then new_nodes else _selection)

		)
)



/**
  *
  */
macroscript	_print_generator_beams_max_distance
category:	"_3D-Print"
buttontext:	"Max Distance"
--tooltip:	""
icon:	"across:4|control:spinner|event:#entered|type:#integer|range:[ 1, 999, 5 ]|width:72|offset:[ 64, 16 ]|tooltip:Max distance in mm between supports to generate beam."
(
	--format "EventFired:	% \n" EventFired

	/** Get size
	 */
	function getSize obj = (bbox	= nodeGetBoundingBox obj ( Matrix3 1))[2].z - bbox[1].z


	--bbox	= nodeGetBoundingBox obj ( Matrix3 1) -- return array of max\min positions E.G.: bbox[1].z | bbox[2].z

	if EventFired.inSpin and EventFired.Control.value == EventFired.Control.range[1] and selection.count >= 2 then
	(
		--sizes = for obj in selection collect  getSize obj

		EventFired.Control.value = SUPPORT_OPTIONS.getMilimeterValue(distance selection[1].pos selection[2].pos )
	)
	else
		SUPPORT_MANAGER.updateModifiers (EventFired.control) (EventFired.Control.value)



)

/**
  *
  */
macroscript	_print_generator_beams_max_length
category:	"_3D-Print"
buttontext:	"Min Height"
tooltip:	"Min Height of supports where beam is created"
icon:	"across:4|control:spinner|event:#entered|type:#integer|range:[ 1, 999, 5 ]|width:64|offset:[ 64, 16 ]"
(
	format "EventFired:	% \n" EventFired

	/** Get size
	 */
	function getSize obj = (bbox	= nodeGetBoundingBox obj ( Matrix3 1))[2].z - bbox[1].z


	--bbox	= nodeGetBoundingBox obj ( Matrix3 1) -- return array of max\min positions E.G.: bbox[1].z | bbox[2].z

	if EventFired.inSpin and EventFired.Control.value == EventFired.Control.range[1] and selection.count > 0 then
	(
		sizes = for obj in selection collect  getSize obj

		EventFired.Control.value = SUPPORT_OPTIONS.getMilimeterValue(amax sizes)
	)
	else
		SUPPORT_MANAGER.updateModifiers (EventFired.control) (EventFired.Control.value)


		--print "\nSpinner test #rightclick or spinner RESETED\n\n3Ds Max BUG ?\n\nArgument inCancel DOESN'T WORK"
	--else
	--	print "Spinner test #entered"

)

/**
  *
 */
macroscript	_print_generator_beams_count
category:	"_Export"
buttontext:	"[Beams Count]"
toolTip:	"Beams Count"
icon:	"control:radiobuttons|across:4|align:#CENTER|items:#('1', '2')|offset:[ 42, 16 ]"
(
	--format "EventFired	= % \n" EventFired
	SUPPORT_MANAGER.updateModifiers (EventFired.control) (EventFired.val)
)


--/**
--  *
--  */
--macroscript	_print_generator_beams_max_length
--category:	"_3D-Print"
--buttontext:	"Same Height"
--tooltip:	"Set height of beams on each support"
--icon:	"across:4|control:checkbox|offset:[ 0, 6 ]"
--(
--	format "EventFired:	% \n" EventFired
--)

/*==============================================================================

		GENERATE BUTTON

================================================================================*/



--/**  BEAM POSITION
--  *
-- */
--macroscript	_print_generator_beams_connect_increment
--category:	"_Export"
--buttontext:	"[Connect]"
--toolTip:	"Where support is connected to beam"
--icon:	"control:radiobuttons|across:4|align:#CENTER|items:#('END', 'MIDDLE', 'THIRD', 'QUATER')|columns:4|offset:[ -72, 0 ]"
--(
--	--export_dir = execute ("@"+ "\""+EventFired.Roll.export_dir.text +"\"")
--
--	--DosCommand ("explorer \""+export_dir+"\"")
--	--format "EventFired	= % \n" EventFired
--)
