


	private

	/** Test collision with source object
	 */
	function _testCollision pos direction =
	(
		--format "\n"; print "SupportObject_v.testCollision()"
		_ray = Ray pos direction
	
		intersectRay source_obj _ray --return
	),

	/*------------------------------------------------------------------------------

		HELPERS

	--------------------------------------------------------------------------------*/

	/** Get name
	 */
	function _getName vertex_index =
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

	public