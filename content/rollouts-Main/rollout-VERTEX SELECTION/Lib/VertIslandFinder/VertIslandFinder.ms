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

			--if layer == 78 then
				--format "VERTS_IN_LAYER 78: %\n" verts_in_layer

			/* JOIN NEW FACES TO ALL NEW_ISLANDS */
			timer_JOIN = timeStamp()

			new_islands_in_layer = this._joinFacesToIslands(new_faces_in_layer)(verts_in_layer)layer
			--this._joinVertsToIslands(new_faces_in_layer)


			if new_islands_in_layer.count > 0 then
			(
				for new_island in new_islands_in_layer do
				(
					island_data = Dictionary()

					--island_data[#NEW_ISLAND] = new_island
					island_data[#NEW_ISLAND] = (new_island * verts_in_layer)

					island_data[#BOTTOM] = layer


					--if layer == 78 then
					--(
						--format "********************************\n"
						--format "NEW_ISLAND: %\n" new_island
						--format "ISLAND_DATA: %\n" island_data
					--)

					append islands_data island_data
				)

				join this.islands_cache new_islands_in_layer

				this._mergeIslandsBySharedVerts(layer)
			)

			faces_processed += faces_in_layer
			verts_processed += verts_in_layer

			gc light:true
		)

		format "\n------\n\n"
		format "ALL_LAYERS_TIMER: % seconds\n" ((( timeStamp()) - all_layers_timer) / 1000.0)


		--for i = 1 to islands_data[#BOTTOM].count do
		--(
		--	format "\n-----------------------------------------------\n"
		--	--format "\n% %: %" islands_data[#BOTTOM][i] islands_data[#HEIGHTS][i] islands_data[#VERTS][i]
		--	format "#ISLAND: %\n" islands_data[#NEW_ISLANDS][i]
		--	format "#LAYER: %\n"  islands_data[#BOTTOM] [i]
		--	format "#HEIGHT: %\n" islands_data[#HEIGHTS][i]
		--	format "#VERTS: %\n"  islands_data[#VERTS][i]
		--
		--)



		--huge_new_islands = for i = 1 to new_islands_heights.count where new_islands_heights[i] != undefined and new_islands_heights[i] > 100 collect islands_data[#NEW_ISLANDS][i]

		format "\n******************************************************************************\n"
		--format "islands_data[#BOTTOM] .count: %\n" islands_data[#BOTTOM] .count
		--format "islands_data[#HEIGHTS].count: %\n" islands_data[#HEIGHTS].count

		--format "NEW_ISLANDS_HEIGHTS: %\n" new_islands_layers
		--format "HUGE_NEW_ISLANDS: %\n" huge_new_islands

		this.islands_data --return
	),

	/** Join faces to islands
	 */
	function _joinFacesToIslands new_faces_in_layer verts_in_layer layer =
	(
		--format "\n"; print "VertIslandFinder_v._joinFacesToIslands()"

		layer_verts_processed	= #{}

		new_islands_in_layer = #()

		--if layer == 78 then
		--	format "NEW_FACES_IN_LAYER: %\n" new_faces_in_layer

		for face in new_faces_in_layer do
		(
			faceverts = polyop.getVertsUsingFace obj #(face)


			merged = false

			/* MERGE FACE TO ISLANDS */
			for i = 1 to islands_cache.count while not merged where not ((islands_cache[i]) * faceverts ).isEmpty do
			--for i = 1 to islands_cache.count while not merged where ((islands_cache[i]) * faceverts ).numberSet > 1 do
			--for i = 1 to islands_cache.count while not merged where (islands_cache[i] * verts_in_layer ).numberSet > 1 do
			(
				merged = true

				islands_cache[i] += faceverts
			)

			/* CREATE NEW ISLAND IF NOT MERGED */
			if not merged then
				append new_islands_in_layer faceverts
		)


		if new_islands_in_layer.count > 0 then
		(
			new_islands_in_layer = this._mergeBitArraysbySharedBits(new_islands_in_layer)


			/* REMOVE ISLANDS THEY ARE NOT IN VERTS PROCESS - HOTFIX */
			for i = new_islands_in_layer.count to 1 by -1 where (new_islands_in_layer[i] * verts_process).isEmpty do deleteItem new_islands_in_layer i

			join islands_cache new_islands_in_layer

			--if layer == 78 then
			--format "\n\n RESULT: NEW_ISLANDS_IN_LAYER: %\n" new_islands_in_layer

		)

		new_islands_in_layer --return
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


	/** Merge bit arrays wich shared bits
	  *
	  * @param #( #{} ) bitarrays Array of bittarays
	 */
	function _mergeIslandsBySharedVerts current_layer =
	(

		--format "\n"; print ".mergeBitArraysTest2()"

		--if new_islands_heights.count < islands_data[#NEW_ISLANDS].count then


		for x = islands_cache.count to 1 by -1 do
		(
			merged = false

			island_x = islands_cache[x]


			--for y = islands_cache.count to 1 by -1 while not merged where x != y and not ( island_x * islands_cache[y] ).isEmpty do
			for y = islands_cache.count to 1 by -1 while not merged where x != y and ( island_x * islands_cache[y] ).numberSet > 1 do
			(
				islands_cache[y] += island_x

				merged = true


				for i = 1 to islands_data.count where islands_data[i][#TOP] == undefined and not (islands_data[i][#NEW_ISLAND] * island_x).isEmpty do
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
	function _mergeBitArraysbySharedBits bitarrays =
	(
		--format "\n"; print "VertSelector_v._mergeBitArraysbySharedBits()"

		for x = bitarrays.count to 1 by -1 do
		(
			--format "x: %\n" x
			merged = false

			bitarrays_x = bitarrays[x]
			--for y = bitarrays.count to 1 by -1 while where x != y and not ( bitarrays_x * bitarrays[y] ).isEmpty do
			--for y = bitarrays.count to 1 by -1 where x != y and not ( bitarrays_x * bitarrays[y] ).isEmpty do

			--for y = bitarrays.count to 1 by -1 where x != y and ( bitarrays_x * bitarrays[y] ).numberSet > 1 do
			for y = bitarrays.count to 1 by -1 while not merged where x != y and ( bitarrays_x * bitarrays[y] ).numberSet > 1 do
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
