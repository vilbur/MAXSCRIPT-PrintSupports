filein( getFilenamePath(getSourceFileName()) + "/../PointHelper/PointHelper.ms" )	--"./../PointHelper/PointHelper.ms"

/** Support object
 */
struct RaftObject_v
(
	/* construct */
	source_obj,

	/* required */


	/* properties */
	support,

	--knots_positions = #(),
	knots_positions = Array (2),

	PointHelpers = #(),

	Beams = #(),

	--normal = [0,0,-1],

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Generate support
	 */
	function generateRaft vert pos: clr: normal:[0,0,-1] =
	(
		format "\n"; print "RaftObject_v.generateSupport()"
		this.raft_mode = raft_mode


		--format "SUPPORT_OPTIONS: %\n" SUPPORT_OPTIONS

		--(PointHelper_v()).generatePointHelpers(vert)

		----this.support = SplineShape name:(this._getName()) wirecolor:(this._shiftWirecolor(clr)(vert) ) pos:knots_positions[1]
		--this.support = SplineShape name:(this._getName()) wirecolor:clr pos:pos
		--
		--if not raft_mode then
		--	this._createSupportLine(support)
		--else
		--	this._createRaftLine(support)

		--support.parent = helpers_chain[helpers_chain.count]
		--
		--Options.setProp support #this (getHandleByAnim support)
		--
		--Options.setProp support #raft_mode raft_mode
		--
		--this.support_obj --return
	),


	private


	/** Set knots positions
	 */
	function _setSupportKnots pos normal =
	(
		format "\n"; print "RaftObject_v._setSupportKnots()"
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


		this._setSupportKnots(pos)(normal)

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

	/** Create line netween point helpers
	  */
	function _createSupportLine spline_shape =
	(
		format "\n"; print "RaftObject_v._createSupportLine()"
		--format "HELPERS_TREE: %\n" helpers_chain
		direction_down = [0,0,-1]

		spline_index = 1

		addNewSpline spline_shape

		--support_hits_source_object = this._testCollision knots_positions[1] [0,0,-1]
		--format "SOURCE_OBJ_INTERSECTION: %\n" support_hits_source_object

		/*------------------------------------------------------------------------------
			ADD KNOTS BY POINTS FROM TOP TO BOTTOM
		--------------------------------------------------------------------------------*/
		for pos in knots_positions do
			addKnot spline_shape spline_index #corner #line pos

		/* GET POSITION OF LAST POINT ABOVE GROUND */
		pos =  knots_positions[knots_positions.count]

		/* IF SUPPORT IS GOING TO GROUND */
		if ( support_hits_source_object = this._testCollision pos direction_down ) == undefined then
		(
			/*------------------------------------------------------------------------------
				ABOVE POINT ABOVE GROUND - NOT IF RAFT MODE
			--------------------------------------------------------------------------------*/

			pos.z = SUPPORT_OPTIONS.base_height -- set knot above ground to set base height and keep last segment straight for extrude

			addKnot spline_shape spline_index #corner #line pos

			pos.z = 0 -- set spline_shape to ground

			/*------------------------------------------------------------------------------
				GROUND POINT
			--------------------------------------------------------------------------------*/
			addKnot spline_shape spline_index #corner #line pos

		)
		else /* IF SUPPORT IS INTERSECTING SOURCE OBJECT, THEN TURN SUPPORT TO RAFT */
		(
			format "support_hits_source_object: %\n" support_hits_source_object

			this.raft_mode = true

			pos.z = support_hits_source_object.pos.z -- set knot above ground to set base height and keep last segment straight for extrude

			addKnot spline_shape spline_index #corner #line pos
		)

		/*------ SET MATERIAL TO SEGMENTS ------*/
		num_of_segments = numSegments spline_shape ( numSplines spline_shape)

		for segment_i = 1 to num_of_segments do
			setMaterialID spline_shape spline_index segment_i SUPPORT_OPTIONS.mat_ids[#MIDDLE] -- setMaterialID <splineShape> <spline_index> <seg_index> <matID>

		/*------ SET MATERIAL TO BOTTOM SEGMENT ------*/

		setMaterialID spline_shape spline_index num_of_segments SUPPORT_OPTIONS.mat_ids[#BASE] -- setMaterialID <splineShape> <spline_index> <seg_index> <matID>

		updateShape spline_shape

		spline_shape --return
	),

	/** Create raft line
	 */
	function _createRaftLine =
	(
		--format "\n"; print "RaftObject_v._createRaftLine()"

		--setMaterialID spline_shape spline_index 1 SUPPORT_OPTIONS.mat_ids[#MIDDLE] -- setMaterialID <splineShape> <spline_index> <seg_index> <matID>

	),

	/** Test collision with source object
	 */
	function _testCollision pos direction =
	(
		format "\n"; print "RaftObject_v.testCollision()"

		_ray = Ray pos direction

		intersectRay source_obj _ray --return
	),

	/*------------------------------------------------------------------------------

		HELPERS

	--------------------------------------------------------------------------------*/

	/** Get name
	 */
	function _getName =
	(
		--format "\n"; print "HelperObject_v._getName()"

		name_stripped = substituteString source_obj.name "-source" ""

		name_stripped + "-support-" + vertex_index as string -- + "-" + index as string
	),

	/** Shift wirecolor sligtly
	  * Each level of points has different wirecolor for better selection
	  */
	function _shiftWirecolor wirecolor i =
	(
		--format "\n"; print "PlatformGenerator_v.shiftWirecolor()"
		--format "wirecolor:	% \n" wirecolor
		wirecolor_shifted = copy wirecolor


		if wirecolor_shifted.r >= abs i then wirecolor_shifted.r -= i
		if wirecolor_shifted.g >= abs i then wirecolor_shifted.g -= i
		if wirecolor_shifted.b >= abs i then wirecolor_shifted.b -= i
		--format "wirecolor_shifted:	% \n" wirecolor_shifted

		wirecolor_shifted --return
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "RaftObject.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
