
global DIALOG_elevation_slider

global SET_ELEVATION

/*------------------------------------------------------------------------------
	DEV DESTROY
--------------------------------------------------------------------------------*/
	--try(
	--	cui.UnRegisterDialogBar DIALOG_elevation_slider
	--
	--	destroyDialog DIALOG_elevation_slider
	--
	--)catch()

/** Create slicer dialog
  *
  */
function createElevationSliderDialog =
(
	--format "\n"; print "test.ms.createSlicerDialog()"


	--getViewportHeight()
	--format "DIALOG_elevation_slider == undefined	= % \n" (DIALOG_elevation_slider == undefined)
	--if DIALOG_elevation_slider == undefined then


	--if DIALOG_elevation_slider == undefined then

	rollout DIALOG_elevation_slider "Parent" --define a rollout and create a dialog
	(
		/** Get height of maximized viewport to find out height of docked dialog
		 */
		function getViewportHeight =
		(
			--print "Dialog_v._getViewportHeight()"
			is_maximized	= viewport.numViews == 1

			height_of_ui	= 0 -- Add heigh
			dialog_title_height	= 30

			--if( trackbar.visible ) then
			--	height_of_ui	+= 27
			--
			--if( timeSlider.isVisible() ) then
			--	height_of_ui	+= 18

			if not( is_maximized ) then
				actionMan.executeAction 0 "50026"  -- Tools: Maximize Viewport Toggle

			viewport_area_size = getViewSize()
			--format "viewport_area_size	= % \n" viewport_area_size
			if not( is_maximized ) then
				actionMan.executeAction 0 "50026"  -- Tools: Maximize Viewport Toggle

			(viewport_area_size[2] as integer) + height_of_ui - dialog_title_height --return
		)


		local viewport_height = (getViewportHeight())

		--local layers_count = 5000

		/*------------------------------------------------------------------------------
			CONTROLS
		--------------------------------------------------------------------------------*/

		button BTN_exit_dialog "EXIT" width:36 height:22  pos:[ -2, -2 ] tooltip:"Exit and remove slicer from all objects"

		slider SLIDER_elevation "" range:[0, SLICE_PLANE_DIALOG.layers_count,0] type:#integer ticks:SLICE_PLANE_DIALOG.layers_count orient:#vertical width:32 height:(viewport_height - 40) pos:[ 10, 22 ] tooltip:"Set positioon of slice plane.\n\nRMB: Circle slice plane on obejct min, center and maximum.\n\nRMB+CTRL: SET SLICE PLANE TO BOTTOM OF OBJECT"

		button BTN_move_layer_increment "+ \ -" width:48 height:28  pos:[ -10, viewport_height - 24 ] tooltip:"LMB: Shift layer UP\n\nRMB: Shift layer DOWN\n\n   ————————————————————   \n\nTooltip:CTRL:SHIFT:ALT: 5|25|25 Layers incremnet by number of mod keys pressed 1|2|3"

		spinner SPIN_layer_current "" range:[0,5000,0] fieldWidth:32 pos:[ -8, viewport_height + 6 ] type:#integer


		/*------------------------------------------------------------------------------
			BUTTON EVENTS
		--------------------------------------------------------------------------------*/
		on BTN_exit_dialog pressed do
			try(
				--removeSlicePlaneModifier( selection )

				cui.UnRegisterDialogBar DIALOG_elevation_slider

				destroyDialog DIALOG_elevation_slider
			)catch()

		/*------------------------------------------------------------------------------
			SLIDER EVENTS
		--------------------------------------------------------------------------------*/
		on SLIDER_elevation changed val do
			SLICE_PLANE_DIALOG.updateSlicePlaneSystem (val)


		on SLIDER_elevation RIGHTCLICK do
			SLICE_PLANE_DIALOG.toggleSlicePlanePosition()

		on SLIDER_elevation BUTTONDOWN do
		(
			--for obj in selection where obj.modifiers[ #SELECT_LAYER ] != undefined do
				 --obj.modifiers[ #SELECT_LAYER ].enabled = false
		)

		on SLIDER_elevation BUTTONUP do
		(
			--for obj in selection where obj.modifiers[ #SELECT_LAYER ] != undefined do
				 --obj.modifiers[ #SELECT_LAYER ].enabled = true

			--if selection.count > 0 then
			--	if $.modifiers[ #SELECT_LAYER ] == undefined then
			--	(
			--		modPanel.addModToSelection (Poly_Select name:"SELECT SLICE")
			--
			--		subobjectLevel = 1
			--	)

		)

		/* ON BUTTON INCREMENT */
		on BTN_move_layer_increment PRESSED do
			macros.run "_3D-Print" "_print_slice_increment_plus"
			--SLICE_PLANE_DIALOG.updateSlicePlaneSystem ( getLayerNumberToMove( #PLUS ) ) incremental:true


		on BTN_move_layer_increment RIGHTCLICK do
			macros.run "_3D-Print" "_print_slice_increment_minus"
			--SLICE_PLANE_DIALOG.updateSlicePlaneSystem ( getLayerNumberToMove( #MINUS ) ) incremental:true

		/* ON SLIDER CHANGE */
		on SPIN_layer_current CHANGED val do
			SLICE_PLANE_DIALOG.updateSlicePlaneSystem (val)


		/*------------------------------------------------------------------------------
			DIALOG EVENTS
		--------------------------------------------------------------------------------*/

		/* ON OPEN */
		on DIALOG_elevation_slider OPEN do
			SLICE_PLANE_DIALOG.toggleSlicePlanePosition pos:#CENTER
			--updateSlicePlaneSystem (DIALOG_elevation_slider.SPIN_layer_current.value)

		/* ON CLOSE */
		on DIALOG_elevation_slider CLOSE do
			SLICE_PLANE_DIALOG.removeSlicePlaneModifier( selection )

		--	updateSlicePlaneSystem (DIALOG_elevation_slider.SPIN_layer_current.value)

    ) -- end rollout

	--format "GetDialogPos DIALOG_elevation_slider	= % \n" (GetDialogPos DIALOG_elevation_slider == [0,0])


	if GetDialogPos DIALOG_elevation_slider == [0,0] then
	(
		CreateDialog DIALOG_elevation_slider pos:[100,100] style:#(#cui_max_sized,#style_border, #style_sysmenu, #style_minimizebox) width:32  --if state then print "Rolled Down!" else print "Rolled Up!"

		cui.RegisterDialogBar DIALOG_elevation_slider minSize:[ 16, -1] maxSize:[ 16, -1] style:#(#cui_dock_right)

		cui.DockDialogBar DIALOG_elevation_slider #cui_dock_right
	)

)