--filein( getFilenamePath(getSourceFileName()) + "/../../../../../Lib/MeshDataGetter/MeshDataGetter.ms" )	--"./../../../../../Lib/MeshDataGetter/MeshDataGetter.ms"

import_browse

filein( getFilenamePath(getSourceFileName()) + "/../VertexLayers/VertexLayers.ms" )	--"./../VertexLayers/VertexLayers.ms"
filein( getFilenamePath(getSourceFileName()) + "/../VertexGrid/VertexGrid.ms" )	--"./../VertexGrid/VertexGrid.ms"
filein( getFilenamePath(getSourceFileName()) + "/../VertexGridGetter/VertexGridGetter.ms" )	--"./../VertexGridGetter/VertexGridGetter.ms"

/** Get lowest verts in grid


	IMPORTANT:
		  DIFFERENT METHODS CAN RETURN DIFFERENT BitArray ON SAME SELECTION e.g.: #{1..157090} and #{1..930, 932..157091} -- vertext index 931 is missing and array is larger

		  In polyop methods is one vertex index missing in middle of BitArray

			Noticed on model imported from Zbrush

		  SOLUTION: REXPORT OBJECT, xform and attach to new object doesnt help

		  A) 'getVertSelection obj.mesh'	returns #{1..1000}
		  B) 'polyop.getVertSelection obj'	returns #{1..930, 932..1001}


 */
