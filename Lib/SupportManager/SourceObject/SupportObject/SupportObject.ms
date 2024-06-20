filein( getFilenamePath(getSourceFileName()) + "/../PointHelper/PointHelper.ms" )	--"./../PointHelper/PointHelper.ms"

/** Support object
 */
struct SupportObject_v
(
	/* construct */


	/* required */


	/* properties */
	PointHelpers = #(),
	Beams = #(),

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Generate support
	 */
	function generateSupport vert =
	(
		--format "\n"; print "SupportObject_v.generateSupport()"

		(PointHelper_v()).generatePointHelpers(vert)
	),


	private


	/**
	 */
	on create do
	(
		--format "\n"; print "SupportObject.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
