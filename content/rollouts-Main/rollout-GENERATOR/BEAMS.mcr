--DEV
--filein( getFilenamePath(getSourceFileName()) + "/../../../Lib/SupportManager/SupportManager.ms" )	--"./../../../Lib/SupportManager/SupportManager.ms"


/*

  IF SELECTED 1 support, then beam is generated to closest support
  IF SELECTED 2 supports, then beam is generated betweene thes supports if does not exists. Otherwise closest supports wil be connected



*/
macroscript	_print_support_generator_beams
category:	"_3D-Print"
buttontext:	"B E A M S"
tooltip:	"Connect closest supports"
icon:	"across:5|offset:[ 4, 6 ]|width:96|height:32|tooltip:GENERATE BEAMS for selected supports.\n\nCTRL: Connect only selected supports"
(
	on execute do
		undo "Generate Beams" on
		(
			filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-GENERATOR\BEAMS.mcr"
			SUPPORT_MANAGER.generateBeams use_only_selected_supports:keyboard.controlPressed use_max_distance:ROLLOUT_generator.CBX_max_distance.state
		)
)

/*
*/
macroscript	_print_support_generator_beams_max_distance_off
category:	"_3D-Print"
buttontext:	"B E A M S"
tooltip:	"OPEN MENU"
(
	on execute do
		undo "Generate Beams" on
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-GENERATOR\BEAMS.mcr"

			--category = "_Epoly-Vertex-Color"
			--
			--macro_name = "epoly_vertex_color_" + method as string  + (if method == #SET then "_by_last_color" else "_by_selection")
			--
			--/* ITEMS BY COLOR */
			--call_fn = "callMethodByVertexColor #"+ method as string + " "
			--

			/* DEFINE MAIN MENU */
			Menu = RcMenu_v name:"GenerateBeamsMenu"


			--if method != #SET then
			--	Menu.item item_title	( "macros.run" + "\"" + category + "\"" + "\"" + macro_name + "\""	) -- macros.run "_Epoly-Vertex-Color" "color_set_by_selection"
			--
			--Menu.item "Force Generate without AUTOSORT and MAX DISTANCE"	( "generateBeams auto_sort:false use_max_distance:false"	)

			Menu.item "Connect supports in CHAIN"	( "SUPPORT_MANAGER.generateBeams sort_mode:#JOIN_SUPPORTS_CHAIN"	)

			--Menu.item "To Closest Selected Supports"	( "generateBeamsToClosestSupports()"	)
			--Menu.item "&GREEN"	( call_fn + "green"	)
			--Menu.item "&BLUE"	( call_fn + " " + COLOR_NAMES[#BLUE] as string	)
			--Menu.item "&ORANGE"	( call_fn + "orange"	)
			--Menu.item "&PINK"	( call_fn + " " + COLOR_NAMES[#PINK] as string	)
			--Menu.item "&WHITE"	( call_fn + "white"	)


			popUpMenu (Menu.create())


			--_selection = for o in selection collect o
			--
			--if _selection.count > 0 then
			--	new_nodes = SUPPORT_MANAGER.generateBeams( _selection) auto_sort:false use_max_distance:false
			--
			--select (if new_nodes.count > 0 then new_nodes else _selection)

		)
)

/** USE MAX DISTANCE CHECKBOX
  *
  */
macroscript	_print_generator_beams_max_distance_toggle
category:	"_3D-Print"
buttontext:	"Max Distance"
--tooltip:	"USE MAX DISTANCE between supports where beams will be generated"
icon:	"across:5|control:checkbox|offset:[ 18, 16 ]|tooltip:USE MAX DISTANCE between supports where beams will be generated"
(
	on execute do
	(

		format "EventFired:	% \n" EventFired

		ROLLOUT_generator.SPIN_max_distance.enabled = EventFired.val

		--/** Get size
		-- */
		--function getSize obj = (bbox	= nodeGetBoundingBox obj ( Matrix3 1))[2].z - bbox[1].z
		--
		--if EventFired.inSpin and EventFired.Control.value == EventFired.Control.range[1] and selection.count >= 2 then
		--(
		--	--sizes = for obj in selection collect  getSize obj
		--
		--	EventFired.Control.value = SUPPORT_OPTIONS.getMilimeterValue(distance selection[1].pos selection[2].pos )
		--)
		--else
		--	SUPPORT_MANAGER.updateModifiers (EventFired.control) (EventFired.Control.value)
	)
)

/**
  *
  */
macroscript	_print_generator_beams_max_distance
category:	"_3D-Print"
buttontext:	"[Max Distance Value]"
--tooltip:	"Max distance between supports"
icon:	"across:5|control:spinner|id:#SPIN_max_distance|event:#entered|type:#integer|range:[ 1, 999, 5 ]|width:32|offset:[ 0, 16 ]|tooltip:Max distance in mm between supports."
(
	on execute do
	(

		format "EventFired:	% \n" EventFired
		format "EventFired.Control.value: %\n" EventFired.Control.value

		EventFired.Control.tooltip = EventFired.Control.value as string + "mm is max distance between supports"

		/** Get size
		 */
		function getSize obj = (bbox	= nodeGetBoundingBox obj ( Matrix3 1))[2].z - bbox[1].z

		if EventFired.inSpin and EventFired.Control.value == EventFired.Control.range[1] and selection.count >= 2 then
		(
			--sizes = for obj in selection collect  getSize obj

			EventFired.Control.value = SUPPORT_OPTIONS.getMilimeterValue(distance selection[1].pos selection[2].pos )
		)
		else
			SUPPORT_MANAGER.updateModifiers (EventFired.control) (EventFired.Control.value)
	)
)

/**
  *
  */
macroscript	_print_generator_beams_max_length
category:	"_3D-Print"
buttontext:	"Min Height"
tooltip:	"Min Height of supports where beam is created"
icon:	"across:5|control:spinner|event:#entered|type:#integer|range:[ 1, 999, 5 ]|width:64|offset:[ 36, 16 ]"
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
icon:	"control:radiobuttons|across:5|align:#CENTER|items:#('1', '2')|offset:[ 32, 16 ]"
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
--icon:	"across:5|control:checkbox|offset:[ 0, 6 ]"
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
--icon:	"control:radiobuttons|across:5|align:#CENTER|items:#('END', 'MIDDLE', 'THIRD', 'QUATER')|columns:4|offset:[ -72, 0 ]"
--(
--	--export_dir = execute ("@"+ "\""+EventFired.Roll.export_dir.text +"\"")
--
--	--DosCommand ("explorer \""+export_dir+"\"")
--	--format "EventFired	= % \n" EventFired
--)
