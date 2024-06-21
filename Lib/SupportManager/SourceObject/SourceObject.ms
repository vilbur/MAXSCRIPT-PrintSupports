
filein( getFilenamePath(getSourceFileName()) + "/SupportObject/SupportObject.ms" )	--"./SupportObject/SupportObject.ms"

/** Source object
 */
struct SourceObject_v
(
	/* construct */
	obj,

	/* required */


	/* properties */
	Supports = #(),

	/* private */
	/* dependency */

	SupportObject, --"./SupportObject/SupportObject.ms"
	VertexColors, --"./../../VertexColors/VertexColors.ms"


	/* reference */
	/* inhered */

	/** Generate supports
	 */
	function generateSupports =
	(
		format "\n"; print "SourceObject_v.generateSupports()"

		--colored_verts = (VertexColors_v(obj)).getColoredVerts()
		verts_by_colors = (VertexColors_v(obj)).getVertsAndColors()

		verts_pos = this._getVertsPositions()

		format "verts_by_colors: %\n" verts_by_colors
		format "verts_pos: %\n" verts_pos

		for vertex_color in verts_by_colors.keys where vertex_color != white as string do
		(
			for vert in verts_by_colors[vertex_color] do
			--format "vertex_color: %\n" vertex_color
			--format "verts_pos[vert]: %\n" verts_pos[vert]
			--format "vert: %\n" vert
			( deepCopy SupportObject ).generateSupport vert pos:verts_pos[vert] clr:(execute vertex_color) --nrml: --"./SupportObject/SupportObject.ms"

		)



	),

	private

	/** Set verts positions
	 */
	function _getVertsPositions =
	(
		all_verts = #{1..(getNumVerts obj.mesh)}
		--format "\n"; print "VertDataGetter_v._getVertsPositions()"
		in coordsys world  meshop.getVerts obj.mesh all_verts node:obj

	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SourceObject.onCreate()"
		VertexColors = VertexColors_v(obj)
		SupportObject = SupportObject_v(obj)

	)

)
