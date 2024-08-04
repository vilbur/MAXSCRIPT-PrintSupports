--filein( getFilenamePath(getSourceFileName()) + "/../MeshDataGetter/MeshDataGetter.ms" )	--"./../MeshDataGetter/MeshDataGetter.ms"



/** Grid vert selector
 */
struct VertexGrid_v
(
	/* construct */
	obj,

	/* required */


	/* properties */
	--resolution = 5,
	resolution = 10,

	verts_pos,


	/* private */
	/* dependency */
	/* reference */
	/* inhered */



	/* reference */
	verts_data,	-- MeshDataGetter.verts_data
	data_faces,	-- MeshDataGetter.data_faces


	/* private */
	/* dependency */
	--VerIslandFinder = VerIslandFinder_v(),


	--resolution = 10,

	points_grid 	= #(), -- 2DMatrix of verts which share same cell in grid points_grid[X_CELL][Y_CELL]
	--sel_modified 	= #{}, -- modified selection for selecting
	round_grid	= #( #(), #(), #() ), -- 3D matrix of points positions rounded into 3 grid - round_grid[AXIS][CELL][VERT]

	--MeshDataGetter,


	/** Get point in grid

		return 2 matrix of cells on XY grid
			#(
				#( #{x1y1}, #{x1y2} )
				#( #{x2y1}, #{x2y2} )
				#( #{x3y1}, #{x3y2} )
			)
	 */
	function _getVertsInGrid verts =
	(
		format "\n"; print "VertSelector_v._getVertsInGrid()"
		format "verts: %\n" verts

		/** Get cell by position
		 */
		function cellByPos vert_pos_on_axis axis_origin =
		(
			((( vert_pos_on_axis - axis_origin ) / this.resolution) as integer ) + 1
		)

		fn roundPoint3 p3 dp =
		(
			--format "p3: %\n" p3
			local tempArr = #(p3.x,p3.y,p3.z)
			local mult = 10.00^(dp as float)
			local rp3Arr = for c in tempArr collect ((floor ((c * mult)+0.5)) / mult)
			point3 rp3Arr[1] rp3Arr[2] rp3Arr[3]
		)

		verts_pos = this._getVertsPositions(verts)
		format "verts_pos: %\n" verts_pos
		format "verts_pos.count: %\n" verts_pos.count
		verts_arr = verts as Array

		pos_by_axis = this.getPositionsSplitByAxis(verts)
		format "pos_by_axis: %\n" pos_by_axis
		min_pos = #( amin pos_by_axis[1], amin pos_by_axis[2], amin pos_by_axis[3])

		/* FILL MATRIX
			round_grid[AXIS][CELL][VERT]
		*/
		for i = 1 to verts_arr.count do
		(
			vert	= verts_arr[i]
			vert_pos	= verts_pos[i]

			for axis = 1 to 3 do
			--for axis = 1 to 2 do
			(
				level = cellByPos(vert_pos[axis])(min_pos[axis])

				/* CRTEATE NEW CELL */
				if (round_grid[axis][level]) == undefined then
					round_grid[axis][level] = #{}

				/* SET VERT TO BITARRAY OF CELL */
				round_grid[axis][level][vert] = true
			)
		)

		--gc()

		--format "POINTS_GRID: %\n" points_grid

		points_grid --return
	),

	/** Set verts positions
	 */
	function _getVertsPositions verts =
	(
		--format "\n"; print "SourceObject_v._getVertsPositions()"
		--format "verts_process: %\n" verts_process
		--format "verts: %\n" verts
		--format "verts.numberSet: %\n" verts.numberSet

		--if verts_pos == undefined then
		--	this.verts_pos = #{1..(getNumVerts obj.mesh)} as Array
		--
		--verts_process_pos = in coordsys world meshop.getVerts obj.mesh verts node:obj
		----format "verts_process_pos: %\n" verts_process_pos
		--
		--for i = 1 to verts_process_pos.count do
		--(
		--	vert = (verts  as Array )[i]
		--	--format "vert: %\n" vert
		--
		--	verts_pos[vert] = verts_process_pos[i]
		--)
		--
		--
		--verts_pos --return

		all_verts = #{1..(getNumVerts obj.mesh)}

		verts_pos = in coordsys world meshop.getVerts obj.mesh all_verts node:obj

		verts_pos --return
	),


	/** Check selection ingerity
	 */
	function _checkSelectionIngerity mesh_sel polyop_sel =
	(
		--format "\n"; print "VertSelector_v._checkSelectionIngerity()"

		if mesh_sel[mesh_sel.count] 1= polyop_sel[polyop_sel.count] then
			messageBox ("Object '"+obj.name+"' needs to be rexported.\n\nVertex needs to be reindexed" )title:"VertSelector_v"
	),


	/** Get positions of each vert splitted to XYZ
	  * Usefull for gettin min and max values oe verts by each axis separatly
	  *
	  * @return #( #(X pos), #(Y pos), #(Z pos) )
	 */
	function getPositionsSplitByAxis verts =
	(
		format "\n"; print "MeshDataGetter_v.getPositionsSplitted()"

		verts_count = verts.numberSet

		x_positions = #(verts_count)
		y_positions = #(verts_count)
		z_positions = #(verts_count)

		for vert in verts do
		(
			--format "vert: %\n" vert
			vert_pos = verts_pos[vert]
			--format "vert_pos: %\n" vert_pos

			x_positions[vert] = vert_pos.x
			y_positions[vert] = vert_pos.y
			z_positions[vert] = vert_pos.z
		)

		--format "x_positions: %\n" x_positions
		--format "y_positions: %\n" y_positions
		--format "z_positions: %\n" z_positions

		x_positions = for x_position in x_positions where x_position != undefined collect x_position
		y_positions = for y_position in y_positions where y_position != undefined collect y_position
		z_positions = for z_position in z_positions where z_position != undefined collect z_position

		#( x_positions, y_positions, z_positions  ) --return
	),










	private


	/**
	 */
	on create do
	(
		--format "\n"; print "VertexGrid.onCreate()"
		--MeshDataGetter 	= MeshDataGetter_v( obj )
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)



)
