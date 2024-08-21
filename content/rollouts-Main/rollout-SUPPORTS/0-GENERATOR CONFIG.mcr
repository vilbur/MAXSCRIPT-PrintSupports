

/**  Export format
  *
 */
macroscript	_print_generator_normal_mode
category:	"_Export"
buttontext:	"Second Point Direction"
toolTip:	"Where support is connected to beam"
icon:	"across:3|align:#LEFT|control:radiobuttons|items:#( 'NORMAL', 'DOWN' )|columns:3|offset:[ 4, 2]"
(
	--export_dir = execute ("@"+ "\""+EventFired.Roll.export_dir.text +"\"")

	--DosCommand ("explorer \""+export_dir+"\"")
	SUPPORT_MANAGER.updateModifiers (EventFired.control) (EventFired.val)
)

/** SPINNER
  */
macroscript	_print_platform_generator_normal_length
category:	"_3D-Print"
buttontext:	"Normal Length"
tooltip:	"Length of first segment of platform facing to vertex normal"
icon:	"across:3|control:spinner|offset:[ 0, 20 ]|fieldwidth:24|range:[ 0.1, 999, 3 ]"
(
	SUPPORT_MANAGER.updateModifiers (EventFired.control) (EventFired.val)
)


--/**
--  *
--  */
--macroscript	_print_support_generate_quet
--category:	"_3D-Print"
--buttontext:	"Quiet Mode"
----toolTip:	"For objects to keep position on export\n\n(Create boxes in corners of print plane to keep exported position)"
--icon:	"control:checkbox|across:3|offset:[ 12, 2 ]"
--(
--	--format "EventFired	= % \n" EventFired
--	--(PrinterVolume_v()).createVolume(#box)(ROLLOUT_export.SPIN_export_size.value)
--)



/*
*/
macroscript	_print_support_generator_live_update
category:	"_3D-Print"
buttontext:	"UPDATE"
tooltip:	"Live update supports on their transfrom"
icon:	"control:#checkbutton|across:3|offset:[0, 6]|height:32|width:96|tooltip:"
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