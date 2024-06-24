filein( getFilenamePath(getSourceFileName()) + "/../PointHelper/PointHelper.ms" )	--"./../PointHelper/PointHelper.ms"

/** Support object
 */
struct RaftObject_v
(
	/*------ EXTENDS  ------*/
	include "MAXSCRIPT-PrintSupports/Lib/SupportManager/SourceObject/SupportRaftBaseObject/SupportRaftBaseObject.ms" --"./../SupportRaftBaseObject/SupportRaftBaseObject.ms"


	/* properties */
	--support,

	--knots_positions = #(),
	--knots_positions = Array (2),

	PointHelpers = #(),

	Beams = #(),

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Generate support
	 */
	function generateSupport vert pos: clr: normal:[0,0,-1] =
	(
		format "\n"; print "RaftObject_v.generateSupport()"

		this.support_obj = SplineShape name:(this._getName(vertex_index)) wirecolor:clr pos:pos

		this._setNewRaftKnots(pos)(normal)

		support_obj.pivot = knots_positions[2]

		this._alignObjectToVector support_obj knots_positions[1]

		this._createRaftLine(support_obj)

		--support.parent = helpers_chain[helpers_chain.count]
		--
		--Options.setProp support #this (getHandleByAnim support)
		--
		--Options.setProp support #raft_mode raft_mode
		--
		this --return
	),

	/** Update support
	 */
	function updateSupport pos: normal: =
	(
		--format "\n-----------------------------------------\n"
		--format "\n"; print "RaftObject_v.updateSupport()"
		--format "support_obj: %\n" support_obj
		--format "pos: %\n" pos
		--format "normal: %\n" normal

		this._setUpdateRaftKnots(pos)

		support_obj.pivot = knots_positions[2]

		deleteSpline support_obj 1

		this._createRaftLine(support_obj)
	),

	private

	/** Create line netween point helpers
	  */
	function _createRaftLine spline_shape =
	(
		--format "\n"; print "RaftObject_v._createSupportLine()"

		direction_down = [0,0,-1]

		addNewSpline spline_shape

		/*------------------------------------------------------------------------------
			ADD KNOTS BY POINTS FROM TOP TO BOTTOM
		--------------------------------------------------------------------------------*/
		for pos in knots_positions do
			addKnot spline_shape _spline_index #corner #line pos

		/*------------------------------------------------------------------------------
			RESULT
		--------------------------------------------------------------------------------*/
		updateShape spline_shape

		spline_shape --return
	),

	/** Set knots positions
	 */
	function _setNewRaftKnots pos normal =
	(
		format "\n"; print "RaftObject_v._setNewRaftKnots()"
		format "NORMAL: %\n" normal

		/** Set second point by normal of vertex
		 */
		function setSecondByNormal pos _normal =
		(
			format "\n"; print "HelperObject_v.setSecondByNormal()"

			/** Get ray to ground
			 */
			--function getRayToGround second_vert_pos = Ray second_vert_pos [0,0,-1]
			collision_with_source_obj = this._intersectRaySourceObject pos _normal

			second_vert_pos = if collision_with_source_obj == undefined then
			(
				/* MOVE SECOND POINT ALONG NORMAL OF FIRST POINT */
				pos + SUPPORT_OPTIONS.normal_length * _normal

			)
			else
				collision_with_source_obj.pos

			--local second_vert_pos = copy pos


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
	function _setUpdateRaftKnots pos =
	(
		--function getNumKnots = numKnots support_obj _spline_index
		knots_positions = #(pos) -- set first knot of spline to vertex position

		last_knot_pos = getKnotPoint support_obj _spline_index 2

		collision_with_source_obj = this._intersectRaySourceObject pos ( normalize (last_knot_pos - pos))

		second_vert_pos = if collision_with_source_obj != undefined then collision_with_source_obj.pos else last_knot_pos

		append knots_positions second_vert_pos
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "RaftObject.onCreate()"
	)
)