filein( getFilenamePath(getSourceFileName()) + "/../../../MAXSCRIPT-MaxToPrint/content/rollouts-Main/rollout-VERTEX COLORS/Lib/VertexColorProcessor.ms" )	--"./../../../MAXSCRIPT-MaxToPrint/content/rollouts-Main/rollout-VERTEX COLORS/Lib/VertexColorProcessor.ms"

filein( getFilenamePath(getSourceFileName()) + "/../VertexColors/VertexColors.ms" )	--"./../VertexColors/VertexColors.ms"

filein( getFilenamePath(getSourceFileName()) + "/onSupportTransformCallback/onSupportTransformCallback.ms" )	--"./onSupportTransformCallback/onSupportTransformCallback.ms" -- MUST BE BEFORE SourceObject.ms
filein( getFilenamePath(getSourceFileName()) + "/onBeamDeletedCallback/onBeamDeletedCallback.ms" )	--"./onBeamDeletedCallback/onBeamDeletedCallback.ms" -- MUST BE BEFORE SourceObject.ms
filein( getFilenamePath(getSourceFileName()) + "/onEvents/onSourceObjectTransform/onSourceObjectTransform.ms" )	--"./onEvents/onSourceObjectTransform/onSourceObjectTransform.ms"

filein( getFilenamePath(getSourceFileName()) + "/../SupportOptions/SupportOptions.ms" )	--"./../SupportOptions/SupportOptions.ms"

filein( getFilenamePath(getSourceFileName()) + "/SourceObject/SourceObject.ms" )	--"./SourceObject/SourceObject.ms"

filein( getFilenamePath(getSourceFileName()) + "/BeamObject/BeamObject.ms" )	--"./BeamObject/BeamObject.ms"

filein( getFilenamePath(getSourceFileName()) + "/SupportModifiers/SupportModifiers.ms" )	--"./SupportModifiers/SupportModifiers.ms"


/** Support manager
  *
  *  DESCRIPTION OF SUPPORT SYSTEM:
  *			• Objects are linked for easy manipulation. LINK IS NOT REQUIRED
  *
  *			• Objects are linked via user data. Data are saved on: Source object, Master Point, Support|Raft,
  *					Master Point know source object
  *					Support|Raft know source object
  *					Beams knows his 2 supports
  *
  *
  *  HIERARCHY OF OBJECTS:
  *
  *		1) SOURCE OBJECT: Mesh object from which are support points generated. Parent of all objects:
  *					// Used vertices  1) SELECTED verts 2) ALL vertex with colors if nothing selected 3) ALL vertices if selection and colors not exists
  *
  * 			2) MASTER POINT ON TOP OF PLAFTORM - Dispalyed as: #BOX and #CROSS - Main point synced with source object by user prop data.
  *					//  Master poin knows which source object and vert has been used.
  *
  * 				3) NORMAL POINT - Dispalyed as: #BOX : Point aligned with source vertex normal
  *
  * 					3) OTHER POINTS - Dispalyed as: #CROSS - Points defining shape of support linked in chain to each other
  *						//  Support points straight to the ground from last point in chain
  *
  * 					4a) RAFT     Same as support obejct, but ends on last point in chain
  * 					4b) SUPPORT: Line connecting all points in chain.
  *
  *		 					5) BEAM: Cross lines between supports
  *
  *
  *
  *
  * NOTICES: Pointers of objects are changing throught sessions
  *
  * USER PROPS KEYS:
  *	#SOURCE_OBJECT	- Pointer of support source object saved into user props of sources object on first use of support system
  *
  *	#POINTER_SYNC	- #SOURCE_OBJECT Pointer saved to POINTS, SUPPORTS and BEAMS to keep connection with source object. #SOURCE_OBJECT==#POINTER_SYNC
  *
  *	#THIS        	- Pointer of object itself saved on object creation.
  *
  *	#SOURCE_VERT 	- Save index of vert of which was used as origin for point helper
  *
  *	#RAFT_MODE   	- Used on SUPPORTS and RAFTS - Differentiate types of objects
  *
  *	#BEAM_SUPPORTS	- Used on BEAMS - Array of supports pointers which beam connects E.G.: #( 1st_support, 2nd_pointer )
  *
  *
  *
  *
  *
 */
