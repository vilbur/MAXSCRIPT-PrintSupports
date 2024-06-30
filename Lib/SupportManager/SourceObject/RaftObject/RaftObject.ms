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

		this._setNewKnots(pos)(normal)

		this._setPivotToSecondPoint()

		this._alignObjectToVector knots_positions[1]

		this._createRaftLine()

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
		this._resetKnots()

		this._setUpdatedKnots(pos)

		this._setPivotToSecondPoint()

		deleteSpline support_obj 1

		this._createRaftLine(support_obj)
	),

	private

	/** Create line netween point helpers
	  */
	function _createRaftLine =
	(
		--format "\n"; print "RaftObject_v._createSupportLine()"

		direction_down = [0,0,-1]

		addNewSpline support_obj

		/*------------------------------------------------------------------------------
			ADD KNOTS BY POINTS FROM TOP TO BOTTOM
		--------------------------------------------------------------------------------*/
		for pos in knots_positions do
			addKnot support_obj _spline_index #corner #line pos

		/*------------------------------------------------------------------------------
			RESULT
		--------------------------------------------------------------------------------*/
		updateShape support_obj

		support_obj --return
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "RaftObject.onCreate()"
	)
)