
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

	is_on_ground	= false,

	private

	_spline_index = 1, -- each support line has ony 1 spline

	hit_source_object,

	direction_down = [0,0,-1],


	public


	/** Generate support
	 */
	function generateSupport vertex_index pos: clr: normal: =
	(
		--format "\n"; print "SupportObject_v.generateSupport()"

		--this.support_obj = SplineShape name:(this._getName()) wirecolor:(this._shiftWirecolor(clr)(vertex_index) ) pos:knots_positions[1]
		this.support_obj = SplineShape name:(this._getName(vertex_index)) wirecolor:clr pos:pos

		this._setNewKnots(pos)(normal)
		--format "knots_positions.count: %\n" knots_positions.count

		this._createSupportObject()

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
		this.hit_source_object = undefined

		this._setUpdatedKnots(vertex_pos)

		this._createSupportObject update:true
	),


	private


	/*------------------------------------------------------------------------------
		METHODS
	--------------------------------------------------------------------------------*/
	/** Reset knots
	 */
	function _resetKnots =
	(
		this.knots_positions = Array (2)
	),


	/** Draw segments support
	 */
	function _createSupportObject update:false =
	(
		format "\n"; print "SupportObject_v._createSupportObject()"
		if knots_positions.count > 1 then
		(
			this._setPivotToSecondPoint()

			if update then
				deleteSpline support_obj 1
			--else
				--this._alignObjectToVector knots_positions[1]

			this._drawNeckLine()

			if hit_source_object == undefined and is_raft == undefined then
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