
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

	Supports = #(),
	Rafts = #(),

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
		format "\n"; print "SourceObject_v.generateSupports()"
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
			for vert in verts_by_colors[vertex_color] do
			(
				second_point_direction = if use_normals then normalize (verts_normals[vert] * obj.transform - obj.pos) else direction_down

				RaftOrSupport = if raft_mode then
					( RaftObject(obj)).generateRaft vert pos:verts_pos[vert] clr:(execute vertex_color) normal:second_point_direction --"./SupportObject/SupportObject.ms"
				else
					( SupportObject_v(obj)).generateSupport vert pos:verts_pos[vert] clr:(execute vertex_color) normal:second_point_direction --"./SupportObject/SupportObject.ms"


				append ( if raft_mode then this.Rafts else this.Supports ) RaftOrSupport

				setUserPropVal RaftOrSupport.BaseShape "SUPPORT_SYNC" sync_key
				setUserPropVal RaftOrSupport.BaseShape "THIS" (getHandleByAnim RaftOrSupport.BaseShape)
				setUserPropVal RaftOrSupport.BaseShape "INDEX" vert
			)
		)
		--Supports_and_Rafts = Supports + Rafts
		for RaftSupport in (Supports + Rafts) do
			format "RaftSupport: %\n" RaftSupport

		Supports + Rafts --return
	),

	/** Get support nodes
	 */
	function getNodes type: =
	(
		--format "\n"; print "SourceObject_v.getSupportNodes()"
		RaftsOrSupports = if type == unsupplied then Supports + Rafts else getProperty this type

		for RaftOrSupport in RaftsOrSupports collect RaftOrSupport.BaseShape --return
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

	/** Flattern dictionary
	 */
	function _flatternDictionary dict =
	(
		--format "\n"; print "SourceObject_v._flatternDictionary()"
		flattern_dict = #{}

		for key in dict.keys do flattern_dict +=  dict[key]

		flattern_dict --return
	),


	/** Test collision with source object
	 */
	function _testCollision pos direction =
	(
		format "\n"; print "SupportObject_v.testCollision()"

		_ray = Ray pos direction

		intersectRay obj _ray --return
	),

	/** Remove deleted nodes
	 */
	function _removeDeletedNodes =
	(
		--format "\n"; print "SourceObject_v._removeDeletedNodes()"
		for i = Supports.count to 1 by -1 where not isValidNode Supports[i].BaseShape do deleteItem Supports i

		for i = Rafts.count to 1 by -1 where not isValidNode Rafts[i].BaseShape do deleteItem Rafts i
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SourceObject.onCreate()"
		VertexColors = VertexColors_v(obj)
		--SupportObject = SupportObject_v(obj)
		--RaftObject = RaftObject_v(obj)

		all_verts = #{1..(getNumVerts obj.mesh)}

	)

)
