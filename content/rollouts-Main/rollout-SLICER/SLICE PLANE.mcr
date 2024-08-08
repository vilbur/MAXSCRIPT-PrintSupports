global ROLLOUT_slicer
global DIALOG_elevation_slider


filein( getFilenamePath(getSourceFileName()) + "/Lib/SlicePlaneDialog/getPlaneZpozition.ms" )	--"./Lib/SlicePlaneDialog/getPlaneZpozition.ms"

filein( getFilenamePath(getSourceFileName()) + "/Lib/SlicePlaneDialog/setSlicePlaneModifier.ms" )	--"./Lib/SlicePlaneDialog/setSlicePlaneModifier.ms"

filein( getFilenamePath(getSourceFileName()) + "/Lib/SlicePlaneDialog/setSelectPlaneModifier.ms" )	-- "./Lib/SlicePlaneDialog/setSelectPlaneModifier.ms"

filein( getFilenamePath(getSourceFileName()) + "/Lib/SlicePlaneDialog/updateSlicePlaneSystem.ms" )	-- "./Lib/SlicePlaneDialog/updateSlicePlaneSystem.ms"

filein( getFilenamePath(getSourceFileName()) + "/Lib/SlicePlaneDialog/createElevationSliderDialog.ms" )	-- "./Lib/SlicePlaneDialog/createElevationSliderDialog.ms"

filein( getFilenamePath(getSourceFileName()) + "/Lib/IslandManagerDialog/IslandManagerDialog.ms" )	--"./Lib/IslandManagerDialog/IslandManagerDialog.ms"

/**
  *
  */
macroscript	print_create_slicerdialog
category:	"_3D-Print"
buttontext:	"SLICE OBJECT"
tooltip:	"Slice selected object."
icon:	"across:3|height:32|tooltip:\n\n----------------------\n\nFIX IF NOT WORK PROPERLY: RESET OBJECT XFORM\n\nIF Z POZITION OF SLICE PLANE DOES NOT WORK PROPERLY"
(
	on execute do
		(
			--clearListener(); print("Cleared in:\n"+getSourceFileName())
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-SLICER\SLICE PLANE.mcr"
			--format "EventFired	= % \n" EventFired

			/* DEVELOP: KILL SLICE DIALOG */
			try(
				cui.UnRegisterDialogBar DIALOG_elevation_slider

				destroyDialog DIALOG_elevation_slider

			)catch()

			/** Add slice mod
			 */
			function addSliceMod obj slice_mod =
			(
				--format "\n"; print ".addSliceMod()"
				addModifier obj slice_mod

				mod_TM =	(getModContextTM obj slice_mod)	* (  obj.transform )
				--format "mod_TM	= % \n" mod_TM
				setModContextTM obj slice_mod mod_TM
			)

			/* CHOOSE SLICE TOP OR BOTTOM, UNUSED CURENTLY
				slice_modes = Dictionary #( #SLICE_PLANE_TOP, ROLLOUT_slicer.CBX_slice_top.state ) #( #SLICE_PLANE_BOTTOM, ROLLOUT_slicer.CBX_slice_bottom.state )

				if not (slice_modes[ #SLICE_PLANE_TOP ]and slice_modes[ #SLICE_PLANE_BOTTOM ])  then
					slice_modes[ #SLICE_PLANE_TOP ] = true
			*/


			slice_modes = Dictionary #( #SLICE_PLANE_TOP, true ) #( #SLICE_PLANE_BOTTOM, false )

			for slice_mode_data in slice_modes where slice_mode_data.value do
			(
				format "slice_mode_data	= % \n" slice_mode_data
				mod_name = slice_mode_data.key

				/* GET ALL INSANCES OF MODIFIER IN SCENE */
				modifiers_in_scene = for mod_in_scene in getClassInstances ( SliceModifier ) where mod_in_scene.name as name == mod_name collect mod_in_scene

				/* GET NEW INSANCE MODIFIER */
				if ( slice_modifier = modifiers_in_scene[1] ) == undefined then
					slice_modifier = SliceModifier name:( mod_name as string ) Faces___Polygons_Toggle:1

				/* GET OBJECTS WITH MODIFIER INS */
				objects_with_modifier = refs.dependentNodes slice_modifier

				/* ADD MODIIFER WHERE IS NOT */
				for obj in selection where superClassOf obj == GeometryClass and findItem objects_with_modifier obj == 0 do
				(
					addModifier obj  (Poly_Select name:"SLICE_SELECT_OBJ" )

					addSliceMod (obj)	(slice_modifier)
				)
			)


			/* CREATE SLICE DIALOG */
			createElevationSliderDialog()

			updateSlicePlaneSystem (DIALOG_elevation_slider.SPIN_layer_current.value)

		)
)



