


global SUPPORTS_BINDED = #()

global SUPPORTS_TRANSFORM_CHANGED = #()

/**
 * https://help.autodesk.com/view/3DSMAX/2015/ENU/?guid=__files_GUID_C1F6495F_5831_4FC8_A00C_667C5F2EAE36_htm
 */
function waitForSupportDeselectCallbackStart =
(
	--print "Start: waitForSupportDeselectCallbackStart()"
	try( callbacks.addScript #selectionSetChanged "onSupportSelectionChanged()" id:#waitForSupportSelectionChangedCallback )catch()
)


/**
 */
function waitForwaitForDeselectkKill =
(
	--print "Kill: waitForSupportSelectionChangedCallback()"
	try( callbacks.removeScripts #selectionSetChanged id:#waitForSupportSelectionChangedCallback )catch()

	deleteAllChangeHandlers id:#updateSupportsEvent
)

/**
 */
function onSupportSelectionChanged =
(
	--print "onSupportSelectionChanged()"
	param = callbacks.notificationParam()

	--if selection.count == 0 and SUPPORTS_TRANSFORM_CHANGED.count > 0 then
	if SUPPORTS_TRANSFORM_CHANGED.count > 0 then
	(

		--SupportGenerator = SupportGenerator_v()

		--for support in SUPPORTS_TRANSFORM_CHANGED do
			SUPPORT_MANAGER.updateSupports( SUPPORTS_TRANSFORM_CHANGED )
			--support.wirecolor = ( color ( random 1 255) ( random 1 255) ( random 1 255) )

		free SUPPORTS_TRANSFORM_CHANGED -- empty array for nett selection
	)
)

/** Bind transform event
 */
function bindSupportToTransformEvent supports =
(
	format "\n"; print ".bindSupportToTransformEvent()"
	format "SUPPORTS: %\n" SUPPORTS

	if classOf supports == Array then
		join SUPPORTS_BINDED supports

	else
		append SUPPORTS_BINDED supports

	/* REMOVE DELETED NODES */
	for i = SUPPORTS_BINDED.count to 1 by -1 where not isValidNode SUPPORTS_BINDED[i] do deleteItem SUPPORTS_BINDED i

	SUPPORTS_BINDED = makeUniqueArray SUPPORTS_BINDED

	when transform SUPPORTS_BINDED changes id:#updateSupportsEvent supports do
	(
		appendIfUnique SUPPORTS_TRANSFORM_CHANGED supports

		waitForSupportDeselectCallbackStart()
	)
)

/** Unind support to transform event
 */
function unindSupportToTransformEvent =
(
	--format "\n"; print ".unindSupportToTransformEvent()"
	deleteAllChangeHandlers id:#updateSupportsEvent

	SUPPORTS_BINDED = #()

	SUPPORTS_TRANSFORM_CHANGED = #()
)
