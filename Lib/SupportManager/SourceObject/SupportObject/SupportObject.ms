filein( getFilenamePath(getSourceFileName()) + "/../PointHelper/PointHelper.ms" )	--"./../PointHelper/PointHelper.ms"

/** Support object
 */
struct SupportObject_v
(
	/* construct */
	source_obj,

	/* required */


	/* properties */
	support_obj,

	is_on_ground = false,

	--knots_positions = #(),
	knots_positions = Array (2),

	PointHelpers = #(),

	Beams = #(),

	/* private */
	_spline_index = 1, -- each support line has ony 1 spline


	/* dependency */
	include "MAXSCRIPT-PrintSupports/Lib/SupportManager/SourceObject/SupportRaftBaseObject/SupportRaftBaseObject.ms" --"./../SupportRaftBaseObject/SupportRaftBaseObject.ms"

	/* reference */
	/* inhered */

	/** Generate support
	 */
	function generateSupport vert pos: clr: normal: =
	(
		format "\n"; print "SupportObject_v.generateSupport()"
		--this.raft_mode = raft_mode


		--format "SUPPORT_OPTIONS: %\n" SUPPORT_OPTIONS

		--(PointHelper_v()).generatePointHelpers(vert)

		--this.support_obj = SplineShape name:(this._getName()) wirecolor:(this._shiftWirecolor(clr)(vert) ) pos:knots_positions[1]
		this.support_obj = SplineShape name:(this._getName()) wirecolor:clr pos:pos

		this._setNewSupportKnots(pos)(normal)

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
		format "\n"; print "SupportObject_v.updateSupport()"
		format "support_obj: %\n" support_obj
		format "pos: %\n" pos
		format "normal: %\n" normal


		this._setUpdateSupportKnots(pos)
		
		deleteSpline support_obj 1

		this._createSupportLine(support_obj)


		----for _spline_index = 1 to numSplines support_obj do
		--for knot_i = 2 to numKnots support_obj 1 do
		--	getKnotPoint spl s k
		--setKnotPoint support_obj 1 1 pos

		--this._createSupportLine(support_obj)

		--updateShape support_obj

	),


	private


	/** Create line netween point helpers
	  */
	function _createSupportLine spline_shape =
	(
		format "\n"; print "SupportObject_v._createSupportLine()"
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
		support_hits_source_object = this._testCollision pos direction_down

		this.is_on_ground = support_hits_source_object == undefined


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
			format "support_hits_source_object: %\n" support_hits_source_object
			pos.z = support_hits_source_object.pos.z -- set knot above ground to set base height and keep last segment straight for extrude

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

	/** Set knots positions
	 */
	function _setNewSupportKnots pos normal =
	(
		format "\n"; print "SupportObject_v._setNewSupportKnots()"
		format "NORMAL: %\n" normal

		/** Set second point by normal of vertex
		 */
		function setSecondByNormal pos _normal =
		(
			format "\n"; print "HelperObject_v.setSecondByNormal()"

			/** Get ray to ground
			 */
			--function getRayToGround second_vert_pos = Ray second_vert_pos [0,0,-1]

			local second_vert_pos = copy pos

			/* MOVE SECOND POINT ALONG NORMAL OF FIRST POINT */
			second_vert_pos += SUPPORT_OPTIONS.normal_length * _normal

			/* EXTEND SECOND POINT ALONG NORMAL IF INTERSECT WITH OBJECT ON ITS WAY TO TTHE GROUND */
			--while (intersection = intersectRay source_obj (getRayToGround(second_vert_pos))) != undefined do
			--	second_vert_pos += SUPPORT_OPTIONS.bar_width * _normal
			--
			--/* MOVE SECOND POINT LITTLE MORE TO MAKE SURE THAT IT NOT COLLIDE WITH OBJECT */
			--second_vert_pos += SUPPORT_OPTIONS.bar_width * _normal


			/* KEEP SECOND POINT BELLOW FIRST OF GIVEN AMOUNT */
			--if SUPPORT_OPTIONS.keep_down and ( second_vert_pos.z - second_vert_pos.z ) < 0 then
				--second_vert_pos.z = pos.z - SUPPORT_OPTIONS.keep_down_limit

			second_vert_pos --return
		)

		/** Set second down
		 */
		function setSecondDown pos =
		(
			--format "\n"; print "HelperObject_v.setSecondDown()"
			pos.z -= SUPPORT_OPTIONS.normal_length

			--append this.knots_positions pos
			pos --return
		)



		/* ADD FIRST POINT */
		knots_positions[1] = pos

		/* ADD SECOND POINT */
		second_point_pos = case SUPPORT_OPTIONS.second_point_direction of
		(
			1: setSecondByNormal	(copy pos)( normal )
			2: setSecondDown	(copy pos)
		)

		/* CHECK POSITION ABOVE GROUND, POINT IS NOT CRETED IF BOTTOM SPACE IS NOT 2x BASE HEIGH */
		if second_point_pos != undefined and second_point_pos.z >= SUPPORT_OPTIONS.base_height * 2 then
			knots_positions[2] = second_point_pos

		format "knots_positions: %\n" knots_positions
	),

	/** Set update support knots
	 */
	function _setUpdateSupportKnots pos =
	(
		--format "\n"; print "SupportObject_v._setUpdateSupportKnots()"

		mat_of_last_segment = getMaterialID support_obj _spline_index ( numSegments support_obj _spline_index )

		knots_count = numKnots support_obj _spline_index

		is_on_ground = mat_of_last_segment == SUPPORT_OPTIONS.mat_ids[#BASE]

		last_knot = if is_on_ground then knots_count - 2 else knots_count

		knots_positions = #(pos) -- set first knot of spline to vertex position

		for knot_i = 2 to last_knot do
			append knots_positions (getKnotPoint support_obj _spline_index knot_i)

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