/**
  *
  */
macroscript	print_remove_slice_modifiers
category:	"_3D-Print"
buttontext:	"Slice Object"
tooltip:	"EXIT SLICE MODE"
icon:	"across:3|height:32"
(
	on execute do
		(
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-SLICER\SLICE PLANE.mcr"
			--try(
			--	cui.UnRegisterDialogBar DIALOG_elevation_slider
			--
			--	destroyDialog DIALOG_elevation_slider
			--)catch()

			_selection = if selection.count == 0 then selection else geometry



			for mod_name in #( #SLICE_PLANE_TOP, #SLICE_PLANE_BOTTOM, #SELECT_BY_PRINT_LAYER ) do
			(

				/*  */
				 if selection.count == 0 then
				 (
					modifiers_in_scene = for mod_in_scene in getClassInstances ( SliceModifier ) where mod_in_scene.name as name == mod_name collect mod_in_scene

					for mod_in_scene in modifiers_in_scene do
						for obj in refs.dependentNodes mod_in_scene do
							deleteModifier obj mod_in_scene

				 )
				 else
					for obj in selection where (_mod = obj.modifiers[mod_name]) != undefined do
						deleteModifier obj _mod


			)
		)
)

/** Get layer number to move
 */
function getLayerNumberToMove direction =
(
	--format "\n"; print ".getLayerNumberToMove()"
	ctrl	= keyboard.controlPressed
	shift 	= keyboard.shiftPressed
	alt 	= keyboard.altPressed


	mod_keys_count = (for mod_value in #( ctrl, shift, alt ) where mod_value collect true).count
	format "mod_keys_count: %\n" mod_keys_count
	increment_val = case mod_keys_count of
	(
		(3):	100
		(2):	25
		(1):	10
		default: 1
	)

	if direction == #MINUS then
		increment_val *= -1

	increment_val --return
)

/**
  *
  */
macroscript	_print_slice_increment_plus
category:	"_3D-Print"
buttontext:	"+ \ -"
tooltip:	"Shift layer UP"
icon:	"across:3|height:32|Tooltip:CTRL:SHIFT:ALT: 10\25\25 Layers incremnet by number of mod keys pressed 1\2\3"
(


	on execute do
		updateSlicePlaneSystem ( getLayerNumberToMove( #PLUS ) ) incremental:true
)
/**
  *
  */
macroscript	_print_slice_increment_minus
category:	"_3D-Print"
buttontext:	"+ \ -"
tooltip:	"RMB: Shift layer DOWN"
icon:	"across:3|height:32"
(

	on execute do
		updateSlicePlaneSystem ( getLayerNumberToMove( #MINUS ) ) incremental:true
)


/*==============================================================================

		FIND ISLANDS

================================================================================*/

/**
 *
 */
macroscript	maxtoprint_find_islands_dialog
category:	"maxtoprint"
buttontext:	"FIND ISLANDS"
toolTip:	"Open Find Island Slider"
icon:	"across:3"
(

	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"
		gc light:true
		gc()

			format "Macro:EventFired:	% \n" EventFired

		undo off
		(
			obj	= selection[1]

			if ( ISLANDS_DATA = getUserPropVal obj "ISLANDS_DATA"  ) == undefined then
			(
				macros.run "maxtoprint" "maxtoprint_find_islands"

				ISLANDS_DATA = getUserPropVal obj "ISLANDS_DATA"
			)


			createIslandManagerDialog()

		)

	)
)

/**
 *
 */
macroscript	maxtoprint_find_islands
category:	"maxtoprint"
buttontext:	"FIND ISLANDS"
toolTip:	"Refresh islands"
icon:	"across:3"
(

	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"
		gc light:true
		gc()

		undo off
		(
			obj	= selection[1]

			VertSelector 	= VertSelector_v(obj )

			VertIslandFinder = VertSelector.VertexLayers.VertIslandFinder
			--if subobject == #FACE then polyop.getFaceSelection obj else polyop.getVertSelection obj -- return

			islands_data = VertSelector.findIslandsPerLayer()

			format "islands_data COUNT: %\n" VertIslandFinder.islands_data.count

			new_islands = for island_data in islands_data collect island_data[#NEW_ISLAND]

			lowest_verts = VertSelector.getLowestVerts ( new_islands )

			--format "lowest_verts: %\n" lowest_verts
			--
			VertSelector.setSelection ( lowest_verts )

			setUserPropVal obj "ISLANDS_DATA" VertIslandFinder.islands_data
		)

		--elements = VertSelector.VertIslandFinder.getElementsOfFaces ( polyop.getFaceSelection obj )
		----getElementsOfFaces ( getFaceSelection obj.mesh )
		--
		--for element in elements do
		--	format "element: %\n" element
		--
		--format "elements.count: %\n" elements.count

	)
)



/*------------------------------------------------------------------------------

	CHECKBOXES

--------------------------------------------------------------------------------*/
--/**
--  *
--  */
--macroscript	_print_slice_select_volume
--category:	"_3D-Print"
--buttontext:	"Select"
--tooltip:	"Select verts in sliced layer"
--icon:	"control:checkbox|id:#CBX_slice_select_plane|autorun:false|across:4|height:32|offset:[ 26, 0 ]"
--(
--	on execute do
--		(
--			format "EventFired	= % \n" EventFired
--			if EventFired.val then
--				updateSlicePlaneSystem(undefined)
--
--			else
--				for obj in objects where ( _modifier = obj.modifiers[#SELECT_BY_PRINT_LAYER] ) != undefined do
--					deleteModifier obj _modifier
--		)
--)
--
--/**
--  *
--  */
--macroscript	_print_slice_plane_top
--category:	"_3D-Print"
--buttontext:	"Slice Top"
--tooltip:	"Slice plane top"
--icon:	"control:checkbox|autorun:false|across:4|height:32|offset:[ 10, 0 ]"
--(
--	on execute do
--	(
--		format "EventFired	= % \n" EventFired
--
--		if EventFired.val then
--			updateSlicePlaneSystem(undefined)
--
--		else
--			for obj in objects where ( _modifier = obj.modifiers[#SLICE_PLANE_TOP] ) != undefined do
--				deleteModifier obj _modifier
--	)
--)
--
--
--/**
--  *
--  */
--macroscript	_print_slice_plane_bottom
--category:	"_3D-Print"
--buttontext:	"Slice Bottom"
--tooltip:	"Slice plane bottom"
--icon:	"control:checkbox|autorun:false|across:4|height:32|offset:[ 4, 0 ]"
--(
--	on execute do
--	(
--		format "EventFired	= % \n" EventFired
--
--		if EventFired.val then
--		updateSlicePlaneSystem(undefined)
--
--		else
--			for obj in objects where ( _modifier = obj.modifiers[#SLICE_PLANE_BOTTOM] ) != undefined do
--				deleteModifier obj _modifier
--	)
--)
--
--/**
--  *
--  */
--macroscript	_print_slice_plane_cap
--category:	"_3D-Print"
--buttontext:	"Cap Slice"
--tooltip:	"Cap Slice plane"
--icon:	"control:checkbox|autorun:false|across:4|height:32|offset:[ 12, 0 ]"
--(
--	on execute do
--		updateSlicePlaneSystem(undefined)
--)