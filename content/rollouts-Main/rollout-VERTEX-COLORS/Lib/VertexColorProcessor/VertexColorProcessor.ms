

--filein( getFilenamePath(getSourceFileName()) + "/../../../../Lib/MeshDataGetters/VertexColors/VertexColors.ms" )	--"./../../../../Lib/MeshDataGetters/VertexColors/VertexColors.ms"


/** Vertex color processor
 */
struct VertexColorProcessor_v
(
	/* construct */
	obj,
	--obj_mesh,
	--obj_baseobject,

	/* required */

	/* properties */
	curr_mod,


	/* private */
	/* dependency */
	VertexColors,
	--MeshVertToColorVertexConvert,

	/* reference */
	/* inhered */

	/** Test map verts
	 */
	function _initObject =
	(
		--format "\n"; print "VertexColorProcessor_v._initObject()"
		--format "TEST: %\n" ( polyop.getMapSupport obj 0)

		if obj != undefined or classOf obj.baseobject != Editable_Poly then
		(
			if not polyop.getMapSupport obj 0 then
				polyop.setMapSupport obj 0 true

			--if classOf curr_mod != Editable_Poly then
				--this.obj = obj.baseobject

			true --return
		)
		else
		(
			messageBox "Select Editable Poly Object" title:"VertexColorProcessor"

			false --return
		)
	),

	/** Set vertex color
	 */
	function setVertexColor verts clr =
	(
		--format "4) --------------- SET VERTEX COLOR\n"

		--format "\n"; print "VertexColorProcessor_v.setVertexColor()"
		--format "obj: %\n" obj
		--format "verts: %\n" verts
		--format "clr: %\n" clr
		--format "VertexColors: %\n" VertexColors
		VertexColors.MeshVertToColorVertexConvert.get_single_vert = true

		verts_base = this._getBaseObjectVerts(verts)
		--format "VERTS_BASE: %\n" verts_base

		start_map_verts = timeStamp()
		--format "start_map_verts()\n"


		vertex_count	= getNumVerts obj.mesh
		CPV_verts 	= getNumCPVVerts obj.mesh

		--format "vertex_count: %\n" vertex_count
		--format "CPV_verts: %\n" CPV_verts

		 if getNumVerts obj.baseobject.mesh != getNumCPVVerts obj.baseobject.mesh then
			this.resetCPVVerts()

		--map_verts = (VertexColors.MeshVertToColorVertexConvert.meshVertsToMapVerts (verts_base) flat:true )

		--start_update_chache = timeStamp()
		this._updateCache(verts_base)(clr as string )
		--format "update_chache: % ms\n" (( timeStamp()) - start_update_chache)

		--start_setVertColor = timeStamp()
		polyop.setVertColor obj 0 verts_base (clr)
		--format "setVertColor: % ms\n" (( timeStamp()) - start_setVertColor)
	),

	/** Process operation on verts by vertex color
	 */
	function byColor method colors =
	(
		--format "\n"; print "VertexColorProcessor_v.byColor()"
		--format "colors: %\n" colors

		verts_by_colors = #{}

		all_verts_by_colors = VertexColors.getVertsAndColors()

		if classOf colors != Array then colors = #(colors)

		for clr in colors where (verts_of_color = all_verts_by_colors[ clr as string ]) != undefined do
			verts_by_colors += verts_of_color

		this._callMethod (method) (verts_by_colors)
	),

	/** Process operation on verts by vertex color of given verts
	 */
	function byVerts method verts =
	(
		--format "\n"; print "VertexColorProcessor_v.byVerts()"
		--format "method: %\n" method
		--format "verts: %\n" verts

		verts_by_colors = #{}

		all_verts_by_colors = VertexColors.getVertsAndColors()
		--for colors_data in all_verts_by_colors do format "COLOR: %	VERTS: %\n" colors_data.key colors_data.value

		for clr in all_verts_by_colors.keys where not ( all_verts_by_colors[clr] * verts ).isEmpty do
			verts_by_colors += all_verts_by_colors[clr]

		this._callMethod (method) (verts_by_colors)
	),

	/** Reset vertex colors channel
	 */
	function resetCPVVerts =
	(
		--format "\n"; print "VertexColorProcessor_v.resetCPVVerts()"
		--format "\n----------\nRESET CPV VERTS\n"
		/* GET ALL VERTS SORTED BY COLORS */
		colors = VertexColors.getVertsAndColors()

        polyOp.defaultMapFaces obj 0
        polyOp.setVertColor obj 0 #all white

		removeDictValue colors (white as string )

		--for colors_data in colors do format "\n********\n\nCOLOR: %\nVERTS: %\n" colors_data.key colors_data.value

		for colors_data in colors do
			this.setVertexColor colors_data.value (execute colors_data.key)
	),

	private

	/** Call method
	 */
	function _callMethod method verts =
	(
		--format "\n"; print "VertexColorProcessor_v._callMethod()"

		subObjectLevel = 1

		case method of
		(
			 #SELECT:	this._selectVerts	(verts)
			 #HIDE:	this._hideVerts	(verts)
			 #UNHIDE:	this._unhideVerts	(verts)
			 #ISOLATE:	this._isolateVerts	(verts)
		)


	),

	/**  hide verts
	 */
	function _hideVerts verts =
	(
		--format "\n"; print "VertexColorProcessor_v._HideVerts()"

		if classOf curr_mod == Edit_Poly then
		(
			curr_mod.SetSelection #VERTEX #{}

			curr_mod.Select #VERTEX verts

			curr_mod.ButtonOp #HideVertex
		)
		else if classOf curr_mod  == Editable_Poly then
			polyop.setHiddenVerts curr_mod verts

	),

	/**  unhide verts
	 */
	function _unhideVerts verts_unhide =
	(
		--format "\n"; print "VertexColorProcessor_v._unhideVerts()"

		if classOf curr_mod == Edit_Poly then
		(
			verts_mesh	= #{1..( getNumVerts obj.mesh)}

			curr_mod.SetSelection #VERTEX verts_mesh

			visible_verts	= curr_mod.GetSelection #Vertex

			hidden_verts = verts_mesh - visible_verts

			curr_mod.ButtonOp #UnhideAllVertex

			curr_mod.SetSelection #VERTEX #{}

			curr_mod.Select #VERTEX (hidden_verts - verts_unhide)

			curr_mod.ButtonOp #HideVertex
		)
		else if classOf curr_mod  == Editable_Poly then
		(
			--verts_mesh	= #{1..( getNumVerts obj.mesh)} as Array
			vertex_sel	= getVertSelection obj.mesh

			hidden_verts = 	polyop.getHiddenVerts obj

			polyop.unHideAllVerts obj

			polyop.setHiddenVerts obj ( hidden_verts - verts_unhide )
		)

	),

	/**  hide verts
	 */
	function _isolateVerts isolate_verts =
	(
		--format "\n"; print "VertexColorProcessor_v._HideVerts()"
		verts_mesh	= #{1..( getNumVerts obj.mesh)}

		if classOf curr_mod == Edit_Poly then
			curr_mod.ButtonOp #UnhideAllVertex

		else if classOf curr_mod  == Editable_Poly then
			polyop.unHideAllVerts obj

		this._hideVerts( verts_mesh - isolate_verts )

	),

	fn round p3 dp =
	(
		local tempArr = #(p3.x,p3.y,p3.z)
		local mult = 10.00^(dp as float)
		local rp3Arr = for c in tempArr collect ((floor ((c * mult)+0.5)) / mult)
		point3 rp3Arr[1] rp3Arr[2] rp3Arr[3]
	),

	/** Pass vertex selection to editable poly
	  *
	  * 1) Get selected verts in modifier like Edit Poly|Poly Select
	  * 2) Find same vertex by position in Editable Poly baseobject
	  *
	  * #return BitArray of vertex indexes of Editable Poly Baseobject
	 */
	function _getBaseObjectVerts verts =
	(
		format "\n"; print "VertexColorProcessor_v.getBaseObjectVerts()"
		----format "verts: %\n" verts
		--format "classof curr_mod: %\n" (classof curr_mod)

		if classof curr_mod != Editable_Poly then
		(
			verts_baseobject = #()

			verts_mesh_all	= #{1..( getNumVerts obj.mesh  )} as Array
			verts_base_all	= #{1..( polyop.getNumVerts obj.baseobject)} as Array

			verts_pos_baseobjects = polyop.getVerts obj.baseobject verts_base_all --node:obj
			--verts_pos_baseobjects = in coordsys world (for vert_pos in verts_pos_baseobjects collect round(vert_pos) 3)

			--format "verts_pos_baseobjects[10203]: %\n" verts_pos_baseobjects[10203]
			--format "VERTS_POS_BASEOBJECTS: %\n" verts_pos_baseobjects

			if verts.count > 0 then
			(
				verts_sel_pos  = for vert in verts collect getVert obj.mesh vert
				--format "verts_sel_pos: %\n" verts_sel_pos
				--verts_sel_pos  = for vert in verts collect round (getVert obj.mesh vert) 3

				for vert_pos in verts_sel_pos where (index = findItem verts_pos_baseobjects (vert_pos)) > 0 do
					append verts_baseobject index
			)
			--format "VERTS_BASEOBJECT: %\n" verts_baseobject

			verts_baseobject --return
		)
		else
			verts --return
	),

	/** Select final selection
	 */
	function _selectVerts sel_bitarray =
	(
		--format "\n"; print "VertexColorProcessor_v.selectVerts()"
		--format "sel_bitarray: %\n" sel_bitarray
		--format "classOf curr_mod: %\n" (classOf curr_mod)
		--max modify mode
		--subObjectLevel = 1

		curr_mod.SetSelection #VERTEX #{}

		if classOf curr_mod == Edit_Poly then
			curr_mod.Select #VERTEX sel_bitarray

		else if classOf curr_mod  == Editable_Poly then
			curr_mod.SetSelection #VERTEX sel_bitarray
	),

	/** Update cache
	 */
	function _updateCache verts clr =
	(
		--format "\n"; print "VertexColorProcessor_v._updateCache()"

		pointer = (getHandleByAnim obj) as string

		if (colors_cahce = VERTEX_COLORS_CACHE[pointer]) != undefined then
		(
			colors = VERTEX_COLORS_CACHE[pointer] = VertexColors.getAllVertsAndColors()


			/* remove verts from other colors */
			for _color in colors.keys do VERTEX_COLORS_CACHE[pointer][_color] -= verts

			/* remove verts from other colors */
			for colors_data in colors where colors_data.value.isEmpty do removeDictValue VERTEX_COLORS_CACHE[pointer] colors_data.key

			/* add verts to color */
			if colors[clr] == undefined then
				VERTEX_COLORS_CACHE[pointer][clr] = verts
			else
				VERTEX_COLORS_CACHE[pointer][clr] += verts

			--for colors_data in VERTEX_COLORS_CACHE[pointer] do format "COLOR: %	VERTS: %\n" colors_data.key colors_data.value

			VERTEX_COLORS_CACHE[pointer] --return
		)
		else
			colors_cahce --return
	),

	/**
	 */
	on create do
	(
		--format "1) --------------- VERTEXCOLOR\n"
		--format "obj: %\n" obj
		curr_mod	= modPanel.getCurrentObject()
		--format "curr_mod: %\n" curr_mod

		if this._initObject() then
			VertexColors	= VertexColors_v(obj)

		--MeshVertToColorVertexConvert	= MeshVertToColorVertexConvertor_v(obj)

		--VertexColors.MeshVertToColorVertexConvert = MeshVertToColorVertexConvert
	)
)
