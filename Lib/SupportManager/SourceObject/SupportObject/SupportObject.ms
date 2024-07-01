filein( getFilenamePath(getSourceFileName()) + "/../PointHelper/PointHelper.ms" )	--"./../PointHelper/PointHelper.ms"

/** Support object
 */
struct SupportObject_v
(

	/*------ EXTENDS  ------*/
	include "MAXSCRIPT-PrintSupports/Lib/SupportManager/SourceObject/SupportRaftBaseObject/SupportRaftBaseObject.ms" --"./../SupportRaftBaseObject/SupportRaftBaseObject.ms"

	/* properties */
	is_on_ground	= false,
	is_raft	= false,

	--knots_positions = #(),
	--knots_positions = Array (2),

	--Beams = #(),

	/* private */
	direction_down = [0,0,-1],

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

		this._setNewKnotsSupport(pos)(normal)
		--format "knots_positions.count: %\n" knots_positions.count

		this._drawSupportSegments()

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
	function updateSupport vertex_pos: normal: =
	(
		--format "\n"; print "SupportObject_v.updateSupport()"

		this._resetKnots()

		this.is_on_ground = false

		this._setUpdatedKnotsSupport(vertex_pos)

		this._drawSupportSegments update:true
	),


	private

	/** Set knots positions
	 */
	function _setNewKnotsSupport vertex_pos normal =
	(
		format "\n"; print "SupportRaftBaseObject._setNewKnots()"
		format "NORMAL: %\n" normal

		/* ADD FIRST POINT */
		knots_positions[1] = vertex_pos
		knots_positions[2] = vertex_pos

		direction = if SUPPORT_OPTIONS.second_point_direction == 2 then direction_down else normal

		hit_source_object = this._intersectRaySourceObject (vertex_pos) (direction)

		if hit_source_object != undefined and distance knots_positions[1] hit_source_object.pos > SUPPORT_OPTIONS.normal_length then
			hit_source_object = undefined


		/* ADD SECOND POINT */
		if hit_source_object != undefined
		then /* SECOND POINT IS POINT OF COLLISION */
			knots_positions[2] = hit_source_object.pos

		else /* EXTEND SECOND POINT ALONG NORMAL */
			knots_positions[2] = knots_positions[2] + SUPPORT_OPTIONS.normal_length * direction

		--/* CHECK POSITION ABOVE GROUND, POINT IS NOT CRETED IF BOTTOM SPACE IS NOT 2x BASE HEIGH */
		--if second_point_pos != undefined and second_point_pos.z >= SUPPORT_OPTIONS.base_height * 2 then
		--	knots_positions[2] = second_point_pos

		--format "knots_positions: %\n" knots_positions
	),

	/** Set update support knots
	 */
	function _setUpdatedKnotsSupport vertex_pos =
	(
		--function getNumKnots = numKnots support_obj _spline_index
		knots_positions[1] = vertex_pos
		knots_positions[2] = getKnotPoint support_obj _spline_index 2

		direction = normalize (knots_positions[2] - vertex_pos)

		hit_source_object = this._intersectRaySourceObject (vertex_pos) ( direction )

		if hit_source_object != undefined and distance knots_positions[1] hit_source_object.pos > distance knots_positions[1] knots_positions[2] then
			hit_source_object = undefined

		/* ADD SECOND POINT */
		if hit_source_object != undefined then
			knots_positions[2] = hit_source_object.pos
	),

	/** Draw segments support
	 */
	function _drawSupportSegments update:false =
	(
		--format "\n"; print "SupportObject_v._drawSupportSegments()"
		if knots_positions.count > 1 then
		(
			this._setPivotToSecondPoint()

			if update then
				deleteSpline support_obj 1
			--else

			this._drawNeckLine()

				--this._alignObjectToVector knots_positions[1]

			if hit_source_object == undefined then
				this._drawLegLine()

			this._setMaterialsToLineSegments()

			updateShape support_obj
		)
	),

	/** Create line
	  */
	function _drawNeckLine =
	(
		--format "\n"; print "SupportObject_v._drawNeckLine()"
		--format "HELPERS_TREE: %\n" helpers_chain

		addNewSpline support_obj

		/*------------------------------------------------------------------------------
			ADD KNOTS BY POINTS FROM TOP TO BOTTOM
		--------------------------------------------------------------------------------*/
		for pos in knots_positions do
			addKnot support_obj _spline_index #corner #line pos
	),

	/** Draw leg line
	 */
	function _drawLegLine =
	(
		--format "\n"; print "SupportObject_v._drawLegLine()"
		/*------------------------------------------------------------------------------
			GET POSITION OF LAST POINT ABOVE GROUND
		--------------------------------------------------------------------------------*/
		pos = copy knots_positions[knots_positions.count] -- copy to avoid modifing of value in array

		/*------------------------------------------------------------------------------
			TEST COLLISION WITH OBJECT on straight down direction
		--------------------------------------------------------------------------------*/
		this.hit_source_object = this._intersectRaySourceObject pos direction_down


		this.is_on_ground = hit_source_object == undefined

		/* IF SUPPORT IS GOING TO GROUND */
		if is_on_ground then
		(
			/*------------------------------------------------------------------------------
				ABOVE POINT ABOVE GROUND - NOT IF RAFT MODE
			--------------------------------------------------------------------------------*/
			pos.z = SUPPORT_OPTIONS.base_height -- set knot above ground to set base height and keep last segment straight for extrude

			addKnot support_obj _spline_index #corner #line pos

			pos.z = 0 -- set support_obj to ground

			/*------------------------------------------------------------------------------
				ADD GROUND POINT
			--------------------------------------------------------------------------------*/
			addKnot support_obj _spline_index #corner #line pos
		)
		else /* IF SUPPORT IS INTERSECTING SOURCE OBJECT, THEN ADD POINT TO INETSECTION */
		(
			--format "hit_source_object: %\n" hit_source_object
			--pos.z = hit_source_object.pos.z -- set knot above ground to set base height and keep last segment straight for extrude

			--addKnot support_obj _spline_index #corner #line pos
			addKnot support_obj _spline_index #corner #line hit_source_object.pos
		)
	),

	/** Set materials to line segments
	 */
	function _setMaterialsToLineSegments =
	(
		--format "\n"; print "SupportObject_v._setMaterialsToLineSegments()"
		num_of_segments = numSegments support_obj ( numSplines support_obj)

		for segment_i = 1 to num_of_segments do
			setMaterialID support_obj _spline_index segment_i SUPPORT_OPTIONS.mat_ids[#MIDDLE] -- setMaterialID <splineShape> <_spline_index> <seg_index> <matID>

		/*------ SET MATERIAL TO GROUND SEGMENT ------*/
		if is_on_ground then
			setMaterialID support_obj _spline_index num_of_segments SUPPORT_OPTIONS.mat_ids[#BASE] -- setMaterialID <splineShape> <_spline_index> <seg_index> <matID>
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
