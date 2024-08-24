--filein( getFilenamePath(getSourceFileName()) + "/Lib/PinsGenerator.ms" )	--"./Lib/PinsGenerator.ms"


/*
*/
macroscript	_print_generator_holes
category:	"_3D-Print"
buttontext:	"DRAINS"
icon:	"across:3|offset:[ 0, 0 ]|height:32|width:96|tooltip:GEENERATE PINS for selected verts"
(
	on execute do
		undo "Generate DRAINS" on
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-PINS & DRAINS\DRAINS.mcr"
			/** SWEEP Modifier
			  *
			  */
			function _sweepSetup sweep_mod diameter =
			(
				--format "\n"; print "SupportModifiers_v._sweep()"

				/** Reset mod propertis -- sweep mpdofoer keeps its settings if newly created, i dont know why.. oteh modifiers dont do that :D

					QUICK SOLUTION - FOR MORE MODIFIERS OR PROPERTIES SHOULD COMPLEX SOLUTUION EXISTS

				 */
				function resetSweepModProperties sweep_mod =
				(
					sweep_mod.MirrorXZPlane = off
					sweep_mod.MirrorXYPlane = off

					sweep_mod.XOffset = 0
					sweep_mod.yOffset = 0

					sweep_mod.angle = 0
					sweep_mod.SmoothSection = off
					sweep_mod.SmoothPath = off
					sweep_mod.PivotAlignment = 4


					sweep_mod.GenMatIDs = on
					sweep_mod.UseSectionIDs = off
					sweep_mod.UsePathIDs = off
				)

				resetSweepModProperties(sweep_mod)

				sweep_mod.CurrentBuiltInShape = 4 -- Set cylinder

				/* GENERATE MATERIAL ID */
				sweep_mod.UseSectionIDs	= false
				sweep_mod.UsePathIDs	= true

				sweep_mod[#Cylinder_Section].radius = diameter / 2

				sweep_mod --return
			)


			sweep_mod = sweep ()

			shapes_to_update	= #()

			obj	= selection[1]

			verts	= getVertSelection obj.mesh

			verts_pos = in coordsys world meshop.getVerts obj.mesh verts node:obj

			direction = [ 0, 0, 1 ]

			for i = 1 to verts.numberSet do
			(
				knots = #()
				--format "knots: %\n" knots

				knots[1] = verts_pos[i] + ( 2 * direction ) -- make raft longer by multiplying normal length 10x
				knots[2] = verts_pos[i] + ( 2 * (direction * -1 ) ) -- make raft longer by multiplying normal length 10x

				support_obj = SplineShape()

				--format "\n"; print "SupportObject_v._drawRaftLine()"
				addNewSpline support_obj

				/*------------------------------------------------------------------------------
					ADD KNOTS BY POINTS FROM TOP TO BOTTOM
				--------------------------------------------------------------------------------*/
				for pos in knots do
					addKnot support_obj 1 #corner #line pos

				append shapes_to_update support_obj
			)

			with redraw off
				for _shape in shapes_to_update do
					updateShape _shape

			redrawViews()

			select shapes_to_update

			modPanel.addModToSelection sweep_mod ui:on

			_sweepSetup sweep_mod SUPPORT_OPTIONS.drain_width

		)
)

/** BAR WIDTH
 */
macroscript	_print_platform_generator_drain_width
category:	"_3D-Print"
buttontext:	"WIDTH"
tooltip:	"Bar width in mm of printed model.\n\nExported scale is used"
icon:	"control:spinner|id:SPIN_drain_width|across:3|range:[ 0.5, 10, 1.0 ]|width:64|offset:[ -8, 12 ]"
(
	--format "EventFired:	% \n" EventFired
	on execute do
		SUPPORT_MANAGER.updateModifiers (EventFired.control) (EventFired.val)
)
