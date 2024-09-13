clearListener(); print("Cleared in:"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../MAXSCRIPT-UI-framework/Lib/ContentLoader/ContentLoader.ms" )	--"./../MAXSCRIPT-UI-framework/Lib/ContentLoader/ContentLoader.ms"

filein( getFilenamePath(getSourceFileName()) + "/../MAXSCRIPT-UI-framework/Lib/Menus/RcMenu/RcMenu.ms" )	--"./../MAXSCRIPT-UI-framework/Lib/Menus/RcMenu/RcMenu.ms"

/* UI GLOBALS */
global DIALOG_content
global ROLLOUT_generator

/* STRUCT GLOBALS - before import SupportManager */
global SUPPORT_OPTIONS -- global SUPPORT_OPTIONS must be defined before SUPPORT_MANAGER
global SUPPORT_MANAGER
global MODIFIERS_MANAGER
global ISLANDS_SYSTEM
global SLICER_SYSTEM

global DIALOG_island_manager


filein( getFilenamePath(getSourceFileName()) + "/content/rollouts-Main/rollout-SLICER/Lib/SlicerSystem/SlicerSystem.ms" )	--"./content/rollouts-Main/rollout-SLICER/Lib/SlicerSystem/SlicerSystem.ms"

filein( getFilenamePath(getSourceFileName()) + "/content/rollouts-Main/rollout-ISLANDS/Lib/IslandsSystem/IslandsSystem.ms" )	--"./content/rollouts-Main/rollout-ISLANDS/Lib/IslandsSystem/IslandsSystem.ms"

filein( getFilenamePath(getSourceFileName()) + "/Lib/SupportManager/SupportManager.ms" )	--"./Lib/SupportManager/SupportManager.ms"


current_dir = getFilenamePath(getSourceFileName())


/*------------------------------------------------------------------------------
	START VilTools
------------------------------------------------------------------------------*/
try(


	/** LOAD CONTENT */
	--ContentLoader	= ContentLoader_v path:(current_dir+"\\content") -- WITHOUT INI FILE --DEV
	ContentLoader	= ContentLoader_v path:(current_dir+"\\content") ini:( getSourceFileName())



	/* CHANGE PROPERTIES oF ROLLOUTS */
	ContentLoader.Dialog.title = "Max Slicer"


	--/* CREATE DIALOG */
	--MaxToPrint = ContentLoader.create width:420 height:1024
	--MaxToPrint = ContentLoader.create width:420 height:#AUTO
	--MaxToPrint = ContentLoader.create width:420 height:undefined
	MaxToPrint = ContentLoader.create width:420

	MaxToPrint.register()

	/*------------------------------------------------------------------------------
		INIT GLOBAL CLASSES when ui exists
	--------------------------------------------------------------------------------*/
	SUPPORT_OPTIONS = SupportOptions_v(ROLLOUT_generator)

	SUPPORT_OPTIONS.getValuesFroUi()

	MODIFIERS_MANAGER = ModifiersManager_v()

	SLICER_SYSTEM = SlicerSystem_v()

	SUPPORT_MANAGER = SupportManager_v()

	/* RELAUNCH ISLAND MANAGER */
	if DIALOG_island_manager != undefined then
		macros.run "_3D-Print" "maxtoprint_islands_dialog"

	/* RELAUNCH SLICER MANAGER */
	if DIALOG_slicer_slider != undefined then
		macros.run "_3D-Print" "maxtoprint_create_slicerdialog"

)catch(
	format "\n——————————————— ERROR IN FILE ———————————————\n\n%\n" (getSourceFileName())
	format "\n————————————————— EXCEPTION —————————————————\n\n%\n" (getCurrentException())
	format "\n——————————————————— TRACE ———————————————————\n%\n"   (getCurrentExceptionStackTrace())
	format "\n——————————————————— STACK ———————————————————\n%\n"   (getCurrentExceptionCallStack())
)
