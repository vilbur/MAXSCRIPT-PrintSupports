
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

	--private

	_spline_index = 1, -- each support line has ony 1 spline

	/*------------------------------------------------------------------------------
		METHODS
	--------------------------------------------------------------------------------*/

	/** Align to ctor
	 */
	function _alignObjectToVector obj point_to_rotate =
	(
		--format "\n"; print "HelperObject_v._alignObjectToVector()"
		--format "obj	= % \n" obj
		--format "% %\n" point_to_rotate obj_pos

		dir = normalize (obj.pos - point_to_rotate)
		--format "dir: %\n" dir

		axis = #z

		vec = case axis of
		(
			#x: obj.transform[1]
			#y: obj.transform[2]
			#z: obj.transform[3]
		)

		tm  = obj.transform
		vec = normalize vec
		dir = normalize dir

		angle_vectors = acos (dot vec dir) -- get angle between

		axis_of_plane_defined_by_vectors = normalize (cross dir vec)

		rtm = AngleAxis (angle_vectors) ( axis_of_plane_defined_by_vectors )

		obj.transform = Translate ( Rotate ( ScaleMatrix tm.scale) (tm.rotation*rtm)) tm.pos

		if pos == true then
			obj.pos = point_to_rotate
	),

	/** Test collision with source object
	 */
	function _intersectRaySourceObject pos direction =
	(
		--format "\n"; print "SupportObject_v.testCollision()"
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
		--format "\n"; print "HelperObject_v._getName()"

		support_name = substituteString source_obj.name "-source" ""

		if not matchPattern support_name pattern:("*-support*") then
			support_name += "-support"
		--support_name + "-support-" + vertex_index as string -- + "-" + index as string

		support_name --return
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

	public