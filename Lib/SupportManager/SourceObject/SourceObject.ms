filein( getFilenamePath(getSourceFileName()) + "/SupportObject/SupportObject.ms" )	--"./SupportObject/SupportObject.ms"

/** Source object
 */
struct SourceObject_v
(
	/* construct */
	obj,
	sync_key,

	/* required */
	/* properties */
	all_verts,
	verts_process,
	verts_pos,

	Supports = Dictionary #INTEGER, -- KEY: vertex_index VALUE: SupportObject|RaftObject

	/* private */
	/* dependency */

	--SupportObject, --"./SupportObject/SupportObject.ms"
	VertexColors, --"./../../VertexColors/VertexColors.ms"


	/* reference */
	/* inhered */

	/** Generate supports
	 */
	function generateSupports is_raft:false =
	(
		format "\n"; print "SourceObject_v.generateSupports()"
		--format "Supports.keys: %\n" Supports.keys
		--format "Supports.keys: %\n" Supports.keys
		this._removeDeletedNodes()

		--this._setVertsToProcess()
		verts_sel	= getVertSelection obj.mesh

		verts_by_colors = VertexColors.getVertsAndColors exclude:#( white as string )

		colored_verts = this._flatternDictionary(verts_by_colors)

		verts_by_colors[ (obj.wirecolor) as string ] = all_verts - colored_verts

		verts_process =  if verts_sel.numberSet > 0 then verts_sel else colored_verts

		verts_pos = this._getVertsPositions()

		verts_normals = this._getVertsNormals(verts_process)

		use_normals = SUPPORT_OPTIONS.second_point_direction == 1

		supports_exists = Supports.keys as BitArray

		/* FILTER ONLY VERTS WHICH SUPPORT NOT EXISTS AND NORMAL IS POINTING DOWN OR TO SIDE */
		verts_process = ( for vert in verts_process where not supports_exists[vert] and verts_normals[vert].z < 0 collect vert ) as BitArray

		/* FILTER ONLY VERTS TO PROCESS */
		for vertex_color in verts_by_colors.keys do verts_by_colors[vertex_color] *= verts_process

		/* CREATE SUPPORTS FOR EACH COLOR */
		for vertex_color in verts_by_colors.keys do
			for vert in verts_by_colors[vertex_color] do
			(
				--format "vert: %\n" vert
				SupportObject = SupportObject_v(obj)(is_raft)

				/*------------------------------------------------------------------------------
					GENERATE SUPPORT OR RAFT
				--------------------------------------------------------------------------------*/
				second_point_direction = if use_normals then verts_normals[vert] else [0,0,-1] -- direction down

				SupportObject.generateSupport vert first_knot_pos:verts_pos[vert] clr:(execute vertex_color) direction:second_point_direction --"./SupportObject/SupportObject.ms"


				setUserPropVal SupportObject.support_obj "SUPPORT_SYNC"	sync_key
				setUserPropVal SupportObject.support_obj "THIS"	((getHandleByAnim SupportObject.support_obj) as string )
				setUserPropVal SupportObject.support_obj "INDEX"	vert
				setUserPropVal SupportObject.support_obj "RAFT"	is_raft
				setUserPropVal SupportObject.support_obj "DIRECTION"	second_point_direction

				SupportObject.support_obj.parent = obj

				this.Supports[vert] = SupportObject
			)


		SUPPORT_MODIFIERS.addModifiers( this.getSupportNodes is_raft:is_raft ) raft_mode:is_raft

		bindSupportToTransformEvent( this.getSupportNodes() )

		bindSourceObjectTransformEvent ( obj )

		--for support in (this.getSupportNodes()) do
		--	support.parent = obj

		--Supports_and_Rafts = Supports + Rafts
		--for RaftSupport in (Supports + Rafts) do
			--format "RaftSupport: %\n" RaftSupport

		--Supports + Rafts --return
	),

	/** Update whole supports objects
	 */
	function updateSupportsRotation =
	(
		format "\n"; print "SourceObject_v.updateSupports()"
		--format "support_nodes: %\n" support_nodes

		verts_pos = this._getVertsPositions()

		for SupportObjectData in Supports where not SupportObjectData.value.is_raft  do
			SupportObjectData.value.updateRotation first_knot_pos:( this._getVertexPosBySupport(SupportObjectData.value.support_obj) )


		--for BeamObject in BeamObjects where BeamObject.support_A == support or BeamObject.support_B == support do
		--	BeamObject.updateBeam()
	),

	/** Update supports height
	 */
	function updateSupportsHeight =
	(
		format "\n"; print "SourceObject_v.updateSupportsHeight()"
		--for SupportObjectData in Supports where SupportObjectData.value.is_on_ground do
		for SupportObjectData in Supports do
			SupportObjectData.value.updateHeight()
	),

	/** Update support
	 */
	function updateSupportPosition support_node =
	(
		--format "\n"; print "SourceObject_v.updateSupport()"
		--format "support_node.name: %\n" support_node.name
		if verts_pos == undefined then
			verts_pos = this._getVertsPositions()

		index = getUserPropVal support_node "INDEX"

		Supports[index].updatePosition first_knot_pos:verts_pos[index]
	),

	/** Get support nodes of given type
	  *
	  * @param #SUPPORT|#RAFT Get only supports or rafts. Get both if unsupplied
	  *
	  * @return array of nodes
	 */
	function getSupportNodes is_raft: =
	(
		--format "\n"; print "SourceObject_v.getSupportNodes()"
		if is_raft != unsupplied then
			for SupportObjectData in Supports where SupportObjectData.value.is_raft == is_raft collect SupportObjectData.value.support_obj --return

		else
			for SupportObjectData in Supports collect SupportObjectData.value.support_obj --return
	),

	/** Get existing support and rafts from scene
	 */
	function loadSupportsAndRaftsFromScene =
	(
		format "\n"; print "SupportManager_v._loadSupportsAndRaftsFromScene()"
		for obj_in_scene in objects where superClassOf obj_in_scene.baseobject == shape and getUserPropVal obj_in_scene "SUPPORT_SYNC" == sync_key do
		(
			vert = getUserPropVal obj_in_scene "INDEX"

			is_raft = getUserPropVal obj_in_scene "RAFT"

			this.Supports[vert] = SupportObject_v source_obj:obj support_obj:obj_in_scene is_raft:is_raft
		)
	),

	private

	/** Get verts normals
	 */
	function _getVertsNormals verts =
	(
		--format "\n"; print "SourceObject_v._getVertsNormals()"
		--format "verts.numberSet: %\n" verts.numberSet
		obj_mesh = obj.mesh

		obj_pos	= obj.pos
		obj_transform	= obj.transform

		vertex_normals = this.all_verts as Array

		for i = 1 to vertex_normals.count do
			vertex_normals[i] = point3 0 0 0

		faces_of_verts = meshop.getFacesUsingVert obj_mesh verts

		for face_of_vert in faces_of_verts do
		(
			face_verts = getFace	obj_mesh face_of_vert
			face_normal = getFaceNormal	obj_mesh face_of_vert


			vertex_normals[face_verts.x] += face_normal
			vertex_normals[face_verts.y] += face_normal
			vertex_normals[face_verts.z] += face_normal
		)

		--for vert in verts collect normalize vertex_normals[vert]
		for vert in verts do vertex_normals[vert] = normalize (vertex_normals[vert] * obj_transform - obj_pos)

		vertex_normals --return
	),

	/** Set verts positions
	 */
	function _getVertsPositions =
	(
		format "\n"; print "SourceObject_v._getVertsPositions()"
		in coordsys world meshop.getVerts obj.mesh all_verts node:obj
	),

	/** Get vertex pos by support
	 */
	function _getVertexPosBySupport support_obj =
	(
		--format "\n"; print "SourceObject_v._getVertexPosBySupport()"
		index = getUserPropVal support_obj "INDEX"

		verts_pos[index] --return
	),

	/** Flattern dictionary
	 */
	function _flatternDictionary dict =
	(
		--format "\n"; print "SourceObject_v._flatternDictionary()"
		flattern_dict = #{}

		for key in dict.keys do flattern_dict += dict[key]

		flattern_dict --return
	),


	/** Remove deleted nodes
	 */
	function _removeDeletedNodes =
	(
		--format "\n"; print "SourceObject_v._removeDeletedNodes()"
		for key in Supports.keys where not isValidNode Supports[key].support_obj do removeDictValue Supports key
	),

	/**
	 */
	on create do
	(
		format "\n"; print "SourceObject.onCreate()"
		VertexColors = VertexColors_v(obj)

		all_verts = #{1..(getNumVerts obj.mesh)}
	)
)
