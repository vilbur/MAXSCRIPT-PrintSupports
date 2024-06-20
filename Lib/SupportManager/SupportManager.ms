
filein( getFilenamePath(getSourceFileName()) + "/../VertexColors/VertexColors.ms" )	--"./../VertexColors/VertexColors.ms"

filein( getFilenamePath(getSourceFileName()) + "/SourceObject/SourceObject.ms" )	--"./SourceObject/SourceObject.ms"

global SUPPORT_MANAGER

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
	function generateSupports source_object =
	(
		format "\n"; print "SupportManager_v.generatePointHelpers()"
		format "source_object: %\n" source_object

		pointer = (getHandleByAnim source_object)	as string
		sync_key = getUserPropVal source_object "SUPPORT_SYNC_SOURCE" asString:true

		if sync_key == undefined then
		(
			sync_key = pointer

			setUserPropVal source_object "SUPPORT_SYNC_SOURCE" pointer
		)


		if SourceObjects[sync_key] == undefined then
			SourceObjects[sync_key] = SourceObject_v(source_object)

		SourceObject = SourceObjects[sync_key]

		SourceObject.generateSupports()
	),



	/**
	*/
	on create do
	(

	)
)

SUPPORT_MANAGER = SupportManager_v()