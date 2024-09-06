/** Call vertex color submenu
  *
  * 1) Macro	-> Open Submenu openVertexColorSubmenu()	-- Choose used method
  *     2) Submenu Item	-> Call Function callMethodByVertexColor()	-- Choose color used for method
  *         3) Function	-> Call Desired Vertex Color Method	-- Run used method with choosed color ( Set color|Select By Color|Hide by Color|... )
  *
 */
function openVertexColorSubmenu method =
(
	format "\n"; print "openVertexColorSubmenu()"
	--format "method: %\n" method


	/* FIRST ITEM */
	item_title = case method of
	(
		--#SET:	"Set &Color"
		#SELECT:	"&Select By Selection"
		#HIDE:	"&Hide By Selection"
		#UNHIDE:	"&Unide By Selection"
		#ISOLATE:	"&Isolate By Selection"

	)


	category = "_Epoly-Vertex-Color"

	macro_name = "epoly_vertex_color_" + method as string  + (if method == #SET then "_by_last_color" else "_by_selection")

	/* ITEMS BY COLOR */
	call_fn = "callMethodByVertexColor #"+ method as string + " "


	/* DEFINE MAIN MENU */
	Menu = RcMenu_v name:"TestMenu"


	if method != #SET then
		Menu.item item_title	( "macros.run" + "\"" + category + "\"" + "\"" + macro_name + "\""	) -- macros.run "_Epoly-Vertex-Color" "color_set_by_selection"

	Menu.item "&RED"	( call_fn + "red"	)
	Menu.item "&GREEN"	( call_fn + "green"	)
	Menu.item "&BLUE"	( call_fn + " " + COLOR_NAMES[#BLUE] as string	)
	Menu.item "&ORANGE"	( call_fn + "orange"	)
	Menu.item "&YELLOW"	( call_fn + "yellow"	)
	Menu.item "&PINK"	( call_fn + " " + COLOR_NAMES[#PINK] as string	)
	Menu.item "&WHITE"	( call_fn + "white"	)


	popUpMenu (Menu.create())

)

/**
  */
macroscript	epoly_vertex_color_set_by_last_color
category:	"_Epoly-Vertex-Color"
buttonText:	"SET"
toolTip:	"Set vertex color to selected vertex.\n\nVertex can be selected in modifiers like:\nEdit Poly|Poly Select\n\nLMB: Green\nCTRL:#RED"
icon:	"across:4|MENU:&Color Set|tooltip:\n\n----------------------\n\nFIX IF NOT WORK PROPERLY:\\n1) Try clean mesh, weld verts and close borders"
(
	on isVisible return subObjectLevel != 0

	on execute do if ( obj = selection[1] ) != undefined then
	undo "Set Vertex Color" on
	(
		--clearListener(); print("Cleared in:\n"+getSourceFileName())
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLOR_NAMES\1-VERTEX COLOR.mcr"

		if (vertex_sel = getVertSelection obj.mesh).numberSet > 0 then
		(
			VertexColorProcessor = VertexColorProcessor_v(obj)

			if VERTEX_COLOR_PARAM != undefined then
				(VertexColorProcessor_v(obj)).setVertexColor (vertex_sel) (VERTEX_COLOR_PARAM)
			else
				openVertexColorSubmenu #SET
		)
	)
)


/**
  */
macroscript	epoly_vertex_color_select_by_selection
category:	"_Epoly-Vertex-Color"
buttonText:	"SELECT"
toolTip:	"Select verts with same color as selected verts.\n\n   IF NOTHING SELECTED, then select ALL COLORED verts"
--icon:	"MENU:&Select Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do if ( obj = selection[1] ) != undefined then
	undo "Hide Verts By Selection" on
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\MANAGE VERTEX COLORS.mcr"

		VertexColorProcessor = VertexColorProcessor_v(obj)

		/* SELECT BY SELECTION */
		if (vertex_sel = getVertSelection obj.mesh).numberSet > 0 then
			VertexColorProcessor.byVerts #SELECT vertex_sel

		/* SELECT BY COLOR */
		else
			VertexColorProcessor.byColor #SELECT VERTEX_COLOR_PARAM

	)
)


/**
  */
macroscript	epoly_vertex_color_select_submenu
category:	"_Epoly-Vertex-Color"
buttonText:	"SELECT"
toolTip:	"Open Select Vrtex Color Menu"
icon:	"MENU:&SELECT Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
		openVertexColorSubmenu #SELECT
)



/*------------------------------------------------------------------------------
	HIDE BY COLOR
--------------------------------------------------------------------------------*/
/**
  */
macroscript	epoly_vertex_color_hide_by_selection
category:	"_Epoly-Vertex-Color"
buttonText:	"HIDE"
toolTip:	"Hide verts with same color as selected verts"
--icon:	"MENU:&Hide Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do if ( obj = selection[1] ) != undefined then
	undo "Hide Verts By Selection" on
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\MANAGE VERTEX COLORS.mcr"

		VertexColorProcessor = VertexColorProcessor_v(obj)

		/* HIDE BY SELECTION */
		if (vertex_sel = getVertSelection obj.mesh).numberSet > 0 then
			VertexColorProcessor.byVerts #HIDE vertex_sel

		/* HIDE BY COLOR */
		else
			VertexColorProcessor.byColor #HIDE VERTEX_COLOR_PARAM

	)
)


