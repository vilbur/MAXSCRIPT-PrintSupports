--DEV
--filein( getFilenamePath(getSourceFileName()) + "/../../../Lib/SupportManager/SupportManager.ms" )	--"./../../../Lib/SupportManager/SupportManager.ms"





/**
  *
  */
macroscript	_print_generator_beams_max_distance
category:	"_3D-Print"
buttontext:	"Max Distance"
--tooltip:	""
icon:	"across:3|control:spinner|type:#integer|range:[ 1, 999, 5 ]|width:64|offset:[ 36, 6 ]|tooltip:Max distance in mm between supports to generate beam."
(
	--format "EventFired:	% \n" EventFired
	SUPPORT_MANAGER.updateModifiers (EventFired.control) (EventFired.val)
)

/**
  *
  */
macroscript	_print_generator_beams_max_length
category:	"_3D-Print"
buttontext:	"Min Height"
tooltip:	"Min Height of supports where beam is created"
icon:	"across:3|control:spinner|type:#integer|range:[ 1, 999, 5 ]|width:64|offset:[ 0, 6 ]"
(
	--format "EventFired:	% \n" EventFired
	SUPPORT_MANAGER.updateModifiers (EventFired.control) (EventFired.val)
)

/**
  *
 */
macroscript	_print_generator_beams_count
category:	"_Export"
buttontext:	"[Beams Count]"
toolTip:	"Beams Count"
icon:	"control:radiobuttons|across:3|align:#CENTER|items:#('1', '2')|offset:[ 0, 0 ]"
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
--icon:	"across:3|control:checkbox|offset:[ 0, 6 ]"
--(
--	format "EventFired:	% \n" EventFired
--)

/*==============================================================================

		GENERATE BUTTON

================================================================================*/
/*
*/
macroscript	_print_support_generator_beams
category:	"_3D-Print"
buttontext:	"BEAMS"
icon:	"across:1|offset:[ 0, 6 ]|width:242|height:32|tooltip:GEENERATE BEAMS between supports.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT\n\t2) POINTS\n\t3) SUPPORTS"
(
	on execute do
		undo "Generate Beams" on
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-SUPPORTS\BEAMS.mcr"
			_selection = for o in selection collect o

			if _selection.count > 0 then
				SUPPORT_MANAGER.generateBeams( _selection)

			if _selection.count > 0 then
				select _selection[1]
		)
)




--/**  BEAM POSITION
--  *
-- */
--macroscript	_print_generator_beams_connect_increment
--category:	"_Export"
--buttontext:	"[Connect]"
--toolTip:	"Where support is connected to beam"
--icon:	"control:radiobuttons|across:1|align:#CENTER|items:#('END', 'MIDDLE', 'THIRD', 'QUATER')|columns:4|offset:[ -72, 0 ]"
--(
--	--export_dir = execute ("@"+ "\""+EventFired.Roll.export_dir.text +"\"")
--
--	--DosCommand ("explorer \""+export_dir+"\"")
--	--format "EventFired	= % \n" EventFired
--)
