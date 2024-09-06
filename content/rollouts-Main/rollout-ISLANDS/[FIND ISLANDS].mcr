filein( getFilenamePath(getSourceFileName()) + "/Lib/IslandManagerDialog/IslandManagerDialog.ms" )	--"./Lib/IslandManagerDialog/IslandManagerDialog.ms"


/**
 *
 */
macroscript	maxtoprint_islands_dialog
category:	"maxtoprint"
buttontext:	"SHOW islands"
toolTip:	"SHOW islands Dialog"
icon:	"across:3"
(
	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"
		--gc light:true

		undo off
		(
			SLICER_SYSTEM.toggleModifiers false

			obj	= selection[1]

			layer_height = 0.05

			ISLANDS_SYSTEM = IslandsSystem_v(obj)

			VertSelector 	= VertSelector_v(obj)

			if ( ISLANDS_SYSTEM.islands_data = getUserPropVal obj "ISLANDS_DATA" ) == undefined then
				ISLANDS_SYSTEM.islands_data = VertSelector.findIslandsPerLayer(layer_height)

			new_islands = for island_data in ISLANDS_SYSTEM.islands_data collect island_data[#NEW_ISLAND]

			lowest_verts = VertSelector.getLowestVerts ( new_islands )

			VertSelector.setSelection ( lowest_verts )

			if ISLANDS_SYSTEM.islands_data.count == 0 then
				messageBox "EMPTY ISLANDS DATA" title:"[FIND ISLANDS].mcr"


			setUserPropVal obj "ISLANDS_DATA" ISLANDS_SYSTEM.islands_data

			SLICER_SYSTEM.toggleModifiers true

			createIslandManagerDialog()
		)
	)
)

/**
 *
 */
macroscript	maxtoprint_find_islands
category:	"maxtoprint"
buttontext:	"FIND islands"
toolTip:	"Refresh islands"
icon:	"across:3"
(
	on execute do
	(
		obj	= selection[1]

		deleteUserProp selection[1] "ISLANDS_DATA"

		macros.run "maxtoprint" "maxtoprint_islands_dialog"
	)
)
