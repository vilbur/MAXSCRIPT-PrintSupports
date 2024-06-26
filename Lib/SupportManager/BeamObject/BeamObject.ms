/** Beam object
 */
struct BeamObject_v
(
	/* construct */
	support_A,
	support_B,

	/* required */
	/* properties */
	beam,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Create beams
	 */
	function createBeamsBetweenTwoSupports =
	(
		format "\n"; print "BeamObject_v._createBeamsBetweenTwoSupports()"
		/* CREATE NEW BEAM */
		--if beam == unsupplied then

		end_points = this._getBeamsEndPoints()
		format "end_points: %\n" end_points

		this._createBeam (support_A) (support_B) (end_points[1][#BOTTOM]) (end_points[1][#TOP])

		--	--if SUPPORT_OPTIONS.connect != 2 then
		--		--this._createBeam support_B support_A pos_bottom_2 pos_top_2

		this --return
	),

	/** Update beam
	 */
	function updateBeam =
	(
		--format "\n"; print "BeamObject_v.updateBeam()"

		end_points = this._getBeamsEndPoints()
		--format "END_POINTS: %\n" end_points

		if numSplines beam > 0 then
			deleteSpline beam 1

		if end_points[1] != undefined and end_points[2] != undefined   then
			this._drawLine (end_points[1][#BOTTOM]) (end_points[1][#TOP])
	),

	private

	/** Get beams end points
	 */
	function _getBeamsEndPoints =
	(
		--format "\n"; print "BeamObject_v.getBeamEndPoints()"
		/** Get posiotion of point on line
		 */
		function getPosOnLine direction point_data offset =
		(
			dir = if direction == #BOTTOM then -1 else 1

			point_data[direction]	+ ( offset	* point_data[#VECTOR] * dir)
		)

		--if same_height then
		--(
		--	/* GET BOTTOM POS WHICH IS UPPER */
		--	pos_bottom_1 = if pos_bottom_1.z > pos_bottom_2.z then pos_bottom_1 else pos_bottom_2
		--	pos_bottom_2 = if pos_bottom_1.z > pos_bottom_2.z then pos_bottom_1 else pos_bottom_2
		--
		--
		--	/* GET TOP POS WHICH IS LOWER */
		--	pos_top_1 = pos_top_2 = if pos_top_1.z > pos_top_2.z then pos_top_1 else pos_top_2
		--)
		--
		--this.support_A = support_A
		--this.support_B = support_B

		beams_created = #()

		if ( support_A == undefined or support_B == undefined ) or  distance support_A.pos support_B.pos > SUPPORT_OPTIONS.max_distance  then
			return beams_created

		point_data_A = this._getSegmentEndPoints(support_A)
		point_data_B = this._getSegmentEndPoints(support_B)


		length_A = distance point_data_A[#BOTTOM] point_data_A[#TOP]
		length_B = distance point_data_B[#BOTTOM] point_data_B[#TOP]

		if length_A < SUPPORT_OPTIONS.min_height and length_B < SUPPORT_OPTIONS.min_height then
			return beams_created

		/* DISTANCE FROM END POINTS */
		offset_A = length_A / SUPPORT_OPTIONS.connect -- Divide by 0|1|3 SUPPORT_OPTIONS.connect:radiobuttons items:#('END', 'MIDDLE', 'QUATER')
		offset_B = length_B / SUPPORT_OPTIONS.connect


		/* BEAM 1 */
		pos_bottom_1  	= getPosOnLine #BOTTOM	point_data_A offset_A
		pos_top_1	= getPosOnLine #TOP	point_data_B offset_B

		/* BEAM 2 */
		pos_bottom_2  	= getPosOnLine #BOTTOM	point_data_B offset_B
		pos_top_2	= getPosOnLine #TOP	point_data_A offset_A


		#(
			Dictionary #(#BOTTOM,	pos_bottom_1)	#(#TOP,	pos_top_1),
			Dictionary #(#BOTTOM,	pos_bottom_2)	#(#TOP,	pos_top_2)
		) -- return
	),


	/** Get segment point_data
	 */
	function _getSegmentEndPoints support =
	(
		--format "\n"; print "BeamObject_v.getSegmentEnds()"
		num_knots	= ( numKnots support )

		/* GET INDEX OF USED POINTS */
		index_bottom	= if ( numSegments support 1) == 1 then 2 else num_knots - 1 -- get second point or second point from end ( above ground point )
		index_top	= index_bottom - 1

		/* GET POSITIONS OF POINTS */
		point_bottom	= getKnotPoint support	1 index_bottom	-- get 2. point from bottom
		point_top	= getKnotPoint support	1 index_top	-- get 1. or 2. point from top

		Dictionary #( #BOTTOM, point_bottom ) #( #TOP, point_top ) #( #VECTOR, normalize (point_bottom - point_top) ) --return
	),

	/** Create beam
	 */
	function _createBeam support_A support_B pos_bottom pos_top =
	(
		--format "\n"; print "BeamObject_v._createBeam()"

		this.beam = SplineShape name:(support_A.name + "-beam") wirecolor:(this._shiftWirecolor(support_A.wirecolor) )

		beam = this._drawLine (pos_bottom) (pos_top)

		this._addToGroup (beam) (support_A)

		beam.parent	= support_A
		beam.pivot  = beam.center


		--SUPPORT_OPTIONS.setProp beam #THIS (getHandleByAnim beam)
		setUserPropVal beam "THIS"	(getHandleByAnim beam)

		--SUPPORT_OPTIONS.setProp beam #BEAM_SUPPORTS #( SUPPORT_OPTIONS.getThisPointer (support_A), SUPPORT_OPTIONS.getThisPointer (support_B) )
		setUserPropVal beam "support_A" ( getUserPropVal support_A "THIS" )
		setUserPropVal beam "support_B" ( getUserPropVal support_B "THIS" )

		/* COPY MODIFIERS OF PARENT SUPPORT NAME WHICH NAME IS MATCHING: "*BAR*" */
		for i = support_A.modifiers.count to 1 by -1 where matchPattern support_A.modifiers[i].name pattern:"*BAR*" do
			addModifier beam support_A.modifiers[i]

		/* GET DISTANCE BETWEEN POINTS */
		--distance_between_points = this.getPointDistance (copy beam_start) (copy beam_end_top )
		--distance_between_points = this.getPointDistance (point_bottom_1) (point_bottom_2 )

		/* CHECK MAX DISTANCE BETWEEN POINTS */
		--if distance_between_points < SUPPORT_OPTIONS.max_distance then
			--beam = this._drawLine (support_1) (beam_start) (beam_end_top)

		beam --return
	),

	/** Draw line
	 */
	function _drawLine start_point end_point =
	(
		--format "\n"; print "BeamObject_v.drawLine()"
		spline_id = 1 -- index of spline

		addNewSpline this.beam

		addKnot this.beam spline_id #corner #line start_point
		addKnot this.beam spline_id #corner #line end_point

		setMaterialID this.beam spline_id 1 SUPPORT_OPTIONS.mat_ids[#BEAM] -- setMaterialID <splineShape> <spline_index> <seg_index> <matID>

		updateShape this.beam


		--for i = support_A.modifiers.count to 1 by -1 do
		--	addModifier this.beam support_A.modifiers[i]

		this.beam --return
	),


	--/** Get distance between points in 2D FROM TOP VIEW
	--  */
	--function getPointDistance point_1 point_2 =
	--(
	--	--format "\n"; print "BeamObject_v.getPointDistance()"
	--	--point_1.z = point_2.z = 0 -- get distance in 2D -- COPY OF PARAMETERS IS NEEDED FOR THIS E.G.: point_1_copy = copy point_1
	--
	--	distance point_1 point_2 --return
	--),

	/** Filter edit spline objects
	  *
	  */
	function filterEditSplineObjects =
	(
		for support in supports where superClassOf support.baseobject == shape collect support
	),

	/** Sort supports by distance
	 */
	function sortSupportsByDistance =
	(
		format "\n"; print "BeamObject_v.sortSupportsByDistance()"

		supports_positions	= for support in supports collect support.pos
		proccessed_supports 	= #{1..supports.count} * #{}

		next_support_i	= 1
		supports_sorted = #(supports[next_support_i])

		while next_support_i != undefined do
		(
			min_distance = 9999999
			next_support	= supports[next_support_i]
			next_support_pos	= next_support.pos

			proccessed_supports[next_support_i]	= true

			next_support_i = undefined
			--supports_to_search = for i = 1 to supports.count where not proccessed_supports[i] collect i

			for i = 1 to supports.count where not proccessed_supports[i] do
			--if supports_to_search.count > 0 then
			(
				--for i in supports_to_search do
					if (dist = distance next_support_pos supports_positions[i] ) < min_distance then
					(
						min_distance = dist


						--proccessed_supports[i]	= true

						next_support_i = i
					)
			)
			--else
				--next_support_i = undefined

			if next_support_i != undefined then
				append supports_sorted supports[next_support_i]
		)

		--this.supports = makeUniqueArray supports_sorted
		this.supports = supports_sorted
	),






	/** Add to group
	 */
	function _addToGroup support point_helper =
	(
		/** Find group
		 */
		function _findGroup obj =
		(
			--format "\n"; print "SupportGenerator_v.findGroup()"

			if isGroupMember obj then
			(
				while not isGroupHead obj.parent do
					obj = obj.parent

				obj.parent --return
			)
		)

		--format "\n"; print "SupportGenerator_v.addToGroup()"
		if ( _group = _findGroup point_helper ) != undefined then
			attachNodesToGroup support _group
	),

	/** Shift wirecolor sligtly to +1 - Helper points are shifter -1
	  *
	  *
	  *
	  * Each level of points has different wirecolor for better selection
	  */
	function _shiftWirecolor wirecolor =
	(
		--format "\n"; print "PlatformGenerator_v.shiftWirecolor()"
		--format "WIRECOLOR:	% \n" wirecolor
		i = 1

		wirecolor_shifted = copy wirecolor

		if wirecolor_shifted.r <= 254 then wirecolor_shifted.r += i
		if wirecolor_shifted.g <= 254 then wirecolor_shifted.g += i
		if wirecolor_shifted.b <= 254 then wirecolor_shifted.b += i
		--format "WIRECOLOR_SHIFTED:	% \n" wirecolor_shifted

		wirecolor_shifted --return
	),







	/**
	 */
	on create do
	(
		format "\n"; print "BeamObject.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
