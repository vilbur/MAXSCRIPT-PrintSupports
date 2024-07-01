
	/*------------------------------------------------------------------------------
		PROPERTIES
	--------------------------------------------------------------------------------*/

	public

	/* construct */
	source_obj,

	/* required */


	/* properties */
	support_obj,

	knots_positions = Array (2),

	private

	_spline_index = 1, -- each support line has ony 1 spline

	hit_source_object,
	/*------------------------------------------------------------------------------
		METHODS
	--------------------------------------------------------------------------------*/
	/** Reset knots
	 */
	function _resetKnots =
	(
		this.knots_positions = Array (2)
	),

	/** Set knots positions
	 */
	function _setNewKnots pos normal =
	(
		format "\n"; print "SupportRaftBaseObject._setNewKnots()"
		format "NORMAL: %\n" normal

		--/** Set second point by normal of vertex
		-- */
		--function setSecondByNormal pos _normal =
		--(
		--	format "\n"; print "SupportRaftBaseObject.setSecondByNormal()"
		--
		--	/** Get ray to ground
		--	 */
		--	this.hit_source_object = this._intersectRaySourceObject pos _normal
		--
		--	second_vert_pos = if hit_source_object != undefined -- if source object has been intersected
		--					  and ( this.is_raft               -- if raft, then use position of hit always
		--					  or distance hit_source_object.pos knots_positions[1] < normal_length ) -- if support, then distance between 1st knot and hit must be greather then normlal length
		--	then
		--		hit_source_object.pos
		--
		--	else
		--		/* MOVE SECOND POINT ALONG NORMAL OF FIRST POINT */
		--		pos + SUPPORT_OPTIONS.normal_length * _normal
		--
		--	--local second_vert_pos = copy pos
		--
		--
		--	/* EXTEND SECOND POINT ALONG NORMAL IF INTERSECT WITH OBJECT ON ITS WAY TO TTHE GROUND */
		--	--while (intersection = intersectRay source_obj (getRayToGround(second_vert_pos))) != undefined do
		--	--	second_vert_pos += SUPPORT_OPTIONS.bar_width * _normal
		--	--
		--	--/* MOVE SECOND POINT LITTLE MORE TO MAKE SURE THAT IT NOT COLLIDE WITH OBJECT */
		--	--second_vert_pos += SUPPORT_OPTIONS.bar_width * _normal
		--
		--
		--	/* KEEP SECOND POINT BELLOW FIRST OF GIVEN AMOUNT */
		--	--if SUPPORT_OPTIONS.keep_down and ( second_vert_pos.z - second_vert_pos.z ) < 0 then
		--		--second_vert_pos.z = pos.z - SUPPORT_OPTIONS.keep_down_limit
		--	format "second_vert_pos: %\n" second_vert_pos
		--	second_vert_pos --return
		--)
		--
		--/** Set second down
		-- */
		--function setSecondDown pos =
		--(
		--	--format "\n"; print "SupportRaftBaseObject.setSecondDown()"
		--	pos.z -= SUPPORT_OPTIONS.normal_length
		--
		--	--append this.knots_positions pos
		--	pos --return
		--)

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

		--format "knots_positions: %\n" knots_positions
	),

	/** Set update support knots
	 */
	function _setUpdatedKnots pos =
	(
		--function getNumKnots = numKnots support_obj _spline_index
		knots_positions = #(pos) -- set first knot of spline to vertex position

		last_knot_pos = getKnotPoint support_obj _spline_index 2

		hit_source_object = this._intersectRaySourceObject pos ( normalize (last_knot_pos - pos))

		second_vert_pos = if hit_source_object != undefined then hit_source_object.pos else last_knot_pos

		append knots_positions second_vert_pos
	),

	/** Align to ctor
	 */
	function _alignObjectToVector point_to_rotate =
	(
		--format "\n"; print "SupportRaftBaseObject._alignObjectToVector()"
		--format "obj	= % \n" obj
		--format "% %\n" point_to_rotate obj_pos

		dir = normalize (support_obj.pos - point_to_rotate)
		--format "dir: %\n" dir

		axis = #z

		vec = case axis of
		(
			#x: support_obj.transform[1]
			#y: support_obj.transform[2]
			#z: support_obj.transform[3]
		)

		tm  = support_obj.transform
		vec = normalize vec
		dir = normalize dir

		angle_vectors = acos (dot vec dir) -- get angle between

		axis_of_plane_defined_by_vectors = normalize (cross dir vec)

		rtm = AngleAxis (angle_vectors) ( axis_of_plane_defined_by_vectors )

		--support_obj.transform = Translate ( Rotate ( ScaleMatrix tm.scale) (tm.rotation*rtm)) tm.pos
		--
		--if pos == true then
		--	support_obj.pos = point_to_rotate
		support_obj.pivot = Translate ( Rotate ( ScaleMatrix tm.scale) (tm.rotation*rtm)) tm.pos

		--if pos == true then
			--support_obj.pos = point_to_rotate

	),

	/** Set pivot to position
	 */
	function _setPivotToSecondPoint =
	(
		--format "\n"; print "SupportRaftBaseObject._alignObjectToVector()"
		support_obj.pivot = knots_positions[2]
	),

	/** Test collision with source object
	 */
	function _intersectRaySourceObject pos direction =
	(
		--format "\n"; print "SupportRaftBaseObject.testCollision()"
		--format "pos: %\n" pos
		/** Modify pos
		 */
		function modifyPos _pos axis val =
		(
			--format "\n"; print ".modifyPos()"
			_pos = copy _pos

			_pos[axis] += val

			_pos --return
		)

		local hit_result

		half_of_bar_width = SUPPORT_OPTIONS.bar_width / 2


		bar_bbox = #(
			modifyPos pos 1 half_of_bar_width,
			modifyPos pos 1 (half_of_bar_width * -1),
			modifyPos pos 2 half_of_bar_width,
			modifyPos pos 2 (half_of_bar_width * -1),
			pos
		)
		--format "bar_bbox: %\n" bar_bbox

		for pos in bar_bbox do
			if ( hit = intersectRay source_obj ( Ray pos direction) ) != undefined then
				hit_result = copy hit


		hit_result --return
	),

	/*------------------------------------------------------------------------------

		HELPERS

	--------------------------------------------------------------------------------*/

	/** Get name
	 */
	function _getName vertex_index =
	(
		--format "\n"; print "SupportRaftBaseObject._getName()"

		support_name = substituteString source_obj.name "-source" ""

		if not matchPattern support_name pattern:("*-support*") then
			support_name += "-support"
		--support_name + "-support-" + vertex_index as string -- + "-" + index as string
		support_name += "-"+ vertex_index as string

		support_name --return
	),

	/** Shift wirecolor sligtly
	  * Each level of points has different wirecolor for better selection
	  */
	function _shiftWirecolor wirecolor i =
	(
		--format "\n"; print "SupportRaftBaseObject.shiftWirecolor()"
		--format "wirecolor:	% \n" wirecolor
		wirecolor_shifted = copy wirecolor


		if wirecolor_shifted.r >= abs i then wirecolor_shifted.r -= i
		if wirecolor_shifted.g >= abs i then wirecolor_shifted.g -= i
		if wirecolor_shifted.b >= abs i then wirecolor_shifted.b -= i
		--format "wirecolor_shifted:	% \n" wirecolor_shifted

		wirecolor_shifted --return
	),

	public