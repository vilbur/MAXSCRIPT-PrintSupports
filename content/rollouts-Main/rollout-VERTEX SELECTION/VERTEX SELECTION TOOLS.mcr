


/** Select verts by cavity
	All verts are used if nothing selected

  @param #CONVEX|#CONCAVE|#MIXED|#CORNER


	CTRL:  Use all verts
	SHIFT: Select convex\concave and mixed
	ALT:	Hide other types of verts

 */
function selectConcexOrBottomFacesOrVers mode subobject:#VERTEX =
(

		fn _getSelection obj subobject = if subobject == #FACE then polyop.getFaceSelection obj else polyop.getVertSelection obj -- return
		/** Select final selection
		 */
		fn setSelection obj verts subobject:#VERTEX =
		(
			format "\n"; print "VertSelector_v.selectVerts()"
			--format "verts: %\n" verts

			max modify mode

			setSelectionLevel obj subobject

			_mod = modPanel.getCurrentObject()

			_mod.SetSelection subobject #{}

			if classOf _mod == Edit_Poly then
				_mod.Select subobject verts

			else if classOf _mod  == Editable_Poly then
				_mod.SetSelection subobject verts
		)

	--format "\n"; print ".selectVertsByCavity()"
		obj	= selection[1]

		--VertSelector 	= VertSelector_v( obj  )

		ctrl	= keyboard.controlPressed
		alt	= keyboard.altPressed
		shift	= keyboard.shiftPressed



		if ctrl then
		(
			obj.EditablePoly.unhideAll subobject

			obj.EditablePoly.SetSelection subobject #{}
		)

		max modify mode

		setSelectionLevel obj subobject

		sel_old = _getSelection obj subobject

		if mode == #BOTTOM then
		(
			--PolyToolsSelect.Normal 3 120 true
			PolyToolsSelect.Normal 3 150 true
			--PolyToolsSelect.Normal 3 170 true

			sel_new = _getSelection obj subobject
			--format "not (sel_old * sel_new).isEmpty: %\n" (not (sel_old * sel_new).isEmpty)
			if not sel_old.isEmpty then
				setSelection obj ( sel_new * sel_old ) subobject:subobject
		)
		else
		(
			--PolyToolsSelect.ConvexConcave 0.1 2 -- select convex and convex-concave
			--PolyToolsSelect.ConvexConcave 0.001 2 -- select convex and convex-concave
			PolyToolsSelect.ConvexConcave 0.0001 2 -- select convex and convex-concave

			sel_new = _getSelection obj subobject
			--format "not (sel_old * sel_new).isEmpty: %\n" (not (sel_old * sel_new).isEmpty)
			--if not sel_old.isEmpty and not (sel_old - sel_new).isEmpty then
			if not sel_old.isEmpty then
				setSelection obj ( sel_new * sel_old) subobject:subobject

		)


		if alt then
			obj.EditablePoly.unhideAll subobject


		if subobject != #FACE and not alt then
		(
			actionMan.executeAction 0 "40044"  -- Selection: Select Invert

			obj.EditablePoly.hide subobject

			actionMan.executeAction 0 "40021"  -- Selection: Select All

		)

	--if subobject == #FACE then polyop.getFaceSelection obj else polyop.getVertSelection obj -- return
)




/**
 *
 */
macroscript	maxtoprint_get_convex_verts
category:	"maxtoprint"
buttontext:	"CONVEX"
toolTip:	"VERTS"
icon:	"tooltip:CTRL: Reset selection"
(
	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"

		selectConcexOrBottomFacesOrVers #CONVEX
	)
)

/**
 *
 */
macroscript	maxtoprint_get_convex_faces
category:	"maxtoprint"
buttontext:	"CONVEX"
toolTip:	"FACES"
--icon:	"tooltip:CTRL: Reset selection"
(
	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"

		selectConcexOrBottomFacesOrVers #CONVEX subobject:#FACE
	)
)



/**
 *
 */
macroscript	maxtoprint_get_bottom_verts
category:	"maxtoprint"
buttontext:	"BOTTOM"
toolTip:	"VERTS"
icon:	"tooltip:CTRL: Reset selection"
(
	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"

		selectConcexOrBottomFacesOrVers #BOTTOM
	)
)

/**
 *
 */
macroscript	maxtoprint_get_bottom_faces
category:	"maxtoprint"
buttontext:	"BOTTOM"
toolTip:	"FACES"
--icon:	"tooltip:CTRL: Reset selection"
(
	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"

		selectConcexOrBottomFacesOrVers #BOTTOM subobject:#FACE
	)
)




/**
  *
  */
macroscript	_print_select_single_vert_of_faces
category:	"_Print-Points-Tools"
buttonText:	"1 on island"
toolTip:	"Get only signlge vertex of each face island"
icon:	"MENU:true|across:4|height:24"
(
	on execute do
	if subObjectLevel == 1 then
	undo "Filter 1 vert per face" on
	(
		clearListener(); print("Cleared in:\n"+getSourceFileName())
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\3-1-3-VERTEX SELECTION TOOLS.mcr"
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\Lib\VertSelector\VertSelector.ms"

		VertSelector 	= VertSelector_v( selection[1] )

		VertSelector.selectSingleVertPerFaceIsland()
		--VertSelector.selectVerts()

		--free VertSelector
		--VertSelector = undefined

		--gc()
	)
)



/**  Checkerboard selection
  *
 */
macroscript	_print_select_verts_checker_pattern
category:	"_Print-Points-Tools"
buttonText:	"Checker"
toolTip:	"Get selection of selected vertices in cheker pattern"
icon:	"MENU:false|across:4|height:24"
(
	on execute do
	if selection.count > 0 then
	(
		clearListener(); print("Cleared in:\n"+getSourceFileName())
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\3-1-3-VERTEX SELECTION TOOLS.mcr"
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\Lib\VertSelector\VertSelector.ms"

		obj	= selection[1]

		VertSelector 	= VertSelector_v( obj ) -- resolution:ROLLOUT_vertex_selection.SPIN_grid_step.value

		VertSelector.selectChecker resolution:ROLLOUT_vertex_selection.SPIN_grid_step.value invert_sel:( keyboard.controlPressed )

		--VertSelector.selectVerts()

	)
)



/**
 *
 */
macroscript	maxtoprint_get_bottom_verts
category:	"maxtoprint"
buttontext:	"SUpports > Verts"
toolTip:	"Select verts of source object which belongs to selected supports"
icon:	"across:4"
(
	on execute do
	(
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
)

