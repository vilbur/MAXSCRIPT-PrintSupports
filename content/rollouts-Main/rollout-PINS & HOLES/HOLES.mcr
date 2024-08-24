--filein( getFilenamePath(getSourceFileName()) + "/Lib/PinsGenerator.ms" )	--"./Lib/PinsGenerator.ms"


/*
*/
macroscript	_print_generator_holes
category:	"_3D-Print"
buttontext:	"HOELS"
icon:	"across:4|offset:[ 0, 0 ]|height:32|width:96|tooltip:GEENERATE PINS for selected verts"
(
	on execute do
		undo "Generate Pins" on
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-LAYERS\Lib\SceneLayers\SceneLayers.ms"
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\Lib\SupportManager\SupportManager.ms"
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\5-PINS.mcr"

			--(getSupportManagerInstance(ROLLOUT_pins)).createPins( selection as Array )
			--(PinsGenerator_v(ROLLOUT_pins)).createPins( selection[1] )
		)
)
