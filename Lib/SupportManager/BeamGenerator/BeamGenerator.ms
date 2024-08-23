/** Beam generator
 */
struct BeamGenerator_v
(
	/* construct */
	/* required */
	/* properties */
	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Generate beam
	 */
	function generateBeam support_A support_B =
	(
		--format "\n"; print "BeamGenerator_v.generateBeam()"
		BeamObject = (BeamObject_v support_A support_B )

		/* IF BEAM DOES NOT EXISTS YET */
		--if SUPPORT_MANAGER.BeamObjects[BeamObject.beam_key] == undefined then
		--(
			BeamObject.generateBeam()

			BeamObject.beam_key = this._getBeamKey (support_A) (support_B)

			/* SAVE SYNC KEY */
			setUserPropVal BeamObject.beam "SYNC_KEY" ( getUserPropVal support_A "SYNC_KEY" )
			setUserPropVal BeamObject.beam "BEAM_KEY"  BeamObject.beam_key

			setUserPropVal BeamObject.beam "SUPPORT_A" ( this._getSupportKey(support_A) )
			setUserPropVal BeamObject.beam "SUPPORT_B" ( this._getSupportKey(support_B) )

			/* ADD TO BEAMS */
			SUPPORT_MANAGER.BeamObjects[BeamObject.beam_key] = BeamObject

			--append new_beams BeamObject.beam

			--format "BeamObject.beam: %\n" BeamObject.beam
			BeamObject.beam --return
		--)
	),

	/** Generate beams chain
	 */
	function generateBeamsChain supports max_distance =
	(
		format "\n"; print "BeamGenerator_v.generateBeamsChain()"
		new_beams = #()

		supports = this._sortSupportsByDistance(supports) (max_distance)

		for supports_in_cluster in sorted_supports do
			format "SUPPORTS_IN_CLUSTER %: %\n" supports_in_cluster.count supports_in_cluster

		for supports_in_cluster in supports do
			for i = 1 to supports_in_cluster.count - 1 do
				append new_beams (this.generateBeam supports_in_cluster[i] supports_in_cluster[i + 1])

		new_beams --return
	),

	/** Generate beams to closest supports
	 */
	function generateBeamsToClosestSupports supports =
	(
		format "\n"; print ".generateBeamsToClosestSupports()"
		procesed_supports = #()
		new_beams = #()

		--_objects = selection as Array

		source_objects = SUPPORT_MANAGER.getObjectsByType ( supports ) type:#SOURCE -- hierarchy:shift
		format "source_objects: %\n" source_objects

		supports = SUPPORT_MANAGER.getObjectsByType supports type:#SUPPORT

		--format "supports.count: %\n" supports.count
		--beams = SUPPORT_MANAGER.getObjectsByType supports type:#BEAM

		supports_all = SUPPORT_MANAGER.getObjectsByType source_objects type:#SUPPORT
		--format "supports_of_beams.count: %\n" supports_of_beams.count
		format "supports_all: %\n" supports_all

		for support in supports where findItem procesed_supports support == 0 do
		(
			local closest_support

			min_distance = 9999999

			for support_other in supports_all where support_other != support and ( dist = distance support support_other ) < min_distance and not this.beamExists support support_other do
			(
				min_distance = dist

				closest_support = support_other
				--format "CLOSEST_SUPPORT: %\n" closest_support

				if findItem supports support_other > 0 then
					appendIfUnique procesed_supports support

			)

			if closest_support != undefined then
				if (new_beam = this.generateBeam support closest_support) != undefined then
					append new_beams new_beam

		)

		new_beams --return
	),


	private


	/** connected with beams
	 */
	function beamExists support_A support_B =
	(
		SUPPORT_MANAGER.BeamObjects[this._getBeamKey support_A support_B] != undefined
	),

	/** Get beam key
	 */
	function _getBeamKey support_A support_B =
	(
		--format "\n"; print "SupportManager_v.getBeamKey()"
		pointers = sort #( this._getSupportKey(support_A) , this._getSupportKey(support_B) )

		( pointers[1] + "x" + pointers[2] ) --return
	),

	/** Get support key
	 */
	function _getSupportKey support =
	(
		--format "\n"; print "BeamObject_v._getSupportKey()"
		getUserPropVal support "SUPPORT_KEY"
	),

	/** Sort supports by distance
	  * Return arrays of supports sorted by closest distance.
	  * Each array contains supports which are close enought to thmeselfs.
	  *
	  * Max distance of supports is set in SUPPORT_OPTIONS.max_distance
	  *
	  * @return 2D array
	 */
	function _sortSupportsByDistance supports max_distance =
	(
		format "\n"; print "SupportManager_v.sortSupportsByDistance()"
		format "use_max_distance: %\n" use_max_distance
        sorted_all = #()
		cluster    = #()

        proccessed_supports	= #{}

        /* SET FIRST SUPPORT INDEX */
        support_i	= 1

		while support_i != undefined do
		(
			min_distance_found = 9999999

			/* GET SUPPORT NODE AND POSITION */
            support     = supports[support_i]
            support_pos = support.pos

			/* AVOID TESTING SUPPORT AGAIN */
            proccessed_supports[support_i] = true

			support_i      = undefined
			next_support_i = undefined

			--format "SUPPORT_OPTIONS.max_distance: %\n" SUPPORT_OPTIONS.max_distance
			/*------------------------------------------------------------------------------
				LOOP SUPPORTS AND FIND CLOSEST SUPPORT
			--------------------------------------------------------------------------------*/
			for i = 1 to supports.count where not proccessed_supports[i] do
			(
				--format "distance: %\n" (distance support_pos supports[i].pos)
				if (current_distance = distance support_pos supports[i].pos ) < min_distance_found then
					--if not use_max_distance or current_distance <= SUPPORT_OPTIONS.max_distance  then
					if current_distance <= max_distance  then
					(
						min_distance_found = current_distance

						next_support_i = i
					)
			)

			/*------------------------------------------------------------------------------
				ADD SUPPORTS TO CLUSTER IF NEXT SUPPORT FOUND
			--------------------------------------------------------------------------------*/
			if next_support_i != undefined then
			(
				if cluster.count == 0 then -- create new cluster
					cluster = #(support)

				append cluster supports[next_support_i]

				support_i = next_support_i
			)
			/*------------------------------------------------------------------------------
				IF NEXT SUPPORT CLOSE ENOUGHT IS NOT FOUND
			--------------------------------------------------------------------------------*/
			else
			(
				/* ADD CLUSTER TO SORTED SUPPORTS */
				if cluster.count > 0 then
					append sorted_all cluster

				cluster = #()
			)

			/*------------------------------------------------------------------------------
				GET NEXT NOT TESTED SUPPORT
			--------------------------------------------------------------------------------*/

			if support_i == undefined then
				for i = 1 to supports.count where not proccessed_supports[i] do
					if support_i == undefined then
						support_i = i
		)

		sorted_all -- return
	),

	--/** Get beam key
	-- */
	--function getBeamKey =
	--(
	--	--format "\n"; print "SupportManager_v.getBeamKey()"
	--	pointers = sort #( this._getSupportKey(support_A) , this._getSupportKey(support_B) )
	--
	--	( pointers[1] + "x" + pointers[2] ) --return
	--),

	/**
	 */
	on create do
	(
		--format "\n"; print "BeamGenerator.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)