struct VertSelector_v
(
	/* construct */
	obj_original,	-- not collapesd original object
	obj,	-- editable poly object used to process

	/* properties */
	sel_modified = #{},
	face_elements = #(),

	verts_pos,
	--data_verts,
	--resolution = 5,
	--resolution = 10,

	/* dependency */
	MeshDataGetter,
	VertexGridGetter,
	VertexLayers,

	/* reference */
	/* inhered */

	/** Get lowest verts in grid
	 */
	function selectLowestVertsInGrid resolution:10 =
	(
		--format "\n"; print "VertSelector_v.selectLowestVertsInGrid()"
		VertexGridGetter.resolution = resolution

		this.sel_modified = VertexGridGetter.getLowestVertsInGrid()

		this._selectVertsAndReturn(true) --return
	),

	/** Get lowest verts in grid
	 */
	function selectMiddleVertsInGrid resolution:10 =
	(
		--format "\n"; print "VertSelector_v.selectLowestVertsInGrid()"
		VertexGridGetter.resolution = resolution

		this.sel_modified = VertexGridGetter.getMiddlePointsInGrid()

		this._selectVertsAndReturn(true) --return
	),

	/** Get lowest verts in grid
	 */
	function selectChecker mode:#2D resolution:10 =
	(
		format "\n"; print "VertSelector_v.selectChecker()"
		format "RESOLUTION: %\n" resolution
		VertexGridGetter.resolution = resolution

		this.sel_modified = if mode == #3D then
								VertexGridGetter.getCheckerPattern3D()
							else
								VertexGridGetter.getCheckerPattern2D()

		this._selectVertsAndReturn(true) --return

	),

	/** Get lowest verts in grid
	 */
	function selectChecker2D resolution:10 invert_sel:false =
	(
		format "\n"; print "VertSelector_v.selectChecker()"
		format "RESOLUTION: %\n" resolution
		VertexGridGetter.resolution = resolution

		this.sel_modified = VertexGridGetter.selectChecker2D invert_sel:invert_sel

		this._selectVertsAndReturn(true) --return

	),

	/** Find islands per layer
	 */
	function findIslandsPerLayer =
	(
		--format "\n"; print "VertSelector_v.findIslandsPerLayer_timer()"
		--format "VertexLayers: %\n" VertexLayers
		--format "findIslandsPerLayer_timer: % ms\n" (( timeStamp()) - findIslandsPerLayer_timer)
		VertexLayers.findVertsOfNewIslands()

		new_islands_all = #{}
		--new_islands_all = for new_island in VertexLayers.VertIslandFinder.new_islands collect new_island
		for new_island in VertexLayers.VertIslandFinder.new_islands do new_islands_all += new_island
		--format "new_islands_all: %\n" new_islands_all
		new_islands_all --return
	),

	/** Select sinlge vert per face island

		Point with lowest position on Z
	 */
	function selectSingleVertPerFaceIsland sel:true =
	(
		--format "\n"; print "VertSelector_v.selectSingleVertPerFaceIsland()"
		/**  Left only single lowest vert of verts
		  *   Verts above are removed from selection
		 */
		function _filterOnlyMinZVerts verts =
		(
			/* VERTS CAN BE UNDEFINED IF CELL IS EMPTY */
			if verts.numberSet > 0 then
			(
				if ( lowest_vert = this._getLowestVertOnZaxis(verts) ) != undefined then
					this.sel_modified[lowest_vert] = true
				else
					this.sel_modified[(verts as Array )[1] ] = true
			)

		)

		--data_verts = MeshDataGetter.getVertexData verts:#SELECTED positions:true
		verts_sel	= getVertSelection obj.mesh


		 this._setVertsPositions(verts_sel)

		hidden_verts = polyop.getHiddenVerts obj

		------if  data_verts[#VERTS].numberSet == 0 then
		------	return false

		this.sel_modified = #{}

		--this.sel_modified = copy data_verts[#VERTS]

		/* LOOP EACH ISLAND OF VERTS */
		for verts_island in (verts_islands = this._sortVertsByIslands()) do
		(
			--format "\n"
			--format "VERTS_ISLAND: %\n" verts_island
			--format "ISLAND SEL: %\n" (verts_island *  verts_sel )

			--this.sel_modified +=  (verts_island *  verts_sel )

			this.sel_modified[( (verts_island *  verts_sel ) as Array )[1]] = true


			--_filterOnlyMinZVerts ( verts_island *  verts_sel )
			--_filterOnlyMinZVerts ( verts_island )
		)
		--gc()

		this._selectVertsAndReturn(sel) --return
	),

	/** Get ace islands by verts
	  *
	  * @param BitArray verts which faces will be sorted by islands
	  *
	  * @return #( #{..} ) array of vertex ids, each array are verts of one island
	 */
	function _sortVertsByIslands =
	(
		--format "\n"; print "VertSelector_v._sortVertsByIslands()"

		function facesShareVerts verts1 verts2 = not ( verts1 * verts2 ).isEmpty
		--function facesShareVerts verts1 verts2 = ( verts1 * verts2 ).numberSet > 1

		tested_pairs	= #{} -- store stringified array of face id used in loop already
		verts_islands	= #() -- #( #{ veret_ids } ) array of bitarrays of verts sorted by island the occupy
		--face_islands	= #() -- #( #{ faces_ids } ) array of bitarrays of faces sorted by island the occupy
		verts_per_faces	= #()

		verts_sel	= getVertSelection obj.mesh

		faces_by_verts = ( polyop.getFacesUsingVert obj verts_sel ) as Array

		verts_per_faces = for f in faces_by_verts collect polyop.getVertsUsingFace obj #{f}



		for f = 1 to faces_by_verts.count do
		(
			--format "f: %\n" f
			joined = #()

			for i = 1 to verts_islands.count where facesShareVerts (verts_islands[i]) (verts_per_faces[f]) do
				(
					verts_islands[i] += verts_per_faces[f]

					append joined i
				)

			if joined.count > 1 then
			(
				--format "joined: %\n" joined
				sort joined

				first_island = joined[1]

				joined = deleteItem joined 1
				--format "joined: %\n" joined

				islands_reversed = for i = joined.count to 2 by -1 collect joined[i]

				for island_to_merge in islands_reversed where (verts_islands[first_island] * verts_islands[island_to_merge]).numberSet > 1 do
				--for island_to_merge in deleteItem joined 1 do
				(
					--format "island_to_merge: %\n" island_to_merge
					verts_islands[first_island] += verts_islands[island_to_merge]

					deleteItem verts_islands island_to_merge
				)


			)
			else if joined.count == 0 then
			(
				append verts_islands verts_per_faces[f]

				--format "verts_islands: %\n" verts_islands.count
			)

		)


		verts_islands --return
	),

	--/** Select final selection
	-- */
	--function selectVerts subobject:#VERTEX =
	--(
	--	--format "\n"; print "VertSelector_v.selectVerts()"
	--	--format "verts: %\n" verts
	--
	--	max modify mode
	--
	--	setSelectionLevel obj subobject
	--
	--	_mod = modPanel.getCurrentObject()
	--
	--	_mod.SetSelection subobject #{}
	--
	--	if classOf _mod == Edit_Poly then
	--		_mod.Select subobject this.sel_modified
	--
	--	else if classOf _mod  == Editable_Poly then
	--		_mod.SetSelection subobject this.sel_modified
	--),

	/** Select final selection
	 */
	function setSelection sel_bitarray subobject:#VERTEX =
	(
		format "\n"; print "VertSelector_v.selectVerts()"
		--format "sel_bitarray: %\n" sel_bitarray

		max modify mode

		setSelectionLevel obj subobject

		_mod = modPanel.getCurrentObject()

		_mod.SetSelection subobject #{}

		if classOf _mod == Edit_Poly then
			_mod.Select subobject sel_bitarray

		else if classOf _mod  == Editable_Poly then
			_mod.SetSelection subobject sel_bitarray
	),


	private

	/** Detach method
	 */
	function setFaceElements faces_of_verts =
	(
		--format "\n"; print ".detachMethod()"
		--format "faces_of_verts: %\n" faces_of_verts
		obj_snap = snapshot obj

		convertTo obj_snap PolyMeshObject

		polyop.detachFaces obj_snap faces_of_verts delete:true

		local poGetElementsUsingFace = polyop.getElementsUsingFace

		while not faces_of_verts.isEmpty do
        (
			face = (faces_of_verts as array)[1]

			element = poGetElementsUsingFace obj_snap #(face)

			append face_elements element

			faces_of_verts -= element
		)

		delete obj_snap

		--face_elements --return
	),

	--/**  Left only single lowest vert of verts
	--  *   Verts above are removed from selection
	-- */
	--function _filterOnlyMinZVerts verts =
	--(
	--	--format "\n"; print "VertexGridGetter_v._SelectOnlyMinZVerts()"
	--	--format "verts: %\n" verts
	--
	--	/* VERTS CAN BE UNDEFINED IF CELL IS EMPTY */
	--	if verts.numberSet > 0 and ( lowest_vert = this._getLowestVertOnZaxis(verts) ) != undefined then
	--		this.sel_modified[lowest_vert] = true
	--
	--	lowest_vert --return
	--
	--	/* REMOVE OTHER VERTS FROM SELECTION */
	--	--for vert in verts_to_remove do
	--		--this.sel_modified[vert] = false
	--),

	/** Get vert with min z pos
	  *
	  * @param BitArray verts
	 */
	function _getLowestVertOnZaxis verts =
	(
		format "\n"; print "VertexGridGetter_v._getLowestVertOnZaxis()"
		verts_arr = verts as Array

		/* GET LOWEST POINT IN CELL */
		if verts_arr.count > 1 then
		(
			z_positions = for vert in verts collect verts_pos[vert].z
			format "Z_POSITIONS: %\n" z_positions
			--z_positions = for pos in (meshop.getVerts obj.mesh verts node:obj) collect pos.z

			if ( index = findItem z_positions (amin z_positions) ) > 0 then
				verts_arr[index] --return
		)
		else
			verts_arr[1] --return

			--verts_arr[1] --return
	),

	/** Select and return mofified selection
	 */
	function _selectVertsAndReturn make_selection =
	(
		if make_selection then
			this.setSelection this.sel_modified

		this.sel_modified  --return
	),

	/** Set verts positions
	 */
	function _setVertsPositions verts =
	(
		format "\n"; print "SourceObject_v._setVertsPositions()"
		--format "verts_process: %\n" verts_process
		--format "verts: %\n" verts
		--format "verts.numberSet: %\n" verts.numberSet
		all_verts = #{1..(getNumVerts obj.mesh)}

		if verts_pos == undefined then
			this.verts_pos = all_verts as Array

		verts_process_pos = in coordsys world meshop.getVerts obj.mesh verts node:obj
		--format "verts_process_pos: %\n" verts_process_pos

		for i = 1 to verts_process_pos.count do
		(
			vert = (verts  as Array )[i]
			--format "vert: %\n" vert

			verts_pos[vert] = verts_process_pos[i]
		)


		verts_pos --return

		--verts_pos = in coordsys world meshop.getVerts obj.mesh all_verts node:obj

		--verts_pos --return
	),

	/** Set object
	 */
	function _setObject =
	(
		format "\n"; print "GridLayerManager_v.setObject()"
		format "this.obj_original: %\n" this.obj_original
		this.obj = this.obj_original -- DEV

		--this.obj  = snapshot this.obj_original

		--convertTo this.obj PolyMeshObject
	),

	/**
	 */
	on create do
	(
		format "\n"; print "VertSelector.onCreate()"
		print "***********************\n***********************"
		this._setObject()

		VertexLayers 	= VertexLayers_v( obj )
		VertexGrid 	= VertexGrid_v( obj )
		--MeshDataGetter 	= MeshDataGetter_v( obj )
		VertexGridGetter 	= VertexGridGetter_v( obj )

	)



)
