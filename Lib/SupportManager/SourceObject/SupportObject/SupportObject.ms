filein( getFilenamePath(getSourceFileName()) + "/../PointHelper/PointHelper.ms" )	--"./../PointHelper/PointHelper.ms"

/** Support object
 */
struct SupportObject_v
(

	/*------ EXTENDS  ------*/
	include "MAXSCRIPT-PrintSupports/Lib/SupportManager/SourceObject/SupportRaftBaseObject/SupportRaftBaseObject.ms" --"./../SupportRaftBaseObject/SupportRaftBaseObject.ms"


	is_on_ground = false,

	--knots_positions = #(),
	--knots_positions = Array (2),

	--Beams = #(),

	/* private */

	/* dependency */

	/* reference */
	/* inhered */

	/** Generate support
	 */
	function generateSupport vertex_index pos: clr: normal: =
	(
		--format "\n"; print "SupportObject_v.generateSupport()"

		--this.support_obj = SplineShape name:(this._getName()) wirecolor:(this._shiftWirecolor(clr)(vertex_index) ) pos:knots_positions[1]
		this.support_obj = SplineShape name:(this._getName(vertex_index)) wirecolor:clr pos:pos

		this._setNewKnots(pos)(normal)

		this._setPivotToSecondPoint()

		this._alignObjectToVector knots_positions[1]

		this._createSupportLine(support_obj)

		--point_helpers = (HelperObject_v()).generatePoints(knots_positions)
		--
		--point_helpers[1].parent = source_obj
		--support_obj.parent = point_helpers[point_helpers.count]


		--support.parent = helpers_chain[helpers_chain.count]
		--
		--Options.setProp support #this (getHandleByAnim support)
		--
		--Options.setProp support #raft_mode raft_mode
		--
		--this.support_obj --return

		this --return
	),

	/** Update support
	 */
	function updateSupport pos: normal: =
	(
		--format "\n-----------------------------------------\n"
		--format "\n"; print "SupportObject_v.updateSupport()"
		--format "support_obj: %\n" support_obj
		--format "pos: %\n" pos
		--format "normal: %\n" normal
		this._resetKnots()

		this._setUpdatedKnots(pos)

		format "knots_positions.count: %\n" knots_positions.count

		this._setPivotToSecondPoint ()

		deleteSpline support_obj 1

		this._createSupportLine(support_obj)
	),


	private


	/** Create line netween point helpers
	  */
	function _createSupportLine spline_shape =
	(
		--format "\n"; print "SupportObject_v._createSupportLine()"
		--format "HELPERS_TREE: %\n" helpers_chain

		direction_down = [0,0,-1]


		addNewSpline spline_shape


		/*------------------------------------------------------------------------------
			ADD KNOTS BY POINTS FROM TOP TO BOTTOM
		--------------------------------------------------------------------------------*/
		for pos in knots_positions do
			addKnot spline_shape _spline_index #corner #line pos


		/*------------------------------------------------------------------------------
			GET POSITION OF LAST POINT ABOVE GROUND
		--------------------------------------------------------------------------------*/
		pos = copy knots_positions[knots_positions.count] -- copy to avoid modifing of value in array


		/*------------------------------------------------------------------------------
			TEST COLLISION WITH OBJECT
		--------------------------------------------------------------------------------*/
		collision_with_source_obj = this._intersectRaySourceObject pos direction_down

		this.is_on_ground = collision_with_source_obj == undefined


		/* IF SUPPORT IS GOING TO GROUND */
		if is_on_ground then
		(
			/*------------------------------------------------------------------------------
				ABOVE POINT ABOVE GROUND - NOT IF RAFT MODE
			--------------------------------------------------------------------------------*/
			pos.z = SUPPORT_OPTIONS.base_height -- set knot above ground to set base height and keep last segment straight for extrude

			addKnot spline_shape _spline_index #corner #line pos

			pos.z = 0 -- set spline_shape to ground

			/*------------------------------------------------------------------------------
				ADD GROUND POINT
			--------------------------------------------------------------------------------*/
			addKnot spline_shape _spline_index #corner #line pos

		)
		else /* IF SUPPORT IS INTERSECTING SOURCE OBJECT, THEN TURN SUPPORT TO RAFT */
		(
			--format "collision_with_source_obj: %\n" collision_with_source_obj
			pos.z = collision_with_source_obj.pos.z -- set knot above ground to set base height and keep last segment straight for extrude

			addKnot spline_shape _spline_index #corner #line pos
		)


		/*------------------------------------------------------------------------------
			SET MATERIALS TO SEGMENTS
		--------------------------------------------------------------------------------*/
		num_of_segments = numSegments spline_shape ( numSplines spline_shape)

		for segment_i = 1 to num_of_segments do
			setMaterialID spline_shape _spline_index segment_i SUPPORT_OPTIONS.mat_ids[#MIDDLE] -- setMaterialID <splineShape> <_spline_index> <seg_index> <matID>


		/*------ SET MATERIAL TO GROUND SEGMENT ------*/
		if is_on_ground then
			setMaterialID spline_shape _spline_index num_of_segments SUPPORT_OPTIONS.mat_ids[#BASE] -- setMaterialID <splineShape> <_spline_index> <seg_index> <matID>


		/*------------------------------------------------------------------------------
			RESULT
		--------------------------------------------------------------------------------*/
		updateShape spline_shape

		spline_shape --return
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SupportObject.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
