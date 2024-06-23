
filein( getFilenamePath(getSourceFileName()) + "/SupportObject/SupportObject.ms" )	--"./SupportObject/SupportObject.ms"
filein( getFilenamePath(getSourceFileName()) + "/RaftObject/RaftObject.ms" )	--"./RaftObject/RaftObject.ms"

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

	Supports = Dictionary #INTEGER, -- KEY: vertex_index VALUE: SupportObject|RaftObject

	/* private */
	/* dependency */

	--SupportObject, --"./SupportObject/SupportObject.ms"
	--VertexColors, --"./../../VertexColors/VertexColors.ms"


	/* reference */
	/* inhered */

	/** Generate supports
	 */
	function generateSupports raft_mode:false =
	(
		--format "\n"; print "SourceObject_v.generateSupports()"
		this._removeDeletedNodes()
		--colored_verts = (VertexColors_v(obj)).getColoredVerts()
		verts_by_colors = (VertexColors_v(obj)).getVertsAndColors exclude:#(white as string )

		colored_verts = this._flatternDictionary(verts_by_colors)

		verts_pos = this._getVertsPositions()

		use_normals = SUPPORT_OPTIONS.second_point_direction == 1

		direction_down = [0,0,-1]

		if use_normals then
			verts_normals = this._getVertsNormals(colored_verts)

		--format "verts_by_colors: %\n" verts_by_colors
		--format "colored_verts: %\n" colored_verts
		--format "verts_pos: %\n" verts_pos
		--format "verts_normals: %\n" verts_normals

		for vertex_color in verts_by_colors.keys where vertex_color != white as string do
		(
			--format "\nVERTEX_COLOR: %\n" vertex_color
			for vert in verts_by_colors[vertex_color] where Supports[vert] == undefined do
			(
				second_point_direction = if use_normals then normalize (verts_normals[vert] * obj.transform - obj.pos) else direction_down

				RaftOrSupport = if raft_mode then
					( RaftObject(obj)).generateRaft vert pos:verts_pos[vert] clr:(execute vertex_color) normal:second_point_direction --"./SupportObject/SupportObject.ms"
				else
					( SupportObject_v(obj)).generateSupport vert pos:verts_pos[vert] clr:(execute vertex_color) normal:second_point_direction --"./SupportObject/SupportObject.ms"

				support_poiter = (getHandleByAnim RaftOrSupport.support_obj) as string

				setUserPropVal RaftOrSupport.support_obj "SUPPORT_SYNC"	sync_key
				setUserPropVal RaftOrSupport.support_obj "THIS"	support_poiter
				setUserPropVal RaftOrSupport.support_obj "INDEX"	vert

				this.Supports[vert] = RaftOrSupport
			)
		)
		--Supports_and_Rafts = Supports + Rafts
		--for RaftSupport in (Supports + Rafts) do
			--format "RaftSupport: %\n" RaftSupport

		--Supports + Rafts --return
	),

	/** Update support
	 */
	function updateSupports support_nodes =
	(
		format "\n"; print "SourceObject_v.updateSupports()"
		--format "support_nodes: %\n" support_nodes
		--verts = #()
		--
		--SupportsToUpdate = #()
		--
		--
		--
		--for support_node in support_nodes do
		--	if ( index = getUserPropVal support_node "INDEX") != undefined then
		--	(
		--		append verts index
		--
		--		append SupportsToUpdate Supports[index]
		--	)
		--
		--		--Supports[index].updateSupport pos:verts_pos[index] normal:
		--verts_normals = this._getVertsNormals(verts)
		--
		--verts_pos = this._getVertsPositions()
		--
		--for i = 1 to SupportsToUpdate.count do
		--	SupportsToUpdate[i].updateSupport pos:verts_pos[verts[i]] normal:verts_normals[verts[i]]
		
		verts_pos = this._getVertsPositions()

		for support_node in support_nodes do
			if ( index = getUserPropVal support_node "INDEX") != undefined then
				Supports[index].updateSupport pos:verts_pos[index]
	),

	/** Get support nodes of given type
	  *
	  * @param #SUPPORT|#RAFT Get only supports or rafts. Get both if unsupplied
	  *
	  * @return array of nodes
	 */
	function getSupportNodes type: =
	(
		format "\n"; print "SourceObject_v.getSupportNodes()"

		/** Struct name
		 */
		function structName _struct = (filterString( classof _struct as string ) "(:")[2]

		if type != unsupplied then
		(
			type = toLower( type as string )

			for RaftOrSupport in Supports where structName(RaftOrSupport.value) == type collect RaftOrSupport.value.support_obj --return
		)
		else
			for RaftOrSupport in Supports collect RaftOrSupport.value.support_obj --return

	),

	private

	/** Get verts normals
	 */
	function _getVertsNormals verts =
	(
		--format "\n"; print "MeshDataGetter_v._getVertsNormals()"
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
		--format "\n"; print "VertDataGetter_v._getVertsPositions()"
		in coordsys world  meshop.getVerts obj.mesh all_verts node:obj
	),

	/** Get existing support and rafts
	 */
	function _loadSupportsAndRaftsFromScene =
	(
		format "\n"; print "SupportManager_v._loadSupportsAndRaftsFromScene()"
		for obj_in_scene in objects where superClassOf obj_in_scene.baseobject == shape and getUserPropVal obj_in_scene "SUPPORT_SYNC" == sync_key do
		(
			vert = getUserPropVal obj_in_scene "INDEX"

			this.Supports[ vert ] = SupportObject_v(obj)(obj_in_scene)
		)
	),

	/** Flattern dictionary
	 */
	function _flatternDictionary dict =
	(
		--format "\n"; print "SourceObject_v._flatternDictionary()"
		flattern_dict = #{}

		for key in dict.keys do flattern_dict +=  dict[key]

		flattern_dict --return
	),

	--
	--/** Test collision with source object
	-- */
	--function _testCollision pos direction =
	--(
	--	--format "\n"; print "SupportObject_v.testCollision()"
	--
	--	_ray = Ray pos direction
	--
	--	intersectRay obj _ray --return
	--),

	/** Remove deleted nodes
	 */
	function _removeDeletedNodes =
	(

		--format "\n"; print "SourceObject_v._removeDeletedNodes()"
		--for i = Supports.count to 1 by -1 where not isValidNode Supports[i].support_obj do deleteItem Supports i
		for key in Supports.keys where not isValidNode Supports[key].support_obj do removeDictValue Supports key
	),

	/**
	 */
	on create do
	(
		format "\n"; print "SourceObject.onCreate()"
		VertexColors = VertexColors_v(obj)
		--SupportObject = SupportObject_v(obj)
		--RaftObject = RaftObject_v(obj)

		all_verts = #{1..(getNumVerts obj.mesh)}


		this._loadSupportsAndRaftsFromScene()

		bindSupportToTransformEvent( this.getSupportNodes() )

	)

)