/**
  */
macroscript	epoly_vertex_color_hide_submenu
category:	"_Epoly-Vertex-Color"
buttonText:	"HIDE"
toolTip:	"Open Hide By Color Menu"
icon:	"MENU:&HIDE Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
		openVertexColorSubmenu #HIDE
)


/*------------------------------------------------------------------------------
	HIDE BY COLOR
--------------------------------------------------------------------------------*/
/**
  */
macroscript	epoly_vertex_color_unhide_by_selection
category:	"_Epoly-Vertex-Color"
buttonText:	"UNHIDE"
toolTip:	"Unhide verts with same color as selected verts"
--icon:	"MENU:&UNHIDE Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0


	on execute do if ( obj = selection[1] ) != undefined then
	undo "Hide Verts By Selection" on
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\MANAGE VERTEX COLORS.mcr"

		VertexColorProcessor = VertexColorProcessor_v(obj)

		if (vertex_sel = getVertSelection obj.mesh).numberSet > 0 then
			VertexColorProcessor.byVerts #UNHIDE vertex_sel
	)
)


/**
  */
macroscript	epoly_vertex_color_unhide_submenu
category:	"_Epoly-Vertex-Color"
buttonText:	"UNHIDE"
toolTip:	"Open Unhide By Color Menu"
icon:	"MENU:&UNHIDE Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
		openVertexColorSubmenu #UNHIDE
)


/*------------------------------------------------------------------------------
	ISOLATE BY COLOR
--------------------------------------------------------------------------------*/
/**
  */
macroscript	epoly_vertex_color_property_toggle
category:	"_Epoly-Vertex-Color"
buttonText:	"SHOW"
toolTip:	"SHOW \ HIDE vertex colors on selcted obejcts"
icon:	"across:4|MENU:true"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
	undo "Show Vertex Colors" on
	(
		--clearListener(); print("Cleared in:\n"+getSourceFileName())
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\VERTEX COLOR.mcr"

		if selection.count > 0 then
		(
			state = not selection[1].showVertexColors

			for obj in selection do
			(
				obj.showVertexColors = state
				obj.vertexColorsShaded = on
				obj.vertexColorType = 0
			)
		)
	)
)

/**
  */
macroscript	epoly_vertex_color_reset_vertex_colors
category:	"_Epoly-Vertex-Color"
buttonText:	"RESET"
toolTip:	"Reset Vertex Colors"
--icon:	"across:4|MENU:true"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
	if queryBox "Reest Vertex Colors ?" title:"RESET VERTEX COLORS" then

	(
		obj	= selection[1]
		/* SET NEW CLASS INSTANCE */
		VertexColorProcessor = VertexColorProcessor_v(obj)

		VertexColorProcessor.resetCPVVerts()

		messageBox "Vertex Colors Reseted" title:"VERTEX COLOR" 
	)
)

/**
  */
