

global BEAMS_BINDED = #()

/** Bind transform event
 */
function bindBeamOnDeleteCallback beams =
(
	--format "\n"; print ".bindBeamOnDeleteCallback()"

	if classOf beams == Array then
		join BEAMS_BINDED beams

	else
		append BEAMS_BINDED beams

	----for i = BEAMS_BINDED.count to 1 by -1 where not isValidNode BEAMS_BINDED[i] do deleteItem BEAMS_BINDED i
	--
	----BEAMS_BINDED = makeUniqueArray BEAMS_BINDED
	--
	--/* GET ONLY VALID NODES */
	--BEAMS_BINDED = for i = (makeUniqueArray BEAMS_BINDED).count to 1 by -1 where isValidNode BEAMS_BINDED[i] collect BEAMS_BINDED[i]
	--format "BEAMS_BINDED: %\n" BEAMS_BINDED
	--format "COUNT: %\n" BEAMS_BINDED.count

	deleteAllChangeHandlers id:#beamOnDeleteEvent

	when BEAMS_BINDED deleted id:#beamOnDeleteEvent beam do
	(
		--appendIfUnique BEAMS_TRANSFORM_CHANGED beam
		--
		--waitForSupportDeselectCallbackStart()
		--format "beam: %\n" beam
		--for beam in BEAMS_TRANSFORM_CHANGED do
			--beam.wirecolor = ( color ( random 1 255) ( random 1 255) ( random 1 255) )
		SUPPORT_MANAGER.onObjectDeleted( beam )
	)
)