struct SupportManager_v
(
	/* construct */
	export_size,

	/* properties */
	SourceObjects = Dictionary #STRING,

	--BeamObjects = Dictionary #STRING, --KEY:"support_pointer" VALUE:BeamObject_v

	BeamObjects = #(),

	/* dependency */
	/* reference */
	/* inhered */

	/** Generate points
	 */
	function generateSupports source_obj is_raft:false =
	(
		format "\n"; print "SupportManager_v.generateSupports()"
		--format "source_obj: %\n" source_obj
		--SUPPORT_OPTIONS.getValuesFroUi()

		pointer = (getHandleByAnim source_obj) as string

		sync_key = getUserPropVal source_obj "SUPPORT_SYNC_SOURCE" asString:true

		if sync_key == undefined then
		(
			sync_key = pointer

			setUserPropVal source_obj "SUPPORT_SYNC_SOURCE" sync_key
		)


		if SourceObjects[sync_key] == undefined then
			SourceObjects[sync_key] = SourceObject_v(source_obj) (sync_key)

		SourceObject = SourceObjects[sync_key]


		/*------------------------------------------------------------------------------
			DEV
		------------------------------------------------------------------------------*/
		--delete (SourceObject.getSupportNodes())

		SourceObject.generateSupports is_raft:is_raft

		bindBeamOnDeleteCallback( SourceObject.getSupportNodes() )

		bindSourceObjectTransformEvent (source_obj)
		--format "SourceObject.getSupportNodes(): %\n" (SourceObject.getSupportNodes())
		--format "SourceObject.Supports: %\n" SourceObject.Supports

	),

	/** Generate beams
	 */
	function generateBeams supports_in =
	(
		format "\n"; print "SupportManager_v.generateBeams()"
		--all_supports = Dictionary #STRING

		/** if support height is greater then min height option
		 */
		function isTallEnough obj =
		(
			bbox = nodeGetBoundingBox obj ( Matrix3 1) -- return array of max\min positions E.G.: bbox[1].z | bbox[2].z

			bbox[2].z - bbox[1].z > SUPPORT_OPTIONS.min_height
		)

		new_beams = #()

		supports_in = for support in supports_in where this._isSupport(support) and isTallEnough(support) collect support


		if supports_in.count >= 2 then
		(
			--format "supports_in IN: %\n" supports_in
			sorted_supports = if supports_in.count > 2 then
							this._sortSupportsByDistance(supports_in)
						else
							#(supports_in)


			format "supports IN: %\n" supports_in
			print "------------------------"
			for supports in sorted_supports do
				format "supports: %\n" supports



			for supports in sorted_supports do
				for i = 1 to supports.count - 1 do
				(
					support_A = supports[i]
					support_B = supports[i + 1]

					pointer_A = getUserPropVal support_A "THIS" asString:true
					pointer_B = getUserPropVal support_B "THIS" asString:true

					/* GENERATE BEAM */
					BeamObject = (BeamObject_v support_A support_B ).generateBeam()

					/* SAVE SYNC KEY */
					setUserPropVal BeamObject.beam "SUPPORT_SYNC" ( getUserPropVal support_A "SUPPORT_SYNC" )

					/* ADD TO BEAMS */
					append BeamObjects BeamObject
				)
		)
	),

	/** Update supports
	 */
	function updateSupports source_objects =
	(
		--format "\n"; print "SupportManager_v.updateSupports()"

		sync_keys = for obj in source_objects where (sync_key = this._getSyncSourceKey (obj) ) != undefined collect sync_key
		--format "sync_keys: %\n" sync_keys

		/* UPDATE SUPPORTS */
		for sync_key in sync_keys do
			SourceObjects[sync_key].updateSupports()

		/* UPDATE BEAMS */
		for BeamObject in BeamObjects where findItem sync_keys (this._getSyncKey (BeamObject.beam)) > 0 do
			BeamObject.updateBeam()

	),

	/** Update supports height
	 */
	function updateSupportsHeight source_objects =
	(
		format "\n"; print "SupportManager_v.updateSupportsHeight()"
		for obj in source_objects where (sync_key = this._getSyncKey (obj) ) != undefined do
			SourceObjects[sync_key as string ].updateSupportsHeight()
	),

	/** Update supports
	 */
	function updateSupport support_node =
	(
		--format "\n"; print "SupportManager_v.updateSupportPosition()"
		--format "support_nodes: %\n" support_nodes
		sync_key = getUserPropVal support_node "SUPPORT_SYNC"

		/* UPDATE SUPPORT */
		SourceObjects[sync_key].updateSupport(support_node)


		/* UPDATE BEAMS OF SUPPORT */
		for BeamObject in BeamObjects where BeamObject.support_A == support_node or BeamObject.support_B == support_node do
			BeamObject.updateBeam()
	),

	/** Update modifiers by control value
	 */
	function updateModifiers ctrl val =
	(
		--format "\n"; print "SupportManager_v.updateModifiers()"
		/** Remove control type prefix from control nmae
		*
		* @param string ctrl E.G.: "SpinnerControl:SPIN_base_width"
		*
		* @return string E.G.: "base_width"
		*/
		function removeControlTypePrefix ctrl =
		(
			--format "\n"; print "SupportManager_v.removeControlTypePrefix()"
			ctrl_id	= (filterString ( ctrl as string ) ":")[2]

			prop_key = substring ctrl_id ((findString ctrl_id "_")+1) -1
		)

		_selection = selection as Array

		prop = removeControlTypePrefix(ctrl)


		source_objects = this._getSourceObjects ( _selection )
		supports       = this._getSupportNodes ( _selection )
		--format "_selection: %\n" _selection
		--format "source_objects: %\n" source_objects
		--format "supports: %\n" supports
		--join supports supports_sel

		for SourceObject in source_objects do
			join supports (SourceObject.getSupportNodes())

		SUPPORT_OPTIONS.setOptionValue (prop) (val)
		--SPIN_base_width
		SUPPORT_MODIFIERS.updateModifier( makeUniqueArray supports )(prop)
	),


	/** On beam deleted
	 */
	function onObjectDeleted obj =
	(
		--format "\n"; print "SupportManager_v.onBeamDeleted()"
		--format "obj: %\n" obj
		--format "BeamObjects.count: %\n" BeamObjects.count


		if ( this._getSyncKey (obj) ) != undefined then
			for child in obj.children do
				delete child

		else if ( getUserPropVal obj "RAFT" ) != undefined then
			for i = BeamObjects.count to 1 by -1 where BeamObjects[i].support_A == obj or BeamObjects[i].support_B == obj do
				delete BeamObjects[i].beam

		--else if ( getUserPropVal obj "support_A" ) != undefined then
		--	for i = 1 to BeamObjects.count where BeamObjects[i].beam == obj do
		--		deleteItem BeamObjects i

		BeamObjects = for BeamObject in BeamObjects where isValidNode BeamObject.beam collect BeamObject

		for pointer in SourceObjects.keys where not isValidNode SourceObjects[pointer].obj do RemoveDictKey SourceObjects pointer
	),

	private

	/** Sort supports by distance
	  * Return arrays of supports sorted by closest distance.
	  * Each array contains supports which are close enought to thmeselfs.
	  *
	  * Max distance of supports is set in SUPPORT_OPTIONS.max_distance
	  *
	  * @return 2D array
	 */
	function _sortSupportsByDistance supports =
	(
		--format "\n"; print "SupportManager_v.sortSupportsByDistance()"
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

			/*------------------------------------------------------------------------------
				LOOP SUPPORTS AND FIND CLOSEST SUPPORT
			--------------------------------------------------------------------------------*/
			for i = 1 to supports.count where not proccessed_supports[i] do
				if (current_distance = distance support_pos supports[i].pos ) < min_distance_found and current_distance <= SUPPORT_OPTIONS.beams_count then
				(
					min_distance_found = current_distance

					next_support_i = i
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
			for i = 1 to supports.count where not proccessed_supports[i] do
				if support_i == undefined then
					support_i = i
		)

		sorted_all -- return
	),

	/** Get source object
	 */
	function _getSourceObjects _objects =
	(
		--format "\n"; print "SupportManager_v._getSourceObject()"
		sync_keys = for obj in _objects where (sync_key = this._getSyncKey (obj)) != undefined collect sync_key

		for sync_key in sync_keys collect SourceObjects[sync_key]
	),

	/** Get supports
	 */
	function _getSupportNodes _objects =
	(
		--format "\n"; print "SupportManager_v._getSupports()"
		for obj in _objects where this._isSupport(obj) collect obj
	),


	/** Get verts normals
	 */
	function _getVertsNormals =
	(
		--format "\n"; print "MeshDataGetter_v._getVertsNormals()"
		obj_mesh = obj.mesh

		vertex_normals = #{1..obj.numverts} as Array

		for i = 1 to verts_data[#VERTS].count do
			vertex_normals[i] = point3 0 0 0

		faces_of_verts = meshop.getFacesUsingVert obj_mesh verts_data[#VERTS]

		for face_of_vert in faces_of_verts do
		(
			face_verts = getFace	obj_mesh face_of_vert
			face_normal = getFaceNormal	obj_mesh face_of_vert


			vertex_normals[face_verts.x] += face_normal
			vertex_normals[face_verts.y] += face_normal
			vertex_normals[face_verts.z] += face_normal
		)

		for vert in verts_data[#VERTS] collect normalize vertex_normals[vert]
	),

	--/** Get existing support and rafts
	-- */
	--function _getExistingSupportAndRafts sync_key =
	--(
	--	--format "\n"; print "SupportManager_v.getExistingSupportAndRafts()"
	--	for obj in objects where superClassOf obj.baseobject == shape and getUserPropVal obj "SUPPORT_SYNC" == sync_key collect obj
	--),

	/** Load source objects from scene
	 */
	function _loadSourceObjectsFromScene =
	(
		format "\n"; print "SupportManager_v._loadSourceObjectsFromScene()"

		--unindSupportToTransformEvent()

		for obj_in_scene in objects where (sync_key = this._getSyncSourceKey (obj_in_scene) ) != undefined do
		(
			SourceObject = SourceObject_v(obj_in_scene) (sync_key)

			SourceObject.initObjectsFromScene()

			supports = SourceObject.getSupportNodes()

			/* BIND TO EVENTS */

			bindSupportToTransformEvent( supports )

			bindBeamOnDeleteCallback( supports )

			SourceObjects[sync_key] = SourceObject

		)

		bindSourceObjectTransformEvent ( for sync_key in SourceObjects.keys collect SourceObjects[sync_key].obj )

	),

	/** Load beam objects from scene
	 */
	function _loadBeamsFromScene =
	(
		format "\n"; print "SupportManager_v._loadBeamsFromScene()"

		BeamObjects = for BeamObject in BeamObjects where isValidNode BeamObject.beam collect BeamObject

		for beam_in_scene in objects where (pointer_A = getUserPropVal beam_in_scene "support_A") != undefined do
		(
			pointer_B = getUserPropVal beam_in_scene "support_B"

			support_A = getAnimByHandle (pointer_A as IntegerPtr )
			support_B = getAnimByHandle (pointer_B as IntegerPtr )

			BeamObject = (BeamObject_v support_A support_B )

			BeamObject.beam = beam_in_scene

			append BeamObjects BeamObject
		)

		--bindBeamOnDeleteCallback( for BeamObject in BeamObjects collect BeamObject.beam  )
	),

	/** Is support
	 */
	function _isSupport obj =
	(
		--format "\n"; print "SupportManager_v._isSupport()"
		superClassOf obj.baseobject == shape and getUserPropVal obj "RAFT" != undefined
	),

	/** Get sync key from source object
	 */
	function _getSyncSourceKey source_obj =
	(
		--format "\n"; print "SupportManager_v.getSyncKey()"
		getUserPropVal source_obj "SUPPORT_SYNC_SOURCE" asString:true
	),

	/** Get sync key from object
	 */
	function _getSyncKey obj =
	(
		--format "\n"; print "SupportManager_v.getSyncKey()"
		getUserPropVal obj "SUPPORT_SYNC" asString:true
	),

	/**
	*/
	on create do
	(
		--format "\n"; print "SupportManager_v.onCreate()"
		this._loadSourceObjectsFromScene()

		this._loadBeamsFromScene()

		SUPPORT_OPTIONS.getValuesFroUi()

	)
)
