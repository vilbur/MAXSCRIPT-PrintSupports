filein( getFilenamePath(getSourceFileName()) + "/../PointHelper/PointHelper.ms" )	--"./../PointHelper/PointHelper.ms"

/** Support object
 */
struct RaftObject_v
(
	/*------ EXTENDS  ------*/
	include "MAXSCRIPT-PrintSupports/Lib/SupportManager/SourceObject/SupportRaftBaseObject/SupportRaftBaseObject.ms" --"./../SupportRaftBaseObject/SupportRaftBaseObject.ms"

	/* properties */
	is_raft	= true,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	--/** Generate support
	-- */
	--function generateSupport vert pos: clr: normal:[0,0,-1] =
	--(
	--	format "\n"; print "RaftObject_v.generateSupport()"
	--
	--	this.support_obj = SplineShape name:(this._getName(vertex_index)) wirecolor:clr pos:pos
	--
	--	this._setNewKnots(pos)(normal)
	--
	--
	--	--this._alignObjectToVector knots_positions[1]
	--
	--	this._createSupportObject()
	--
	--	--support.parent = helpers_chain[helpers_chain.count]
	--	--
	--	--Options.setProp support #this (getHandleByAnim support)
	--	--
	--	--Options.setProp support #raft_mode raft_mode
	--	--
	--	this --return
	--),
	--
	--/** Update support
	-- */
	--function updateSupport vertex_pos: normal: =
	--(
	--	--format "\n-----------------------------------------\n"
	--	--format "\n"; print "RaftObject_v.updateSupport()"
	--	--format "support_obj: %\n" support_obj
	--	--format "pos: %\n" pos
	--	--format "normal: %\n" normal
	--	this._resetKnots()
	--
	--	this._setUpdatedKnots(vertex_pos)
	--
	--	this._setPivotToSecondPoint()
	--
	--	--deleteSpline support_obj 1
	--
	--	this._createSupportObject update:true
	--),

	private

	/** Set knots positions
	 */
	function _setNewKnots vertex_pos normal =
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

	--/** Create line netween point helpers
	--  */
	--function _createRaftLine update:false =
	--(
	--	--format "\n"; print "RaftObject_v._createSupportLine()"
	--
	--	if knots_positions.count > 1 then
	--	(
	--		this._setPivotToSecondPoint()
	--
	--		if update then
	--			deleteSpline support_obj 1
	--		--else
	--			--this._alignObjectToVector knots_positions[1]
	--
	--		this._drawNeckLine()
	--
	--		--if hit_source_object == undefined then
	--			--this._drawLegLine()
	--
	--		this._setMaterialsToLineSegments()
	--
	--		updateShape support_obj
	--	)
	--),

	/**
	 */
	on create do
	(
		--format "\n"; print "RaftObject.onCreate()"
	)
)




































