--filein( getFilenamePath(getSourceFileName()) + "/../../../MAXSCRIPT-MaxToPrint/content/rollouts-Main/rollout-VERTEX COLORS/Lib/VertexColorProcessor.ms" )	--"./../../../MAXSCRIPT-MaxToPrint/content/rollouts-Main/rollout-VERTEX COLORS/Lib/VertexColorProcessor.ms"

filein( getFilenamePath(getSourceFileName()) + "/../../content/rollouts-Main/rollout-VERTEX-COLORS/Lib/VertexColors/VertexColors.ms" )	--"./../../content/rollouts-Main/rollout-VERTEX-COLORS/Lib/VertexColors/VertexColors.ms"
--filein( getFilenamePath(getSourceFileName()) + "/../VertexColors/VertexColors.ms" )	--"./../VertexColors/VertexColors.ms"

--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-PrintSupports\content\rollouts-Main\rollout-VERTEX COLORS\Lib\VertexColorProcessor.ms"
filein( getFilenamePath(getSourceFileName()) + "/../../content/rollouts-Main/rollout-VERTEX-COLORS/Lib/VertexColorProcessor/VertexColorProcessor.ms" )	--"./../../content/rollouts-Main/rollout-VERTEX-COLORS/Lib/VertexColorProcessor/VertexColorProcessor.ms"

filein( getFilenamePath(getSourceFileName()) + "/onSupportTransformCallback/onSupportTransformCallback.ms" )	--"./onSupportTransformCallback/onSupportTransformCallback.ms" -- MUST BE BEFORE SourceObject.ms
filein( getFilenamePath(getSourceFileName()) + "/onBeamDeletedCallback/onBeamDeletedCallback.ms" )	--"./onBeamDeletedCallback/onBeamDeletedCallback.ms" -- MUST BE BEFORE SourceObject.ms
filein( getFilenamePath(getSourceFileName()) + "/onEvents/onSourceObjectTransform/onSourceObjectTransform.ms" )	--"./onEvents/onSourceObjectTransform/onSourceObjectTransform.ms"

filein( getFilenamePath(getSourceFileName()) + "/../SupportOptions/SupportOptions.ms" )	--"./../SupportOptions/SupportOptions.ms"

filein( getFilenamePath(getSourceFileName()) + "/SourceObject/SourceObject.ms" )	--"./SourceObject/SourceObject.ms"

filein( getFilenamePath(getSourceFileName()) + "/BeamObject/BeamObject.ms" )	--"./BeamObject/BeamObject.ms"

