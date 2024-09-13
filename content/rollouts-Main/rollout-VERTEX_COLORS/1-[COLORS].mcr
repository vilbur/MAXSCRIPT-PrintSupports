--filein( getFilenamePath(getSourceFileName()) + "/../rollout-VERTEX SELECTION/Lib/VertSelector/VertSelector.ms" )	--"./../rollout-VERTEX SELECTION/Lib/VertSelector/VertSelector.ms"
filein( getFilenamePath(getSourceFileName()) + "/../../../../MAXSCRIPT-UI-framework/Lib/Menus/RcMenu/RcMenu.ms" )	--"./../../../../MAXSCRIPT-UI-framework/Lib/Menus/RcMenu/RcMenu.ms"
--filein( getFilenamePath(getSourceFileName()) + "/Lib/VertexColorProcessor.ms" )	--"./Lib/VertexColorProcessor.ms"


global VERTEX_COLOR_PARAM

global COLOR_NAMES = Dictionary #( #BLUE, color 0 135 255 ) #(#PINK, color 225 88 199 ) #(#MAGENTA, color 225 0 255 )-- KEY:#COLOR_NAME VALUE:color value



/** Call vertex color macro
 */
function callMethodByVertexColor method _color =
(
	format "\n"; print "callMethodByVertexColor()"
	format "method: %\n" method
	format "VERTEX_COLOR_PARAM: %\n" VERTEX_COLOR_PARAM

	obj = selection[1]

	VERTEX_COLOR_PARAM = _color

	VertexColorProcessor = VertexColorProcessor_v(obj)

	vertex_sel	= getVertSelection obj.mesh


	if method == #SET then
		VertexColorProcessor.setVertexColor vertex_sel VERTEX_COLOR_PARAM

	else
		VertexColorProcessor.byColor method VERTEX_COLOR_PARAM


	--messageBox (param as string ) title:method
)


/*==============================================================================
	Color Set
================================================================================*/


--/**
--  *
--  */
--macroscript	epoly_vertex_color_set_submenu
--category:	"_Epoly-Vertex-Color"
--buttonText:	"Color Set"
--toolTip:	""
--icon:	"MENU:&Color Set"
--(
--	on isVisible return subObjectLevel != 0
--
--	on execute do
--		openVertexColorSubmenu #SET
--)

/**
  */
macroscript	epoly_vertex_color_set_red
category:	"_Epoly-Vertex-Color"
buttonText:	"RED"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &RED|across:4|width:64"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET red
)

/**
  */
macroscript	epoly_vertex_color_set_green
category:	"_Epoly-Vertex-Color"
buttonText:	"GREEN"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &GREEN"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET green
)

/**
  */
macroscript	epoly_vertex_color_set_blue
category:	"_Epoly-Vertex-Color"
buttonText:	"BLUE"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &BLUE"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET COLOR_NAMES[#BLUE]
)

/**
  */
macroscript	epoly_vertex_color_set_white
category:	"_Epoly-Vertex-Color"
buttonText:	"WHITE"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &WHITE"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET white
)

/**
  */
macroscript	epoly_vertex_color_set_orange
category:	"_Epoly-Vertex-Color"
buttonText:	"ORANGE"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &ORANGE"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET orange
)
/**
  */
macroscript	epoly_vertex_color_set_yellow
category:	"_Epoly-Vertex-Color"
buttonText:	"YELLOW"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &YELLOW"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET yellow
)
/**
  */
macroscript	epoly_vertex_color_set_pink
category:	"_Epoly-Vertex-Color"
buttonText:	"PINK"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &PINK"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET COLOR_NAMES[#PINK]
)

/**
  */
macroscript	epoly_vertex_color_set_magenta
category:	"_Epoly-Vertex-Color"
buttonText:	"MAGENTA"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &MAGENTA"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET COLOR_NAMES[#MAGENTA]
)