macroscript	epoly_vertex_color_isolate_by_selection
category:	"_Epoly-Vertex-Color"
buttonText:	"ISOLATE"
toolTip:	"Hide verts by vertex color of selected verts.White color is used, if nothing selected.\n\nCTRL: ISOLATE MODE (Show all verts of selected colors ).\n\nQUICK SCRIPT, TESTED ONLY ON EDITABLE POLY"
icon:	"across:4"
(
	on execute do if ( obj = selection[1] ) != undefined then
	undo "Hide Colored Verts" on
	(
		--clearListener(); print("Cleared in:\n"+getSourceFileName())
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\MANAGE VERTEX COLORS.mcr"
		VertexColorProcessor = VertexColorProcessor_v(obj)

		vertex_sel	= getVertSelection obj.mesh

		VertexColorProcessor.byVerts #ISOLATE vertex_sel

	)
)



/**
  */
macroscript	epoly_vertex_color_isolate_submenu
category:	"_Epoly-Vertex-Color"
buttonText:	"ISOLATE"
toolTip:	"Open Isolate By Color Menu"
icon:	"MENU:&ISOLATE Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
		openVertexColorSubmenu #ISOLATE
)



/**
  */
macroscript	epoly_vertex_color_channel_info
category:	"_Epoly-Vertex-Color"
buttonText:	"Channel Info"
toolTip:	"Open or Update Channel Info Dialog"
--icon:	"across:4|MENU:true"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
	(
		channelInfo.Dialog ()

		channelInfo.Update ()

	)
)
/**
  */
macroscript	epoly_vertex_color_list_vertex_colors
category:	"_Epoly-Vertex-Color"
buttonText:	"List Colors"
toolTip:	"List Vertex Colors"
--icon:	"across:4|MENU:true"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
	(
		obj	= selection[1]
		/* SET NEW CLASS INSTANCE */
		VertexColors = VertexColors_v(obj)


		/* GET ALL VERTS SORTED BY COLORS */
		colors = VertexColors.getVertsAndColors()

		for colors_data in colors do format "\n********\n\nCOLOR: %\nVERTS: %\nCOUNT: %\n" colors_data.key colors_data.value colors_data.value.numberSet

	)
)
--/**
--  *
--  */
--macroscript	epoly_vertex_color_unhide_submenu
--category:	"_Epoly-Vertex-Color"
--buttonText:	"Menu"
--toolTip:	""
--icon:	"MENU:&Hide Color"
--(
--	on isVisible return subObjectLevel != undefined and subObjectLevel != 0
--
--	on execute do
--		openVertexColorSubmenu "color_unhide"
--)

--
--/**
--  *
--  */
--macroscript	epoly_vertex_color_reset
--category:	"_Epoly-Vertex-Color"
--buttonText:	"RESET Color"
--toolTip:	"Hide verts by vertex color of selected verts.White color is used, if nothing selected.\n\nCTRL: ISOLATE MODE (Show all verts of selected colors ).\n\nQUICK SCRIPT, TESTED ONLY ON EDITABLE POLY"
--icon:	"across:4|MENU:true"
--(
--	on execute do
--	undo "Reset Vertex Color" on
--	(
--		--clearListener(); print("Cleared in:\n"+getSourceFileName())
--		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\VERTEX COLOR.mcr"
--
--
--		obj = selection[1]
--
--		--if getNumCPVVerts obj.mesh > 0 then
--		if polyop.getNumMapVerts obj.baseObject 0 > 0 then
--		(
--			--vertex_sel = getVertSelection obj.mesh
--
--			verts = passVertexSelectionToEditablePoly()
--
--			if verts.isEmpty then
--				verts = #ALL
--
--
--			--/* GET SELECTED OR ALL VERTS */
--			--verts = if vertex_sel.isEmpty then
--			--(
--			--	all_verts =  #{1..(getNumVerts obj.mesh)}
--			--	white_verts = meshop.getVertsByColor obj.mesh white 0.001 0.001 0.001
--			--
--			--	all_verts - white_verts
--			--)
--			--else
--			--	vertex_sel
--
--
--			polyop.setVertColor  obj.baseobject 0 verts white
--
--			--print ("VERTEX COLOR OF "+ (if vertex_sel.isEmpty then "ALL"else "SELECTED") +" SET TO WHITE")
--
--		)
--		else
--			messageBox ("There is not any vertex color on object:\n\n"+obj.name) title:"NO VERTEX COLOR"
--	)
--)
