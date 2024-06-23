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
		SUPPORT_MODIFIERS.addModifiers( SourceObject.getSupportNodes tye:#SUPPORTS)

		bindSupportToTransformEvent( SourceObject.getSupportNodes() )

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


	private

	/** Get source object
	 */
	function _getSourceObject =
	(
		--format "\n"; print "SupportManager_v._getSourceObject()"



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

		unindSupportToTransformEvent()

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
SUPPORT_MANAGER = SupportManager_v()

SUPPORT_OPTIONS = SupportOptions_v()

SUPPORT_MODIFIERS = SupportModifiers_v()



