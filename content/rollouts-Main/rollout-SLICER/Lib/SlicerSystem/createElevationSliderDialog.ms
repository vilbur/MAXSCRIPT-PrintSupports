
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
	format "\n"; print "createElevationSliderDialog()"


	--getViewportHeight()
	--format "DIALOG_elevation_slider == undefined	= % \n" (DIALOG_elevation_slider == undefined)
	--if DIALOG_elevation_slider == undefined then


	/*------------------------------------------------------------------------------
		DIALOG
	--------------------------------------------------------------------------------*/

	slider_ticks  = SLICER_SYSTEM.layers_count
	--slider_height = SLICER_SYSTEM.viewport_height - ( mod SLICER_SYSTEM.viewport_height 10 ) - 70 -- round viewport height to ceil 10 E.G.: 1789 >>> 1780
	slider_height = SLICER_SYSTEM.viewport_height - 85 -- round viewport height to ceil 10 E.G.: 1789 >>> 1780

	--if slider_height > slider_ticks then
		--slider_ticks /= 10

	--slider_ticks = (floor ( slider_ticks / 10 ) ) * 10
	slider_ticks = (ceil ( slider_ticks / 100 ) ) * 10
	--slider_ticks = 100

	format "SLICER_SYSTEM.layers_count: %\n" SLICER_SYSTEM.layers_count
	format "SLICER_SYSTEM.viewport_height: %\n" SLICER_SYSTEM.viewport_height
	format "slider_height: %\n" slider_height
	format "slider_ticks: %\n" slider_ticks

    Dialog 	    = Dialog_v "" id:#DIALOG_elevation_slider ini:(getSourceFileName()) --min_size:[48, -1] max_size:[48, -1]

	_Controls   = Dialog.Controls() --group:"Main Controls"

	/*------------------------------------------------------------------------------
		CONTROLS
	--------------------------------------------------------------------------------*/

	btn_exit = _Controls.control #BUTTON "EXIT" width:42 height:24 offset:	[ 0, -4 ] tooltip:"Exit and remove slicer from all objects"


    /*------ SLIDER ------*/
    _slider = _Controls.control #SLIDER "" \
                    id:	#SLIDER_elevation	\
                    range:	[0, SLICER_SYSTEM.layers_count, 0]	\
                    type:	#INTEGER	\
                    params:	#(#orient, #vertical  )	\
                    ticks:	100	\
                    width:	44	\
                    height:	slider_height	\
                    across:	1	\
                    offset:	[ -8, -4 ]	\
                    ini:	false
                    --pos:	pos_slider

	btn_plus_minus = _Controls.control #BUTTON "+ \ -"across:1  width:42 height:42 offset:[ -4, -8 ] tooltip:"LMB: Shift layer UP\n\nRMB: Shift layer DOWN\n\n   ————————————————————   \n\nTooltip:CTRL:SHIFT:ALT: 5|25|25 Layers incremnet by number of mod keys pressed 1|2|3"


	_spinner = _Controls.control #SPINNER "" id:#SPIN_layer_current across:1 range:[ 0, SLICER_SYSTEM.layers_count, 0] width:42 type:#integer offset:[ -4, 0 ]

	_dropdown = _Controls.control #DROPDOWNLIST "" id:#DD_slider_snaps  width:64  items:#( "layers", "verts", "islands" ) offset:[ -16, 0 ] ini:false --params:#( #UNSELECT, true ) across:1 offset:[ 4, 2 ] --align:#center  --width:96



	/*------------------------------------------------------------------------------
		EVENTS
	--------------------------------------------------------------------------------*/
	btn_exit.Event #PRESSED "SLICER_SYSTEM.desroySliderDialog()"

	_slider.Event #CHANGED     "SLICER_SYSTEM.updateSlicePlaneSystem"
	--_slider.Event #RIGHTCLICK  "toggleSelectIslandMode()"

	_spinner.Event #CHANGED "SLICER_SYSTEM.updateSlicePlaneSystem(val)"

	btn_plus_minus.Event #PRESSED    "SLICER_SYSTEM.updateSlicePlaneSystem( 1 ) incremental:true"
	btn_plus_minus.Event #RIGHTCLICK "SLICER_SYSTEM.updateSlicePlaneSystem( -1 )incremental:true"

	--_dropdown.Event #CHANGED "SLICER_SYSTEM.changeSliderSnamps"

	/*------------------------------------------------------------------------------
		CREATE DIALOG
	--------------------------------------------------------------------------------*/
	Dialog.create width:(42) height:#VIEWPORT --lockWidth:false --style:#()   --bgcolor:( color 60 130 140 )
	--Dialog.create width:(42) height:#VIEWPORT lockWidth:false --style:#()   --bgcolor:( color 60 130 140 )

	Dialog.dock #RIGHT



)