filein( getFilenamePath(getSourceFileName()) + "/ModifiersManager/ModifiersManager.ms" )	--"./ModifiersManager/ModifiersManager.ms"

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
	SourceObjects  = Dictionary #STRING,
	SupportObjects = Dictionary #STRING,

	BeamObjects = Dictionary #STRING, --KEY:#POINTER_SUPORT_AxPOINTER_SUPORT_B VALUE:BeamObject_v

	--BeamObjects = #(),

	shapes_to_update = #(), -- sore shape for mass updating

	/* dependency */
	/* reference */
	/* inhered */

	/** Generate points
	 */
	function generateSupports source_obj obj_type:#SUPPORT =
	(
		--format "\n"; print "SupportManager_v.generateSupports()"
		--format "obj_type: %\n" obj_type
		--format "source_obj: %\n" source_obj
		--SUPPORT_OPTIONS.getValuesFroUi()

		pointer = (getHandleByAnim source_obj) as string

		sync_key = getUserPropVal source_obj "SOURCE_KEY"

		if sync_key == undefined then
		(
			sync_key = pointer

			setUserPropVal source_obj "SOURCE_KEY" sync_key asString:true
		)


		if SourceObjects[sync_key] == undefined then
		(
			SourceObjects[sync_key] = SourceObject_v(source_obj) (sync_key)

			bindSourceObjectTransformEvent (source_obj)
		)

		SourceObject = SourceObjects[sync_key]


		/*------------------------------------------------------------------------------
			DEV
		------------------------------------------------------------------------------*/
		--delete (SourceObject.getSupportNodes())

		new_nodes = SourceObject.generateSupports obj_type:obj_type

		--support_nodes =
		--
		--for SupportObject in (SupportObjects) do

		bindSupportToTransformEvent( SourceObject.getSupportNodes() )

		bindBeamOnDeleteCallback( SourceObject.getSupportNodes() )

		--format "SourceObject.getSupportNodes(): %\n" (SourceObject.getSupportNodes())
		--format "SourceObject.Supports: %\n" SourceObject.Supports
		this.updateShapes()

		new_nodes --return
	),

	/** Generate beams
	 */
	function generateBeams supports_in auto_sort:true use_max_distance:true =
	(
		format "\n"; print "SupportManager_v.generateBeams()"
		--format "supports_in: %\n" supports_in

		/** if support height is greater then min height option
		 */
		function isTallEnough obj =
		(
			bbox = nodeGetBoundingBox obj ( Matrix3 1) -- return array of max\min positions E.G.: bbox[1].z | bbox[2].z

			bbox[2].z - bbox[1].z > SUPPORT_OPTIONS.min_height
		)
		/** Get beam key
		 */
		function getBeamKey =
		(
			--format "\n"; print "SupportManager_v.getBeamKey()"
			pointers = sort #( this._getSupportKey(support_A) , this._getSupportKey(support_B) )

			( pointers[1] + "x" + pointers[2] ) --return
		)
		new_beams = #()

		supports_in = for support in supports_in where this.isType #SUPPORT (support) != false  collect support

		if supports_in.count > 2 then
			supports_in = for support in supports_in where isTallEnough(support)  collect support


		--supports_in = for support in supports_in where this.isType #SUPPORT support != false collect support

		format "supports_in: %\n" supports_in.count
		format "supports_in: %\n" supports_in

		if supports_in.count >= 2 then
		(
			--format "supports_in IN: %\n" supports_in
			sorted_supports = if supports_in.count > 2 and auto_sort then
							this._sortSupportsByDistance(supports_in) (use_max_distance)
						else
							#(supports_in)

			--format "sorted_supports: %\n" sorted_supports.count
			--format "sorted_supports: %\n" sorted_supports

			--print "------------------------"
			--for supports in sorted_supports do
				--format "supports: %\n" supports

			for supports in sorted_supports do
				for i = 1 to supports.count - 1 do
				(
					support_A = supports[i]
					support_B = supports[i + 1]

					/* GENERATE BEAM */
					BeamObject = (BeamObject_v support_A support_B )
					format "TEST: %\n" BeamObjects[BeamObject.beam_key]
					if BeamObjects[BeamObject.beam_key]  == undefined then
					(
						BeamObject.generateBeam()

						/* SAVE SYNC KEY */
						setUserPropVal BeamObject.beam "SYNC_KEY" ( getUserPropVal support_A "SYNC_KEY" )
						setUserPropVal BeamObject.beam "BEAM_KEY"  BeamObject.beam_key

						/* ADD TO BEAMS */
						BeamObjects[BeamObject.beam_key] = BeamObject

						append new_beams BeamObject.beam
					)

				)
		)

		this.updateShapes()

		new_beams --return
	),

	/** Update supports
	 */
	function updateSupportsBySourceObject source_objects only_height:false =
	(
		format "\n"; print "SupportManager_v.updateSupportsBySourceObject()"

		sync_keys = for obj in source_objects where (sync_key = this._getSyncSourceKey (obj) ) != undefined collect sync_key

		/* UPDATE SUPPORTS */
		for sync_key in sync_keys do
			if only_height then
				SourceObjects[sync_key].updateSupportsHeight()

			else
				SourceObjects[sync_key].updateSupports()

		/* UPDATE ALL BEAMS OF SOURCE OBEJCTS */
		for key in BeamObjects.keys where findItem sync_keys (this._getSyncKey (BeamObjects[key].beam)) > 0 do
			BeamObjects[key].updateBeam()

		this.updateShapes()
	),

	/** Update supports
	 */
	function updateSupports support_nodes =
	(
		--format "\n"; print "SupportManager_v.updateSupportPosition()"
		--format "support_nodes: %\n" support_nodes

		supports_by_source = this._sortObjectsBySourceObject (support_nodes)

		for sync_key in supports_by_source.keys do
			for support_node in supports_by_source[sync_key] do
				SourceObjects[sync_key].updateSupport(support_node)

		/* UPDATE ALL BEAMS OF SELECTED SUPPORTS */
		/* !!!!!!!!!!!!! TODO UPDATE ONLY BEAMS OF UPDATED SUPPORTS */
		for key in BeamObjects.keys where findItem supports_by_source.keys (this._getSyncKey (BeamObjects[key].beam)) > 0 do
			BeamObjects[key].updateBeam()


		this.updateShapes()
	),

	/** Convert support to raft or vice versa
	  *
	  * @param #SUPPORT|#RAFT to_type of obejct to covert
	  *
	 */
	function convert support_nodes to_type:#RAFT  =
	(
		--format "\n"; print "SupportManager_v.convertSupportsToRafts()"

		--from_type =  if to_type == #RAFT then #SUPPORT else #RAFT
		--format "SupportObjects: %\n" SupportObjects
		--format "from_type: %\n" from_type
		--format "to_type:   %\n" to_type
		--format "supports_by_source.keys: %\n" supports_by_source.keys

		supports_by_source = this._sortObjectsBySourceObject (support_nodes)
		--format "supports_by_source: %\n" supports_by_source

		pauseSupportToTransformEvent()

		with redraw off
			for sync_key in supports_by_source.keys do
			(

				--format "sync_key: %\n" sync_key
				SourceObjects[sync_key].convert(supports_by_source[sync_key] ) to_type:to_type

				--for support_node in supports_by_source[sync_key] do
				--   SupportObjects[this._getKey(from_type)(support_node)].convert(to_type)


				MODIFIERS_MANAGER.switchSupportType( SourceObjects[sync_key].getSupportNodes obj_type:to_type ) to_type:to_type

			)

		redrawViews()


		--for sync_key in supports_by_source.keys do
		--	for support_node in supports_by_source[sync_key] do
		--		SourceObjects[sync_key].convertToRaft(support_node)

		this.updateShapes()

		resumeSupportToTransformEvent()
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

		prop_key = removeControlTypePrefix(ctrl)

		source_objects = this._getSourceObjects ( _selection )
		supports       = this._getSupportNodes ( _selection )

		for SourceObject in source_objects do
			join supports (SourceObject.getSupportNodes())

		SUPPORT_OPTIONS.setOptionValue (prop_key) (val)
		--SPIN_base_width
		MODIFIERS_MANAGER.updateModifier( makeUniqueArray supports )(prop_key as name )
	),


	/** On beam deleted
	 */
	function onObjectDeleted obj =
	(
		--format "\n"; print "SupportManager_v.onObjectDeleted()"
		--format "obj: %\n" obj

		/* IF SOURCE OBJECT */
		if (sync_key = this.isSourceObject obj) != false then
		(
			RemoveDictValue SourceObjects sync_key

			/*  DELETE SUPPORTS */
			for support_key in SourceObjects[sync_key].Supports.keys do
				delete SourceObjects[sync_key].Supports[support_key].support_obj
		)

		/* IF SUPPORT DELETED */
		else if (support_key = this.isType #SUPPORT obj) != false then
		(
			sync_key = this._getSyncKey obj
		    index    = getUserPropVal obj "INDEX"

			/* REMOVE FROM SOURCE OBJECT */
			RemoveDictValue SourceObjects[sync_key].Supports index

			/* REMOVE FROM THIS */
			RemoveDictValue SupportObjects support_key

			/*  DELETE BEAMS */
			for beam_key in BeamObjects.keys where matchPattern support_key pattern:("*"+beam_key+"*") do
				delete BeamObjects[beam_key].beam
		)

		/* IF BEAM DELETED */
		else if (beam_key = this.isType #BEAM obj) != false then
			RemoveDictValue BeamObjects beam_key

	),

	/** Update shape add
	 */
	function updateShapeAdd _shape =
	(
		--format "\n"; print "SupportManager_v.updateShapeAdd()"
		appendIfUnique shapes_to_update _shape
	),

	/** Update shapes
	 */
	function updateShapes =
	(
		--format "\n"; print "SupportManager_v.updateShapes()"

		with redraw off
			for _shape in shapes_to_update do
				updateShape _shape

		redrawViews()

		shapes_to_update = #()
	),


	/** get objects by type
	 */
	function searchObjectsByType _objects type: hierarchy:false =
	(
		format "\n"; print "SupportManager_v.searchObjectsByType()"

        source_keys = #()
        supports	= #()
        beams   	= #()

        objects_to_process = #()


		for obj in _objects do
			case of
			(
                ((sync_key = this.isSourceObject obj) != false): append source_keys sync_key
                --((this.isType #SOURCE  obj) != false): append source_keys obj
                ((this.isType #SUPPORT obj) != false): append supports obj
                ((this.isType #BEAM    obj) != false): append beams obj
                --default:
			)

		format "source_keys: %\n" source_keys.count
		format "supports: %\n" supports.count
		format "beams: %\n" beams.count

		if type == #SOURCE then
		(
			--for source_key in source_keys do append objects_to_process SourceObjects[source_key]
			--if hierarchy then
			--(
				sync_keys_of_objs = for obj in supports + beams collect this._getSyncKey(obj)
			--	format "sync_keys_of_objs: %\n" sync_keys_of_objs
			--	format "source_keys: %\n" source_keys
			--
				source_keys = makeUniqueArray (source_keys + sync_keys_of_objs)
			--	--objects_to_process = for key in  collect SourceObjects[key].obj
			--
			--	source_keys = makeUniqueArray (source_keys + sync_keys_of_objs)
			--)


			objects_to_process = for key in source_keys collect SourceObjects[key].obj
		)

		else if source_keys.count > 0 then
		(

			/* GET SUPPORTS OF SOURCE OBJECT */
			if hierarchy or type == #SUPPORT  then
				for key in SupportObjects.keys where findItem source_keys SupportObjects[key].sync_key > 0 do
					append objects_to_process SupportObjects[key].support_obj

			/* GET BEAMS OF SOURCE OBJECT */
			if hierarchy or type == #BEAM  then
				for key in BeamObjects.keys where findItem source_keys BeamObjects[key].sync_key > 0 do
					append objects_to_process BeamObjects[key].beam

		)
		else if supports.count > 0 then
		(

			if  hierarchy or type == #SUPPORT then
				objects_to_process += supports

			/* GET BEAMS OF SOURCE OBJECT */
				if hierarchy or type == #BEAM  then
					for key in BeamObjects.keys where findItem supports BeamObjects[key].support_A > 0 or findItem supports BeamObjects[key].support_B > 0 do
						append objects_to_process BeamObjects[key].beam

		)
		else if beams.count > 0 then
		(

			if type == #BEAM  then
				objects_to_process = beams


			else if type == #SUPPORT then
				for beam in beams do(

					appendIfUnique objects_to_process SupportObjects[getUserPropVal beam "SUPPORT_A"].support_obj
					appendIfUnique objects_to_process SupportObjects[getUserPropVal beam "SUPPORT_B"].support_obj
				)

		)



		format "OBJECTS_TO_PROCESS: %\n" OBJECTS_TO_PROCESS

		objects_to_process --return
	),

	/*------------------------------------------------------------------------------
		TEST OBEJCT TYPE
	--------------------------------------------------------------------------------*/

	/** Test if object is support|beam|raft
	  *
	  * @return boolean
	 */
	function isManaged obj =
	(
		--format "\n"; print "SupportManager_v.isSourceObject()"
		getUserPropVal obj "SYNC_KEY" != undefined
	),

	/** Test if object is source object
	  *
	  * @return string|false
	 */
	function isSourceObject obj =
	(
		--format "\n"; print "SupportManager_v.isSourceObject()"
		if ( sync_key = getUserPropVal obj "SOURCE_KEY" ) != undefined then
			sync_key --return
		else
			false --return
	),

	/** Test if object is type of source|support|beam|raft
	  *
	  * @return string|false
	 */
	function isType type obj =
	(
		--format "\n"; print "SupportManager_v._isObjectType()"
		type_full = toUpper (type as string ) + "_KEY"
		--format "type_full: %\n" type_full

		--if superClassOf obj.baseobject == shape and ( object_key = getUserPropVal obj type_full ) != undefined then
		if ( object_key = getUserPropVal obj type_full ) != undefined then
			object_key --return
		else
			false --return
	),

	--/** Test if object is raft
	--  *
	--  * @return string|false
	-- */
	--function isRaft obj =
	--(
	--	( is_raft = getUserPropVal obj "IS_RAFT" ) != undefined and is_raft == true
	--),

	/*------------------------------------------------------------------------------*/

	private

	/*------------------------------------------------------------------------------*/

	/** Sort supports by distance
	  * Return arrays of supports sorted by closest distance.
	  * Each array contains supports which are close enought to thmeselfs.
	  *
	  * Max distance of supports is set in SUPPORT_OPTIONS.max_distance
	  *
	  * @return 2D array
	 */
	function _sortSupportsByDistance supports use_max_distance =
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
					if not use_max_distance or current_distance <= SUPPORT_OPTIONS.max_distance  then
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

	/** Get source object
	 */
	function _getSourceObjects _objects =
	(
		--format "\n"; print "SupportManager_v._getSourceObject()"
		sync_keys = for obj in _objects where (sync_key = this._getSyncSourceKey (obj)) != undefined collect sync_key

		for sync_key in sync_keys collect SourceObjects[sync_key]
	),

	/** Get supports
	 */
	function _getSupportNodes _objects =
	(
		--format "\n"; print "SupportManager_v._getSupports()"
		for obj in _objects where this.isType #SUPPORT obj != false or this.isType #RAFT obj != false collect obj
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
	--	for obj in objects where superClassOf obj.baseobject == shape and getUserPropVal obj "SYNC_KEY" == sync_key collect obj
	--),

	/** Sort obejcts by source object
	  *
	  * @return Dictionary #STRING -- KEY:"SYNC_KEY" VALUE:#( nodes of source objects )
	 */
	function _sortObjectsBySourceObject _objects =
	(
		--format "\n"; print "SupportManager_v.sortObejctsBySourceObject()"
		supports_by_source =  Dictionary #STRING

		for obj in _objects do
		(
			sync_key = this._getSyncKey (obj)

			if supports_by_source[sync_key] == undefined then
				supports_by_source[sync_key] = #()

			append supports_by_source[sync_key] obj
		)

		supports_by_source --return
	),

	/** Load source objects from scene
	 */
	function _loadSourceObjectsFromScene =
	(
		--format "\n"; print "SupportManager_v._loadSourceObjectsFromScene()"

		--unindSupportToTransformEvent()
		--for obj_in_scene in objects do
			--format "sync_key: %\n" (this.isType #SOURCE obj_in_scene)

		for obj_in_scene in objects where (sync_key = this.isSourceObject obj_in_scene) != false do
		(
			--format "obj_in_scene: %\n" obj_in_scene
			SourceObject = SourceObject_v(obj_in_scene) (sync_key)

			SourceObject.initObjectsFromScene()

			supports = SourceObject.getSupportNodes()

			/* BIND TO EVENTS */

			--bindSupportToTransformEvent( supports )

			--bindBeamOnDeleteCallback( supports )

			SourceObjects[sync_key] = SourceObject

		)

		bindSourceObjectTransformEvent ( for sync_key in SourceObjects.keys collect SourceObjects[sync_key].obj )

	),

	/** Load supports from scene
	 */
	function _loadSupportsFromScene =
	(
		--format "\n"; print "SupportManager_v.loadSupportsFromScene()"

		for obj_type in #( #SUPPORT, #RAFT ) do
			for obj_in_scene in objects where (support_key = this._getKey obj_type obj_in_scene) != undefined do
			(
				format "SUPPORT_KEY: %\n" support_key
				index	 = getUserPropVal obj_in_scene "INDEX"
				sync_key = getUserPropVal obj_in_scene "SYNC_KEY"
				--is_raft	 = getUserPropVal obj_in_scene "IS_RAFT"

				SupportObject = SupportObject_v source_obj:SourceObjects[sync_key].obj support_obj:obj_in_scene support_key:support_key sync_key:sync_key obj_type:obj_type

				SupportObjects[SupportObject.support_key] = SupportObject

				SourceObjects[sync_key].Supports[index] = SupportObject
			)

		bindSupportToTransformEvent( for key in SupportObjects.keys collect SupportObjects[key].support_obj )
	),

	/** Load beam objects from scene
	 */
	function _loadBeamsFromScene =
	(
		--format "\n"; print "SupportManager_v._loadBeamsFromScene()"

		/* REMOVE DELETE NODES */
		for key in BeamObjects.keys where not isValidNode BeamObject[key].beam do
			RemoveDictValue BeamObjects key

		for obj_in_scene in objects where (beam_key = this.isType #BEAM obj_in_scene) != false do
		(
			--format "beam_key: %\n" beam_key
			key_A = getUserPropVal obj_in_scene "SUPPORT_A"
			key_B = getUserPropVal obj_in_scene "SUPPORT_B"

		    sync_key = getUserPropVal obj_in_scene "SYNC_KEY"

			--format "key_A: %\n" key_A
			--format "key_B: %\n" key_B

			if SupportObjects[key_A] != undefined and SupportObjects[key_B] != undefiand then
			(
				support_A = SupportObjects[key_A].support_obj
				support_B = SupportObjects[key_B].support_obj

				BeamObject = BeamObject_v support_A:support_A support_B:support_B beam:obj_in_scene beam_key:beam_key sync_key:sync_key

				/* ADD TO BEAMS */
				BeamObjects[beam_key] = BeamObject
			)

		)

		bindBeamOnDeleteCallback( for key in BeamObjects.keys collect BeamObjects[key].beam )
	),


	/** Get sync key from source object
	 */
	function _getSyncSourceKey source_obj =
	(
		--format "\n"; print "SupportManager_v.getSyncKey()"
		getUserPropVal source_obj "SOURCE_KEY" asString:true
	),

	/** Get sync key from object
	 */
	function _getSyncKey obj =
	(
		--format "\n"; print "SupportManager_v.getSyncKey()"
		getUserPropVal obj "SYNC_KEY" asString:true
	),

	/** Get "SOURCE_KEY|SUPPORT_KEY|BEAM_KEY|" keys from user object properties
	  *
	  * @return string|undefined
	 */
	function _getKey type obj =
	(
		--format "\n"; print "SupportManager_v._getKey()"
		type_full = toUpper (type as string ) + "_KEY"
		--format "type_full: %\n" type_full

		obj_key =  getUserPropVal obj type_full asString:true
		--format "OBJ_KEY: %\n" obj_key
		obj_key --return
	),

	/**
	*/
	on create do
	(
		--format "\n"; print "SupportManager_v.onCreate()"
		this._loadSourceObjectsFromScene()

		this._loadSupportsFromScene()

		this._loadBeamsFromScene()

		--SUPPORT_OPTIONS.getValuesFroUi()

	)
)
