

/**
 *
 */
macroscript	maxtoprint_select_verts_by_supports
category:	"maxtoprint"
buttontext:	"SUPPORT ↔ VERT"
toolTip:	"Select verts of source object which belongs to selected supports"
icon:	"across:4"
(

	/** Select supports by vert
	 */
	function selectSupportsByVerts =
	(
		format "\n"; print ".selectSupportsByVert()"

		obj	= selection[1]

		--source_objects = SUPPORT_MANAGER.getObjectsByType ( obj ) type:#SOURCE -- hierarchy:shift
		--format "source_objects: %\n" source_objects
		vertex_sel	= getVertSelection obj.mesh

		SourceObjects = SUPPORT_MANAGER.getSourceObjects ( selection as Array )
		--format "SourceObjects: %\n" SourceObjects

		SourceObject = SourceObjects[1]

		supports = for index in SourceObject.Supports.keys where vertex_sel[index] collect SourceObject.Supports[index].support_obj

		if supports.count > 0 then
			select supports

	)

	/** Select verts by supports
	 */
	function selectVertsBySupports =
	(
		--format "\n"; print ".selectVertsBySupports()"
		_objects = selection as Array

		source_objects = SUPPORT_MANAGER.getObjectsByType ( _objects ) type:#SOURCE -- hierarchy:shift

		format "source_objects: %\n" source_objects

		supports = SUPPORT_MANAGER.getObjectsByType _objects type:#SUPPORT

		format "supports: %\n" supports

		SourceObjects = SUPPORT_MANAGER.getSourceObjects source_objects

		for SourceObject in SourceObjects do
		(
			--format "SourceObject: %\n" SourceObject
			indexes =( for index in SourceObject.Supports.keys where SourceObject.Supports[index].support_obj.isSelected collect index) as BitArray

			format "indexes: %\n" indexes

			obj = SourceObject.obj.baseobject

			max modify mode

			verts_hidden = polyop.getHiddenVerts obj

			polyop.setHiddenVerts obj (verts_hidden - indexes )

			obj.SetSelection #VERTEX indexes

		)

		if SourceObjects.count == 1 then
		(
			select SourceObjects[1].obj

			subObjectLevel = 1
		)
		else if SourceObjects.count > 1 then
			select ( 	for SourceObject in SourceObjects collect SourceObject.obj )
	)

	on execute do
	(
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-VERTEX SELECTION\VERTEX SELECTION TOOLS.mcr"

		if subObjectLevel == 0 then
			selectVertsBySupports()

		else if subObjectLevel == 1 then
			selectSupportsByVerts()
	)
)

/**
 *
 */
macroscript	maxtoprint_select_supports_on_ground
category:	"maxtoprint"
buttontext:	"ON GROUND"
toolTip:	"Select supports which are on ground"
icon:	"across:4"
(
	on execute do
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-SELECTION-TOOLS\SUPPORT SELECTION.mcr"

		supports = SUPPORT_MANAGER.getObjectsByType ( selection as Array ) type:#SUPPORT -- hierarchy:shift

		supports_on_ground = for support in supports where support.min.z as integer == 0 collect support

		select supports_on_ground
	)
)

/**
 *
 */
macroscript	maxtoprint_select_supports_not_on_ground
category:	"maxtoprint"
buttontext:	"ON GROUND"
toolTip:	"Select supports which are NOT on ground"
--icon:	"across:4"
(
	on execute do
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-SELECTION-TOOLS\SUPPORT SELECTION.mcr"

		supports = SUPPORT_MANAGER.getObjectsByType ( selection as Array ) type:#SUPPORT -- hierarchy:shift

		supports_on_ground = for support in supports where support.min.z as integer != 0 collect support

		select supports_on_ground
	)
)



/**
 *
 */
macroscript	maxtoprint_select_by_direction
category:	"maxtoprint"
buttontext:	"BY DIRECTION"
toolTip:	"Select only supports with normal DOWN"
icon:	"across:4"
(

	on execute do
	(
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-SELECTION-TOOLS\SUPPORT SELECTION.mcr"

		supports = SUPPORT_MANAGER.getObjectsByType ( selection as Array ) type:#SUPPORT -- hierarchy:shift


		filtered = for support in supports where getUserPropVal support "DIRECTION" == [0,0,-1] collect support

		select filtered
	)
)




/** Select supports by beams count
 */
function selectSupportsByBeamsCount count =
(
	--format "\n"; print ".selectSupportsByBeamsCount()"

	_objects = (if selection.count > 0 then selection else objects) as Array

	--source_objects = SUPPORT_MANAGER.getObjectsByType ( _objects ) type:#SOURCE -- hierarchy:shift

	supports = SUPPORT_MANAGER.getObjectsByType _objects type:#SUPPORT
	format "supports.count: %\n" supports.count
	--beams = SUPPORT_MANAGER.getObjectsByType supports type:#BEAM

	bemas_of_supports = for support in supports collect SUPPORT_MANAGER.getObjectsByType support type:#BEAM
	--SUPPORT_MANAGER.getObjectsByType beams type:#SUPPORT
	--format "bemas_of_supports.count: %\n" bemas_of_supports.count
	--format "source_objects: %\n" source_objects
	supports_by_count = for i = 1 to bemas_of_supports.count where bemas_of_supports[i].count == count collect supports[i]

	if supports_by_count.count > 0 then
		select supports_by_count

)


/**
 *
 */
macroscript	maxtoprint_select_supports_with_beams
category:	"maxtoprint"
buttontext:	"BY BEAMS"
toolTip:	"Select supports without beams"
icon:	"across:4"
(
	on execute do
		selectSupportsByBeamsCount 0
)


/**
 *
 */
macroscript	maxtoprint_select_supports_with_beams_by_count
category:	"maxtoprint"
buttontext:	"BY BEAMS"
toolTip:	"Select supports by beams count"
(
	on execute do
	(
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-SELECTION-TOOLS\SUPPORT SELECTION.mcr"


		/* DEFINE MAIN MENU */
		Menu = RcMenu_v name:"GenerateBeamsMenu"

		Menu.item "With 1 beam" ( "selectSupportsByBeamsCount 1" )
		Menu.item "With 2 beam" ( "selectSupportsByBeamsCount 2" )
		Menu.item "With 3 beam" ( "selectSupportsByBeamsCount 3" )
		Menu.item "With 4 beam" ( "selectSupportsByBeamsCount 4" )

		popUpMenu (Menu.create())
	)
)



