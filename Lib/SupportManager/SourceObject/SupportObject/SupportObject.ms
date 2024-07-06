/** Support object
 */
struct SupportObject_v
(
	/* construct */
	source_obj,

	is_raft,

	/* required on load from scene */
	support_obj,

	/* properties */

	knots_positions = Array (2),

	is_on_ground	= false,


	private

	_spline_index = 1, -- each support line has ony 1 spline

	hit_source_object,

	direction_down = [0,0,-1],


	public


	/** Generate support
	 */
	function generateSupport vertex_index first_knot_pos: clr: direction: =
	(
		--format "\n"; print "SupportObject_v.generateSupport()"
		this.support_obj = SplineShape name:(this._getName(vertex_index)) wirecolor:clr first_knot_pos:first_knot_pos

		this._setNewKnots(first_knot_pos)(direction)

		this._createSupportObject()

		this --return
	),

	/** Update support
	 */
	function updateRotation first_knot_pos: =
	(
		format "\n"; print "SupportObject_v.updateRotation()"

		this._resetThisObject()

		this._setUpdatedKnots(first_knot_pos)

		this._createSupportObject update:true
	),

	/** Update supports position
	 */
	function updatePosition first_knot_pos: =
	(
		--format "\n"; print "SupportObject_v.updatePosition()"
		this._resetThisObject()

		this._setUpdatedKnots(first_knot_pos)

		this._createSupportObject update:true

	),

	/** Update support height
	 */
	function updateHeight =
	(
		format "\n"; print "SupportObject_v.updateHeight()"
		ground_knot	= numKnots support_obj _spline_index
		base_knot	= ground_knot - 1

		ground_knot_pos	= getKnotPoint support_obj _spline_index ground_knot
		base_knot_pos	= getKnotPoint support_obj _spline_index base_knot


		ground_knot_pos.z	= 0
		base_knot_pos.z	= SUPPORT_OPTIONS.base_height


		setKnotPoint support_obj _spline_index ground_knot	ground_knot_pos
		setKnotPoint support_obj _spline_index base_knot	base_knot_pos

		updateShape support_obj
	),


	private


	/** Set knots positions
	 */
	function _setNewKnots vertex_pos direction =
	(
		--format "\n"; print "SupportRaftBaseObject._setNewKnots()"
		--format "DIRECTION: %\n" direction
		--format "normal_length: %\n" SUPPORT_OPTIONS.normal_length

		limit_height_to_base = SUPPORT_OPTIONS.base_height * 1.3 -- z pozition preserved for base points

		/* ADD FIRST POINT */
		knots_positions[1] = vertex_pos


		/* TEST COLLISTION WITH SOURCE OBJECT FOR 2nd POINT */
		hit_source_object = this._intersectRaySourceObject (vertex_pos) (direction)


		/* RESET COLLISION IF DISTANCE TO HIT IS GRTEATER THEN NORMAL - only for support */
		if not is_raft and hit_source_object != undefined and distance knots_positions[1] hit_source_object.pos > SUPPORT_OPTIONS.normal_length then
			hit_source_object = undefined


		/* ADD SECOND POINT */
		if hit_source_object != undefined
		then /* SECOND POINT IS POINT OF COLLISION */
			second_point_pos = hit_source_object.pos

		else /* EXTEND SECOND POINT ALONG NORMAL */
			second_point_pos = vertex_pos +( SUPPORT_OPTIONS.normal_length * direction)


		/* CHECK POSITION ABOVE GROUND, SET LAST KNOT ABOVE BASE */
		if not this.is_raft and second_point_pos.z < limit_height_to_base then
		(
			normal_length = abs ((vertex_pos.z - limit_height_to_base ) / direction.z)

			second_point_pos = vertex_pos + ( normal_length * direction)
		)


		/* ADD 2nd POINT */
		knots_positions[2] = second_point_pos
	),

	/** Set update support knots
	 */
	function _setUpdatedKnots vertex_pos =
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
	function _createSupportObject update:false =
	(
		--format "\n"; print "SupportObject_v._createSupportObject()"
		if knots_positions.count > 1 then
		(
			this._setPivotToSecondPoint()

			if update then
				deleteSpline support_obj 1
			--else
				--this._alignObjectToVector knots_positions[1]

			this._drawRaftLine()

			if is_raft == false and hit_source_object == undefined then
				this._drawSupportLine()

			this._setMaterialsToLineSegments()

			updateShape support_obj
		)
	),

	/** Create line
	  */
	function _drawRaftLine =
	(
		--format "\n"; print "SupportObject_v._drawRaftLine()"
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
	function _drawSupportLine =
	(
		--format "\n"; print "SupportObject_v._drawSupportLine()"
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
				POINT ABOVE GROUND - NOT IF RAFT MODE
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
		--if is_on_ground != undefined and is_on_ground then
		if is_on_ground then
			setMaterialID support_obj _spline_index num_of_segments SUPPORT_OPTIONS.mat_ids[#BASE] -- setMaterialID <splineShape> <_spline_index> <seg_index> <matID>
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

	/** Reset knots
	 */
	function _resetThisObject=
	(
		this.knots_positions = Array (2)

		this.is_on_ground = false

		this.hit_source_object = undefined
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

	/**
	 */
	on create do
	(
		--format "\n"; print "SupportObject.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
