
filein( getFilenamePath(getSourceFileName()) + "/SupportObject/SupportObject.ms" )	--"./SupportObject/SupportObject.ms"

/** Source object
 */
struct SourceObject_v
(
	/* construct */
	source_object,

	/* required */


	/* properties */
	Supports = #(),

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Generate supports
	 */
	function generateSupports =
	(
		format "\n"; print "SourceObject_v.generateSupports()"

		vertex_colors = (VertexColors_v(source_object)).getVertsAndColors()

		format "vertex_colors: %\n" vertex_colors

		colored_verts = #{}

		for vertex_color in vertex_colors.keys where vertex_color != "(color 255 255 255)" do colored_verts +=  vertex_colors[vertex_color]

		format "colored_verts: %\n" colored_verts

		for vert in colored_verts do
			(SupportObject_v()).generateSupport(vert) --"./SupportObject/SupportObject.ms"
	),

	private


	/**
	 */
	on create do
	(
		--format "\n"; print "SourceObject.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
