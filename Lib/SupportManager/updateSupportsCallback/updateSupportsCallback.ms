


global SUPPORTS_BINDED = #()

--global SUPPORTS_TRANSFORM_CHANGED = #()
--
--/**
-- * https://help.autodesk.com/view/3DSMAX/2015/ENU/?guid=__files_GUID_C1F6495F_5831_4FC8_A00C_667C5F2EAE36_htm
-- */
--function waitForSupportDeselectCallbackStart =
--(
--	--print "Start: waitForSupportDeselectCallbackStart()"
--	try( callbacks.addScript #selectionSetChanged "onSupportSelectionChanged()" id:#waitForSupportSelectionChangedCallback )catch()
--)
--
--
--/**
-- */
--function waitForwaitForDeselectkKill =
--(
--	--print "Kill: waitForSupportSelectionChangedCallback()"
--	try( callbacks.removeScripts #selectionSetChanged id:#waitForSupportSelectionChangedCallback )catch()
--
--	deleteAllChangeHandlers id:#updateSupportsEvent
--)
--
--/**
-- */
--function onSupportSelectionChanged =
--(
--	--print "onSupportSelectionChanged()"
--	param = callbacks.notificationParam()
--
--	--if selection.count == 0 and SUPPORTS_TRANSFORM_CHANGED.count > 0 then
--	if SUPPORTS_TRANSFORM_CHANGED.count > 0 then
--	(
--
--		--SupportGenerator = SupportGenerator_v()
--
--		--for support in SUPPORTS_TRANSFORM_CHANGED do
--			--support.wirecolor = ( color ( random 1 255) ( random 1 255) ( random 1 255) )
--
--		SUPPORT_MANAGER.updateSupports( SUPPORTS_TRANSFORM_CHANGED )
--
--		free SUPPORTS_TRANSFORM_CHANGED -- empty array for nett selection
--	)
--)

/** Bind transform event
 */
function bindSupportToTransformEvent supports =
(
	format "\n"; print ".bindSupportToTransformEvent()"
	format "SUPPORTS: %\n" SUPPORTS
	format "COUNT: %\n" SUPPORTS.count

	--if classOf supports == Array then
	--	join SUPPORTS_BINDED supports
	--
	--else
	--	append SUPPORTS_BINDED supports
	--
	----for i = SUPPORTS_BINDED.count to 1 by -1 where not isValidNode SUPPORTS_BINDED[i] do deleteItem SUPPORTS_BINDED i
	--
	----SUPPORTS_BINDED = makeUniqueArray SUPPORTS_BINDED
	--
	--/* GET ONLY VALID NODES */
	--SUPPORTS_BINDED = for i = (makeUniqueArray SUPPORTS_BINDED).count to 1 by -1 where isValidNode SUPPORTS_BINDED[i] collect SUPPORTS_BINDED[i]
	--format "SUPPORTS_BINDED: %\n" SUPPORTS_BINDED
	--format "COUNT: %\n" SUPPORTS_BINDED.count

	deleteAllChangeHandlers id:#updateSupportsEvent

	when transform supports changes id:#updateSupportsEvent support do
	(
		--appendIfUnique SUPPORTS_TRANSFORM_CHANGED support
		--
		--waitForSupportDeselectCallbackStart()
		--format "support: %\n" support
		--for support in SUPPORTS_TRANSFORM_CHANGED do
			--support.wirecolor = ( color ( random 1 255) ( random 1 255) ( random 1 255) )

		SUPPORT_MANAGER.updateSupports( support )
	)
)

--/** Unind support to transform event
-- */
--function resetSupportToTransformEvent =
--(
--	--format "\n"; print ".resetSupportToTransformEvent()"
--	deleteAllChangeHandlers id:#updateSupportsEvent
--
--	SUPPORTS_BINDED = #()
--
--	SUPPORTS_TRANSFORM_CHANGED = #()
--)
--
--resetSupportToTransformEvent() -- unbind in case of restart tools