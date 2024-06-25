filein( getFilenamePath(getSourceFileName()) + "/../../../MAXSCRIPT-MaxToPrint/content/rollouts-Main/rollout-VERTEX COLORS/Lib/VertexColorProcessor.ms" )	--"./../../../MAXSCRIPT-MaxToPrint/content/rollouts-Main/rollout-VERTEX COLORS/Lib/VertexColorProcessor.ms"
filein( getFilenamePath(getSourceFileName()) + "/../VertexColors/VertexColors.ms" )	--"./../VertexColors/VertexColors.ms"

filein( getFilenamePath(getSourceFileName()) + "/updateSupportsCallback/updateSupportsCallback.ms" )	--"./updateSupportsCallback/updateSupportsCallback.ms" -- MUST BE BEFORE SourceObject.ms

filein( getFilenamePath(getSourceFileName()) + "/../SupportOptions/SupportOptions.ms" )	--"./../SupportOptions/SupportOptions.ms"

filein( getFilenamePath(getSourceFileName()) + "/SourceObject/SourceObject.ms" )	--"./SourceObject/SourceObject.ms"

filein( getFilenamePath(getSourceFileName()) + "/HelperObject/HelperObject.ms" )	--"./HelperObject/HelperObject.ms"

filein( getFilenamePath(getSourceFileName()) + "/SupportModifiers/SupportModifiers.ms" )	--"./SupportModifiers/SupportModifiers.ms"


global SUPPORT_MANAGER
global SUPPORT_OPTIONS
global SUPPORT_MODIFIERS



--delete helpers
--delete shapes
--



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

	/* dependency */
	/* reference */
	/* inhered */

	/** Generate points
	 */
	function generateSupports source_object raft_mode:false =
	(
		format "\n"; print "SupportManager_v.generatePointHelpers()"
		format "source_object: %\n" source_object

		pointer = (getHandleByAnim source_object)	as string
		sync_key = getUserPropVal source_object "SUPPORT_SYNC_SOURCE" asString:true

		if sync_key == undefined then
		(
			sync_key = pointer

			setUserPropVal source_object "SUPPORT_SYNC_SOURCE" sync_key
		)


		if SourceObjects[sync_key] == undefined then
			SourceObjects[sync_key] = SourceObject_v(source_object) (sync_key)

		SourceObject = SourceObjects[sync_key]

		--existing_support_and_rafts = this._getExistingSupportAndRafts(sync_key)
		--format "existing_support_and_rafts: %\n" existing_support_and_rafts

		/*------------------------------------------------------------------------------
			DEV
		------------------------------------------------------------------------------*/
		delete helpers
		--delete existing_support_and_rafts

		SourceObject.generateSupports raft_mode:raft_mode

		format "SourceObject.Supports: %\n" SourceObject.Supports

	),

	/** Update supports
	 */
	function updateSupports support_nodes =
	(
		--format "\n"; print "SupportManager_v.updateSupports()"
		--format "support_nodes: %\n" support_nodes

		for support in support_nodes where (sync_key = getUserPropVal support "SUPPORT_SYNC" ) != undefined do
			SourceObjects[sync_key].updateSupports #(support)
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

	private

	/** Get source object
	 */
	function _getSourceObjects _objects =
	(
		--format "\n"; print "SupportManager_v._getSourceObject()"
		sync_keys = for obj in _objects where (sync_key = getUserPropVal obj "SUPPORT_SYNC_SOURCE") != undefined collect sync_key

		for sync_key in sync_keys collect SourceObjects[sync_key]
	),

	/** Get supports
	 */
	function _getSupportNodes _objects =
	(
		--format "\n"; print "SupportManager_v._getSupports()"
		for obj in _objects where superClassOf obj.baseobject == shape and getUserPropVal obj "RAFT" != undefined collect obj
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

		for obj_in_scene in objects where (sync_key = getUserPropVal obj_in_scene "SUPPORT_SYNC_SOURCE") != undefined do
			SourceObjects[sync_key] = SourceObject_v(obj_in_scene) (sync_key)
	),

	/**
	*/
	on create do
	(
		format "\n"; print "SourceObject.onCreate()"
		this._loadSourceObjectsFromScene()
	)
)

/*------------------------------------------------------------------------------
	INIT GLOBAL CLASSES
--------------------------------------------------------------------------------*/
SUPPORT_OPTIONS = SupportOptions_v(ROLLOUT_supports)

SUPPORT_MODIFIERS = SupportModifiers_v()

SUPPORT_MANAGER = SupportManager_v()
