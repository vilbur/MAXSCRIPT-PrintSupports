

/** Open island sdialog with VISIBLE islands
 *
 */
macroscript	maxtoprint_islands_dialog
category:	"_3D-Print"
buttontext:	"I S L A N D S  ☰"
toolTip:	"Open islands dialog with VISIBLE islands"
icon:	"across:3|height:32"
(
	on execute do
	(
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-02-ISLANDS\Lib\IslandsSystem\IslandsSystem.ms"
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-02-ISLANDS\Lib\IslandManagerDialog\IslandManagerDialog.ms"
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-02-ISLANDS\[FIND ISLANDS].mcr"

		undo off
		(
			obj	= selection[1]

			ISLANDS_SYSTEM = IslandsSystem_v(obj)

            VertSelector = VertSelector_v(obj) --"./../rollout-VERTEX_SELECTION/Lib/VertSelector/VertSelector.ms"

			/* DISABLE SLICER MODIFIERS */
			SLICER_SYSTEM.toggleModifiers false

			layer_height = DIALOG_content.SPIN_layer_height.value

			/* LOAD DATA FROM OBJECT PROPERTIES */
			islands_data_loaded = getUserPropVal obj "ISLANDS_DATA"


			/* SET ISLANDS DATA */
			ISLANDS_SYSTEM.islands_data = if islands_data_loaded != undefined then
					/*  */
					ISLANDS_SYSTEM.fitZpozitions( islands_data_loaded )(layer_height)

				else /* GET NEW ISALNDS DATA */
					VertSelector.findIslandsPerLayer(layer_height)



			/* GET NEW ISALNDS DATA */
			new_islands = for island_data in ISLANDS_SYSTEM.islands_data collect island_data[#NEW_ISLAND]

			lowest_verts = for island_data in ISLANDS_SYSTEM.islands_data collect island_data[#LOWEST_VERT]


			--lowest_verts = VertSelector.getLowestVerts ( new_islands )

			VertSelector.setSelection ( lowest_verts as BitArray )

			if ISLANDS_SYSTEM.islands_data.count == 0 then
				messageBox "EMPTY ISLANDS DATA" title:"[FIND ISLANDS].mcr"


			/* SAVE ISlANDS DATA TO OBJECT */
			setUserPropVal obj "ISLANDS_DATA" ISLANDS_SYSTEM.islands_data

			/* RE ENABLE SLICER MODIFIERS */
			SLICER_SYSTEM.toggleModifiers true


			/* CREATE DIALOG */
			createIslandManagerDialog()
		)
	)
)


/** Open island sdialog with ALL islands
 *
 */
macroscript	maxtoprint_islands_dialog_show_all
category:	"_3D-Print"
buttontext:	"I S L A N D S  ☰"
toolTip:	"Open islands dialog with ALL islands"
icon:	"across:3|height:32"
(
	on execute do
	(
		undo off
		(
			if DIALOG_island_manager != undefined then
				createIslandManagerDialog islands_to_show:#{}
		)
	)
)

/**
 *
 */
macroscript	maxtoprint_find_islands
category:	"_3D-Print"
buttontext:	"Search Islands"
toolTip:	"Search islands"
icon:	"across:3"
(
	on execute do
	(
		obj	= selection[1]

		deleteUserProp selection[1] "ISLANDS_DATA"

		macros.run "_3D-Print" "maxtoprint_islands_dialog"
	)
)
