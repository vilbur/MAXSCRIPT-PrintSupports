
filein( getFilenamePath(getSourceFileName()) + "/SupportObject/SupportObject.ms" )	--"./SupportObject/SupportObject.ms"
--filein( getFilenamePath(getSourceFileName()) + "/RaftObject/RaftObject.ms" )	--"./RaftObject/RaftObject.ms"

--filein( getFilenamePath(getSourceFileName()) + "/SupportGenerator/SupportGenerator.ms" )	--"./SupportGenerator/SupportGenerator.ms"

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

		for vertex_color in verts_by_colors.keys do
		(
			format "\n\n----------------- generateSupports by VERTEX_COLOR: % -----------------\n\n" vertex_color
			--format "VERTS: %\n" verts_by_colors[vertex_color]

			for vert in verts_by_colors[vertex_color] where verts_process[vert] and Supports[vert] == undefined do
			(
				format "vert: %\n" vert
				second_point_direction = if use_normals then normalize (verts_normals[vert] * obj.transform - obj.pos) else [0,0,-1] -- direction down

				SupportObject = SupportObject_v(obj)(is_raft)

				/*------------------------------------------------------------------------------
					GENERATE SUPPORT OR RAFT
				--------------------------------------------------------------------------------*/
				SupportObject.generateSupport vert pos:verts_pos[vert] clr:(execute vertex_color) direction:second_point_direction --"./SupportObject/SupportObject.ms"

				SupportObject.support_obj.parent = obj

				support_poiter = (getHandleByAnim SupportObject.support_obj) as string

				setUserPropVal SupportObject.support_obj "SUPPORT_SYNC"	sync_key
				setUserPropVal SupportObject.support_obj "THIS"	support_poiter
				setUserPropVal SupportObject.support_obj "INDEX"	vert
				setUserPropVal SupportObject.support_obj "RAFT"	is_raft

				this.Supports[vert] = SupportObject
			)
		)


		SUPPORT_MODIFIERS.addModifiers( this.getSupportNodes is_raft:is_raft ) raft_mode:is_raft

		bindSupportToTransformEvent( this.getSupportNodes() )

		--for support in (this.getSupportNodes()) do
		--	support.parent = obj

		--Supports_and_Rafts = Supports + Rafts
		--for RaftSupport in (Supports + Rafts) do
			--format "RaftSupport: %\n" RaftSupport

		--Supports + Rafts --return
	),

	/** Update support
	 */
	function updateSupport support_node =
	(
		--format "\n"; print "SourceObject_v.updateSupport()"

		--if verts_pos == undefined then
		verts_pos = this._getVertsPositions()

		--for support_node in support_nodes do
		if ( index = getUserPropVal support_node "INDEX") != undefined then
			Supports[index].updateSupport vertex_pos:verts_pos[index]

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
		--format "is_raft: %\n" is_raft
		/** Struct name
		 */
		--function structName _struct = (filterString( classof _struct as string ) "(:")[2]

		if is_raft != unsupplied then
			for SupportObjectData in Supports where SupportObjectData.value.is_raft == is_raft collect SupportObjectData.value.support_obj --return

		else
			for SupportObjectData in Supports collect SupportObjectData.value.support_obj --return

	),

	/** Get existing support and rafts
	 */
	function loadSupportsAndRaftsFromScene =
	(
		format "\n"; print "SupportManager_v._loadSupportsAndRaftsFromScene()"
		for obj_in_scene in objects where superClassOf obj_in_scene.baseobject == shape and getUserPropVal obj_in_scene "SUPPORT_SYNC" == sync_key do
		(
			vert = getUserPropVal obj_in_scene "INDEX"

			is_raft = getUserPropVal obj_in_scene "RAFT"

			this.Supports[ vert ] = SupportObject_v(obj)(is_raft)(obj_in_scene)
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
		for vert in verts do vertex_normals[vert] = normalize vertex_normals[vert]

		vertex_normals --return
	),

	/** Set verts positions
	 */
	function _getVertsPositions =
	(
		--format "\n"; print "SourceObject_v._getVertsPositions()"
		in coordsys world  meshop.getVerts obj.mesh all_verts node:obj
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
