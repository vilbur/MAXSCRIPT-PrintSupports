/** Ver island finder

	1) Loop each layer
	2) Get verts in each layer
	3) Find how many mesh island exsits


	4) Test if new or old island - in old, then faces exist in all island

 */
struct VertIslandFinder_v
(
	/* construct */
	obj,

	/* required */

	/* properties */
	verts_process	= #{},
	verts_all	= #{},

	face_islands	= #(),
	verts_layers	= #(),	-- each item is BitArray of verts in layer
	verts_above	= #{},	-- store verts above last layer, or not yet iterated layers
	verts_processed	= #{},

	islands_data	= #(),
	islands_cache	= #(),
	faces_processed	= #{},

	/* private */
	/* dependency */
	/* reference */
	/* inhered */
	layer_height,

	/** GET NEW NEW_ISLANDS PER LAYER
	  *
	  * Loop each print layer and search for new islands_cache
	  *
	  * This method is usefel up to 100k vertex count, higher vertex count is slow
	  * Use lots of RAM memory
	  *
	  * @return #( #{ verts of new islands_cache } )
	 */
	function getNewIslandsPerLayer =
	(
		format "\n"; print "VertIslandFinder_v.getNewIslandsPerLayer()"

		format "verts_process.count: %\n" verts_process.count
		--format "layers_count: %\n" layers_count
		--verts_processed = #{}

		--this.empty_bitarray = verts_all * #{}

		if verts_above.isEmpty then
			verts_above = copy verts_all

		layers_with_verts = for layer_index = 1 to verts_layers.count where classOf ( verts_in_layer = verts_layers[layer_index] ) == BitArray collect layer_index -- layer has not verts if item is integer ( layer number )

		used_layers_count = layers_with_verts.count

		all_layers_timer = timeStamp()

		format "\nSTART GETTING ISLANDS\n"

		for l = 1 to used_layers_count do
		--for layer in layers_with_verts do -- layer has not verts if item is integer ( layer number )
		(
			--format "layer: %\n" layer
			--format "\n==============================\nlayer: %\n" layer
			if mod l 100 == 0 then (

				format "\n"
				format "layer: % of: %\n" l used_layers_count

				--format "islands_cache.count: %\n" islands_cache.count
				layer_timer = timeStamp()
			)

			layer = layers_with_verts[l]

			/* GET VERTS IN LAYER */
			verts_in_layer = verts_layers[layer]

			/* REMOVE VERTS FORM CURENT LAYER FROM VERTS ABOVE */
			verts_above  -= verts_in_layer

			/* GET ALL FACES IN LAYER */
			faces_in_layer = polyop.getFacesUsingVert obj verts_in_layer

			/* GET ONLY NEW FACES IN LAYER - avoid repetion of faces across layers */
			new_faces_in_layer = faces_in_layer - faces_processed

			/* JOIN NEW FACES TO ALL NEW_ISLANDS */
			timer_JOIN = timeStamp()

			new_islands = this._joinFacesToIslands(new_faces_in_layer)(verts_in_layer)layer
			--this._joinVertsToIslands(new_faces_in_layer)

			/* IF NEW ISLANDS FOUND */
			if new_islands.count > 0 then
			(
				if new_islands.count > 1 then
				(
					/* MERGE NEW ISLANDS BY VERTS - new islands can be splitten  */
					new_islands = this._mergeNewIslandsBySharedBits(new_islands)

					--for new_island in new_islands do
					--	format "new_island: %\n" new_island

					/* MERGE NEW ISLANDS BY FACES  */
					new_islands = this._mergeIslandsBySharedFaces(new_islands) verts_in_layer
				)

				/* ADD NEW ISLANDS TO OTHER ISLANDS */
				join islands_cache new_islands

				/* TRY MERGE ALL ISALNDS - islands can be joined by new faces in layer */
				this._mergeIslandsBySharedVerts(layer)

				this._addIslandDataToNewIslands(new_islands)(verts_in_layer)(layer)
			)

			faces_processed += faces_in_layer
			verts_processed += verts_in_layer

			gc light:true
		)

		format "\n------\n\n"
		format "islands_data.count: %\n" islands_data.count
		format "ALL_LAYERS_TIMER: % seconds\n" ((( timeStamp()) - all_layers_timer) / 1000.0)

		this.islands_data --return
	),

	/** Join faces to islands
	 */
	function _joinFacesToIslands new_faces_in_layer verts_in_layer layer =
	(
		--format "\n"; print "VertIslandFinder_v._joinFacesToIslands()"
		layer_verts_processed	= #{}
		faceverts_processed	= #{}

		new_islands = #()

		faceverts_in_layer = for face in new_faces_in_layer collect polyop.getVertsUsingFace obj #(face)

		/* SEARCH FOR NEW ISLANDS */
		for faceverts in faceverts_in_layer do
		(
			merged = false

			/* TRY MERGE FACE TO EXISTING ISlANDS */
			for y = 1 to islands_cache.count while not merged                                                  \
				where ( connecting_verts = this._bitsAreShared islands_cache[y] faceverts more_bits_then:0 ) != false \
				and this._bitsAreShared -verts_above connecting_verts != false \
				do
			(
				--print "MERGE"
				merged = true

				islands_cache[y] += faceverts
			)

			/* ADD FACE AS NEW ISLAND IF NOT MERGED */
			if not merged then
			(
				if this._bitsAreShared verts_process faceverts != false then
					/* ADD NEW ISLAND */
					append new_islands faceverts
				else
					/* ADD TO OTHER ISLANDS IF VERTS ARE NOT MEANT TO BE PROCESED - E.g.: if faces are on top side of object */
					append islands_cache faceverts
			)
		)

		new_islands --return
	),

	/** Merge islands by shared faces
	  *
	  * FIX:       2 VERTS on one edge problem
	  * CASED BY: Single island with mutliple faces can by divided by face which is not recognized as face of new island
	  *
	 */
	function _mergeIslandsBySharedFaces new_islands verts_in_layer =
	(
		--format "\n"; print "VertIslandFinder_v._mergeIslandsBySharedFaces()"
		--faces_islands = for new_island in new_islands collect polyop.getFacesUsingVert obj (new_island)
		faces_islands = for new_island in new_islands collect polyop.getFacesUsingVert obj (new_island * verts_in_layer )

		for x = faces_islands.count to 1 by -1 do
		(
			merged = false

			faces_island_x = faces_islands[x]
			new_island_x   = new_islands[x]

			/* MERGE ISLANDS IF SHARE FACE */
			for y = faces_islands.count to 1 by -1 while not merged where x != y and this._bitsAreShared faces_island_x faces_islands[y] more_bits_then:0 != false do
			(
				merged = true

				--if new_island_x[25] or new_islands[y][25] then
				--(
				--	format "\nMERGE ISLANDS\n"
				--	format "new_island_x: %\n" new_island_x
				--	format "new_islands[y]: %\n" new_islands[y]
				--	format "\n"
				--	format "faces_island_x: %\n" faces_island_x
				--	format "faces_islands[y]: %\n" faces_islands[y]
				--
				--)


				faces_islands[y] += faces_island_x
				new_islands[y]   += new_island_x

				deleteItem faces_islands x
				deleteItem new_islands x
			)
		)

		new_islands --return
	),

	/** Merge bit arrays wich shared bits
	  *
	  * @param #( #{} ) bitarrays Array of bittarays
	 */
	function _mergeIslandsBySharedVerts current_layer =
	(
		/* LOOP EACH NEW ISLAND */
		for x = islands_cache.count to 1 by -1 do
		(
			merged = false

			island_x = islands_cache[x]

			for y = islands_cache.count to 1 by -1 while not merged where x != y and this._bitsAreShared islands_cache[y] island_x more_bits_then:1 != false do
			(
				islands_cache[y] += island_x

				merged = true

				for i = 1 to islands_data.count where islands_data[i][#TOP] == undefined and this._bitsAreShared islands_data[i][#NEW_ISLAND] island_x != false  do
				(
					if current_layer != islands_data[i][#BOTTOM] then
					(
						--format "islands_data[#BOTTOM][i]: %\n" islands_data[#BOTTOM][i]
						islands_data[i][#TOP] = current_layer

						islands_data[i][#WHOLE_ISLAND] = island_x
					)

				)

				deleteItem islands_cache x
			)
		)
	),

	/** Merge bit arrays wich shared bits
	  *
	  * @param #( #{} ) bitarrays Array of bittarays
	 */
	function _mergeNewIslandsBySharedBits bitarrays =
	(
		--format "\n"; print "VertSelector_v._mergeNewIslandsBySharedBits()"

		for x = bitarrays.count to 1 by -1 do
		(
			--format "x: %\n" x
			merged = false

			bitarrays_x = bitarrays[x]

			--for y = bitarrays.count to 1 by -1 while not merged where x != y and ( bitarrays_x * bitarrays[y] ).numberSet > 0 do
			for y = bitarrays.count to 1 by -1 while not merged where x != y and this._bitsAreShared bitarrays_x bitarrays[y] more_bits_then:1 != false  do
			(
				bitarrays[y] += bitarrays[x]

				merged = true

				--gc light:true
			)

			if merged then
				deleteItem bitarrays x
		)

		bitarrays --return
	),

	/** Add island data to neww islands
	 */
	function _addIslandDataToNewIslands new_islands verts_in_layer layer =
	(
		--format "\n"; print "VertIslandFinder_v._addIslandDataToNewIslands()"
		for new_island in new_islands do
		(
			island_data = Dictionary()

			island_data[#NEW_ISLAND] = (new_island * verts_in_layer)

			island_data[#BOTTOM] = layer

			append islands_data island_data
		)
	),

	/** Test if bitarrays share bits
	 */
	function _bitsAreShared arr_A arr_B more_bits_then:0 =
	(
		if ( intersection = ( arr_A * arr_B ) ).numberSet > more_bits_then then
			intersection --return
		else
			false --return
	),

	/** Bitarrays match
	 */
	function _bitsAreSharedSearch haystack needle =
	(
		--format "\n"; print "VertIslandFinder_v.bitarraysMatch()"
		found = false

		for vert in needle while not found where haystack[vert] do found = true

		found --return
	),

	/** Test new islands
	 */
	function _testNewIslands =
	(
		format "\n"; print "VertIslandFinder_v._testNewIslands()"
		--for x = islands_data.count to 1 by -1 do
		--(
		--	--format "x: %\n" x
		--
		--	island_data = islands_data[x][#NEW_ISLAND]
		--
		--		--format "island_data: %\n" island_data
		--	--if island_data != undefined then
		--
		--
		--		for y = islands_data.count to 1 by -1 where x != y and ( island_data * islands_data[y][#NEW_ISLAND] ).numberSet > 0 do
		--		(
		--			format "\n\n=========================\n"
		--			format "x: % \ny: %\n\n" x y
		--			format "NEW_ISLAND: %\n" islands_data[y][#NEW_ISLAND]
		--		)
		--		--else
		--		--(
		--		--	format "\n\n=========================\n"
		--		--	format "UNDEFINED: %\n" x
		--		--)
		--	gc light:true
		--
		--)

		for island_data in islands_data do
			format "island_data[#NEW_ISLAND]: %\n" island_data[#NEW_ISLAND]

	),

	/** Set vertex color to new islands
	 */
	function _setVertexColorToNewIslands =
	(
		--format "\n"; print "VertIslandFinder_v.setVertexColorToNewIslands()"
		obj.showVertexColors	= true
		obj.vertexColorsShaded	= true

		polyop.setVertColor obj.baseobject 0 this.verts_all white

		for merged_island in this.merged_islands  do
		(
			format "merged_island: %\n" merged_island

			polyop.setVertColor obj.baseobject 0 (merged_island) green
		)


		--for new_island in this.islands_data[#NEW_ISLANDS]  do
		----for new_island in this.islands_data[#NEW_ISLANDS]  do
		--(
		--	polyop.setVertColor obj.baseobject 0 (new_island) red
		--
		--	this._getCenterOfIsland (new_island)
		--)

	),

	/** Get first layer
	 */
	function _getFirstLayerIslands =
	(
		format "\n"; print "VertIslandFinder_v._getFirstLayer()"
		for layer = 1 to verts_layers.count where classOf ( verts_in_layer = verts_layers[layer] ) == BitArray and not ( verts_in_layer * verts_process ).isEmpty  do -- layer has not verts if item is integer ( layer number )
		(
			faces_in_layer = polyop.getFacesUsingVert obj verts_in_layer
			format "faces_in_layer: %\n" faces_in_layer
			this.faces_processed += faces_in_layer


			this.islands_cache = this.getVertexIslands ( polyop.getVertsUsedOnlyByFaces obj faces_in_layer)
			--this.islands_cache = this.getVertexIslands ( polyop.getVertsUsingFace obj faces_in_layer)

			return layer
		)

	),

	/** Set verts processed
	 */
	function setVertsProcessed verts =
	(
		--format "\n"; print "VertIslandFinder_v.setVertsProcessed()"
		this.islands_cache = this.getVertexIslands (verts)
	),

	/** Set verts processed
	 */
	function getVertexIslands verts =
	(
		--format "\n"; print "VertIslandFinder_v.getVertexIslands()"
		--verts_processed = verts
		--
		----faceverts = for face_id in faces_of_verts collect ( polyop.getVertsUsingFace obj face_id )
		--
		--islands_cache = this._sortVertsByIslands( polyop.getFacesUsingVert obj verts_processed
		islands = #()

		--verts_used = copy verts
		--face_verts = polyop.getVertsUsingFace obj face

		--vertex_count = getNumVerts obj.mesh
		--format "vertex_count: %\n" vertex_count
		--
		--all_verts = #{1..(vertex_count)}

		--faces_sel = polyop.getFaceSelection obj
		--format "faces_sel: %\n" faces_sel
		--/*------ SPLIT TO NEW_ISLANDS ------*/
		--verts_sel = polyop.getVertsUsingFace obj faces_sel
		--format "verts_sel: %\n" verts_sel

		while not verts.isEmpty do
		(
			faces_of_vert = polyop.getFacesUsingVert obj (verts as Array )[1]

			verts_of_faces = polyop.getVertsUsingFace obj faces_of_vert
			format "verts_of_faces: %\n" verts_of_faces
			verts_of_faces -= this.verts_above

			append islands verts_of_faces

			verts -= verts_of_faces
		)

		this._mergeIslandsBySharedVerts(islands) --return

		--islands --return
	),

	/** Get center of island
	 */
	function _getCenterOfIsland verts =
	(
		--format "\n"; print "VertIslandFinder_v.getCenterOfIsland()"

		pos_center = point3 0 0 0

		positions = in coordsys world meshop.getVerts obj.mesh verts node:obj


		for pos in positions do pos_center += pos

		pos_center /= positions.count

		_Point = Point pos:pos_center size:5 wirecolor:red

		_Point.parent = obj

	),



	private

	/** Get face layers
	 */
	function getFaceLayers faces_in_layer =
	(
		--format "\n"; print "VertIslandFinder_v.getFaceLayers()"
	),





	/**
	 */
	on create do
	(
		--format "\n"; print "VertIslandFinder.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
