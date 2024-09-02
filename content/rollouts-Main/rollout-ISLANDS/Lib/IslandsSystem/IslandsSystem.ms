/** Islands system
 */
struct IslandsSystem_v
(
	/* construct */


	/* required */
	obj,

	/* properties */
	islands_data,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Isolate slected islands
	 */
	function isolateSlectedIslands state =
	(
		format "\n"; print "IslandsSystem_v.isolateSlectedIslands()"
		format "state: %\n" state

		if state then
		(
			selected_islands = ( this.getSelectedIslandsFromListBox() ) as Array

			verts = this._getVertsOfSelectedIslands(selected_islands)

			subObjectLevel = 1

			hidden_verts =	( polyop.getHiddenVerts obj) - verts

			polyop.unHideAllVerts obj

			if DIALOG_island_manager.CBTN_isolate.state == 1 then
			(
				all_verts = #{1..(getNumVerts obj.mesh)}

				polyop.setHiddenVerts obj (all_verts - verts)
			)
		)
	),

	/** Select all islands in listbox
	 */
	function selectAllIslandsInListbox =
	(
		--format "\n"; print "IslandsSystem_v.selectAllIslandsInListbox()"
		DIALOG_island_manager.ML_island_listbox.selection = #{1..DIALOG_island_manager.ML_island_listbox.items.count}

		this.updateIslandSelectionByRadiobuttonsState()
	),
	/** Get selected islands from list box
	 */
	function getSelectedIslandsFromListBox =
	(
		--format "\n"; print ".getSelectedIslandsFromListBox()"
		selected_islands = #{}

		if DIALOG_island_manager != undefined then
		(
			_listbox = DIALOG_island_manager.ML_island_listbox

			list_items = _listbox.items
			items_count = _listbox.items.count
			items_sel = _listbox.selection

			/* FLIP INDEX - first item == last siland */

			selected_islands = ( for i = 1 to list_items.count where items_sel[i] collect this._getIslandIndexFromTitle(list_items[i])) as BitArray
			--format "SELECTED_ISLANDS: %\n" selected_islands
		)

		selected_islands --return
	),

	/** Get first island from listbox
	 */
	function getFirstIslandFromListbox =
	(
		--format "\n"; print ".getFirstIslandFromListbox()"
		_listbox = DIALOG_island_manager.ML_island_listbox

		this._getIslandIndexFromTitle (_listbox.items[_listbox.items.count]) --return
	),
	/** Select layer
	 */
	function selectIslandBySlider slider_val =
	(
		format "\n"; print "IslandsSystem_v.selectIslandBySlider()"
		--format "slider_val: %\n" slider_val

		if slider_val == undefined then
			slider_val = DIALOG_island_manager.SLIDER_island_select.value

		--obj	= selection[1]

		layer_index = slider_val + 1
		--format "layer_index: %\n" layer_index
		select_whole_island = DIALOG_island_manager.RB_slider_mode.state
		--format "select_whole_island: %\n" select_whole_island
		--format "BOTTOM: %\n" islands_data[#BOTTOM][layer_index]
		--format "NEW_ISLAND:   %\n" islands_data[#NEW_ISLAND][layer_index]
		--format "WHOLE_ISLAND: %\n" islands_data[#WHOLE_ISLAND][layer_index]

		island_data = islands_data[layer_index]
		--format "island_data: %\n" island_data
		--format "island_data[#WHOLE_ISLAND]: %\n" island_data[#WHOLE_ISLAND]

		if island_data[#NEW_ISLAND] != undefined then
		(
			--verts = islands_data[#WHOLE_ISLAND]
			--verts = islands_data[#NEW_ISLAND]
			verts = this.getVertsFromIslandData (island_data)

			if keyboard.shiftPressed then
				verts += polyop.getVertSelection obj

			--format "VERTS: %\n" verts
			this.selectIslandsVerts (verts)

		)

		this.selectIslandByLayerInListbox (layer_index)
	),

	/** Select layer
	 */
	function updateListboxCallback =
	(
		format "\n"; print "IslandsSystem_v.updateListboxCallback()"
		--format "EventFired	= % \n" EventFired
		selected_islands = ( this.getSelectedIslandsFromListBox() ) as Array

		verts = this._getVertsOfSelectedIslands(selected_islands)

		/* SLECT VERTS OF SELECTED ISLANDS */
		this.selectIslandsVerts (verts)

		/* UPDATE SLIDER */
		if selected_islands.count > 0 then
			DIALOG_island_manager.SLIDER_island_select.value = selected_islands[selected_islands.count] - 1
	),

	/** Toggle select island mode
	 */
	function toggleSelectIslandMode =
	(
		--format "\n"; print ".toggleSelectIslandMode()"
		--format "DIALOG_island_manager.RB_slider_mode.state: %\n" DIALOG_island_manager.RB_slider_mode.state
		--DIALOG_island_manager.RB_slider_mode.state = not DIALOG_island_manager.RB_slider_mode.state
		--format "DIALOG_island_manager.RB_slider_mode_last_state: %\n" DIALOG_island_manager.RB_slider_mode_last_state
		--format "DIALOG_island_manager.RB_slider_mode.state: %\n" DIALOG_island_manager.RB_slider_mode.state

		DIALOG_island_manager.RB_slider_mode.state = case DIALOG_island_manager.RB_slider_mode.state of
		(
			0:	1
			1:	2
			2:	0
		)
	),

	/** Get verts from island data
	 */
	function getVertsFromIslandData island_data =
	(
		--format "\n"; print ".getVertsFromIslandData()"
		--format "STATE: %\n" (DIALOG_island_manager.RB_slider_mode.state)
		case DIALOG_island_manager.RB_slider_mode.state of
		(
			0:	island_data[#NEW_ISLAND]
			1:	#{island_data[#LOWEST_VERT]}
			2:	if island_data[#WHOLE_ISLAND] != undefined then island_data[#WHOLE_ISLAND] else island_data[#NEW_ISLAND]
		)

	),

	/** Select islands verts
	 */
	function selectIslandsVerts verts =
	(
		format "\n"; print "IslandsSystem_v.selectIslandsVerts()"
		format "verts: %\n" verts


		/** Select verts editable poly
		 */
		function selectVertsEditablePoly obj verts isolate =
		(
			--format "\n"; print "IslandsSystem_v.selectVertsEditablePoly()"


			hidden_verts =	( polyop.getHiddenVerts obj) - verts

			polyop.unHideAllVerts obj

			if DIALOG_island_manager.CBTN_isolate.state == 1 then
			(
				all_verts = #{1..(getNumVerts obj.mesh)}

				polyop.setHiddenVerts obj (all_verts - verts)
			)
			else
				polyop.setHiddenVerts obj (hidden_verts - verts) -- unhide selected verts


			obj.baseobject.SetSelection #Vertex #{}

			obj.baseobject.SetSelection #VERTEX verts
		)

		/** Select verts edit poly
		 */
		function selectVertsEditPoly _mod verts isolate =
		(
			--format "\n"; print "IslandsSystem_v.selectVertsEditablePoly()"
			/** Pass vertex selection from editable poly baseobject to edit poly modifier based on vertex position
			  *
			  * #return BitArray of vertex indexes of Edit Poly Modifier
			 */
			function getVertsByBaseobject obj verts_baseobject verts_mesh_all =
			(
				format "\n"; print "VertexColorProcessor_v.getBaseObjectVerts()"
				verts_edit_poly = #()

				verts_pos_baseobjects = polyop.getVerts obj.baseobject verts_baseobject --node:obj

				verts_mesh_pos  = for vert in verts_mesh_all collect getVert obj.mesh vert

				for vert_pos in verts_pos_baseobjects where (index = findItem verts_mesh_pos (vert_pos)) > 0 do
					append verts_edit_poly index

				verts_edit_poly as BitArray --return
			)


			verts_mesh_all	= #{1..( getNumVerts obj.mesh  )}
			verts_base_all	= #{1..( polyop.getNumVerts obj.baseobject)}

			/* GET EDIT POLY VERTS */
			if verts_base_all.numberSet != verts_mesh_all.numberSet then
				verts = getVertsByBaseobject(obj)(verts)(verts_mesh_all)

			_mod.Select #VERTEX verts
		)

		isolate_verts = DIALOG_island_manager.CBTN_isolate.state == 1

		subObjectLevel = 1

		if classOf (_mod = modPanel.getCurrentObject()) == Editable_Poly then
			selectVertsEditablePoly (obj)(verts)(isolate_verts)

		else if classOf _mod  == Edit_Poly then
			selectVertsEditPoly (_mod)(verts)(isolate_verts)

	),

	/** Select layer listbox
	 */
	function selectIslandByLayerInListbox layer_indexes =
	(
		format "\n"; print "IslandsSystem_v.selectIslandByLayerInListbox()"
		if classOf layer_indexes != BitArray then
			layer_indexes = #{layer_indexes}

		format "layer_indexes: %\n" layer_indexes

		--items = _listbox.items
		--items_count = _listbox.items.count
		--items_sel = _listbox.selection
		--
		--new_index = DIALOG_island_manager.ML_island_listbox.items.count - layer_index + 1
		--
		----format "TEST: %\n" (if keyboard.shiftPressed then items_sel + #{new_index} else new_index)
		--
		--DIALOG_island_manager.ML_island_listbox.selection = if keyboard.shiftPressed then items_sel + #{new_index} else #{new_index}

		--this._getIslandByLayer (layer_indexes)

		DIALOG_island_manager.ML_island_listbox.selection = this._getIslandByLayer (layer_indexes)
	),

	/** Select islands by size
	 */
	function selectIslandsBySize size =
	(
		format "\n"; print "IslandsSystem_v.selectIslandsBySize()"

		/** Is island matchin size
		 */
		function isIslandMatchinSize island_size size =
		(
			--format "\n"; print ".isIslandMatchinSize()"
			--format "island_size: %\n" island_size
			--format "size: %\n" size
			size_min = DIALOG_island_manager.SPIN_island_size_min.value
			size_max = DIALOG_island_manager.SPIN_island_size_max.value

			case size of
			(
				(#SMALL):	island_size.x <= size_min or  island_size.y <= size_min
				(#MEDIUM):	(island_size.x > size_min and island_size.x < size_max) or (island_size.y > size_min and island_size.y < size_max)
				(#BIG):	island_size.x >= size_max or  island_size.y >= size_max
			)

		)

		--islands_by_size = for i = islands_data.count to 1 by -1 where islands_data[i][#SIZE] != undefined and  islands_data[i][#SIZE] > 2 collect i

		/* GET ISLANDS MATHING SIZE */
		islands_by_size = (for i = 1 to islands_data.count where islands_data[i][#SIZE] != undefined and isIslandMatchinSize(islands_data[i][#SIZE])(size) collect i) as BitArray

		DIALOG_island_manager.ML_island_listbox.selection = this._getListboxItemsByIslandsIndex (islands_by_size)

		updateListbox()
	),

	/** Select islands by verts
	 */
	function selectIslandsByVerts =
	(
		--format "\n"; print "IslandsSystem_v.selectIslandsByVerts()"
		verts_sel = polyop.getVertSelection selection[1]

		verts_of_islands = #{}

		islands_of_verts = ( for i = 1 to islands_data.count where not (islands_data[i][#NEW_ISLAND] * verts_sel ).isEmpty collect i) as BitArray

		for index in islands_of_verts do verts_of_islands += islands_data[index][#NEW_ISLAND]


		if classOf (_mod = modPanel.getCurrentObject()) == Edit_Poly then
			_mod.Select #VERTEX verts_of_islands

		else if classOf _mod  == Editable_Poly then
			_mod.SetSelection #VERTEX verts_of_islands


		DIALOG_island_manager.ML_island_listbox.selection = this._getListboxItemsByIslandsIndex (islands_of_verts)

	),


	/** Select first verts
	 */
	function selectVertsOfIslands vertex_type =
	(
		format "\n"; print ".selectVertsOfIslands()"
		format "vertex_type: %\n" (classOf vertex_type)
		_listbox = DIALOG_island_manager.ML_island_listbox

		selected_islands = getSelectedIslandsFromListBox()

		if selected_islands.count == 0 then
			selected_islands = #{1..islands_data.count} as Array

		format "SELECTED_ISLANDS: %\n" selected_islands

		verts = #{}

		for layer_index in selected_islands collect
		(
			if vertex_type == #LOWEST_VERT then
				verts[islands_data[layer_index][vertex_type]] = true

			else if ( island_verts = ISLANDS_DATA[layer_index][vertex_type] ) != undefined then
				verts += island_verts
		)

		this.selectIslandsVerts( verts as BitArray )
	),


	/** Get listbox items by island index
	  *
	  * @prams BitArray indexes of islands from this.islands_data
	  *
	  * @returnn BitArray indexes of listbox items
	 */
	function _getListboxItemsByIslandsIndex island_indexes =
	(
		--format "\n"; print "IslandsSystem_v._getListboxItemsByIslandIndex()"
		--_listbox = DIALOG_island_manager.ML_island_listbox

		list_items = DIALOG_island_manager.ML_island_listbox.items


		( for i = 1 to  list_items.count where island_indexes[ this._getIslandIndexFromTitle list_items[i] ] collect i ) as BitArray
	),

	/** Get island by layer
	 */
	function _getIslandByLayer layer_indexes =
	(
		--format "\n"; print "IslandsSystem_v._getIslandByLayer()"
		--format "layer_indexes: %\n" layer_indexes

		list_items = DIALOG_island_manager.ML_island_listbox.items

		( for i = 1 to  list_items.count where layer_indexes[ this._getIslandLayerFromTitle list_items[i] ] collect i ) as BitArray

	),

	/** Get island item title
	 */
	function _getIslandIndexFromTitle list_item =
	(
		--format "\n"; print "IslandsSystem_v._getIslandIndexFromTitle()"
		( substring list_item (( findString list_item "#" )+1) -1 ) as Number
	),

	/** Get island item title
	 */
	function _getIslandLayerFromTitle list_item =
	(
		--format "\n"; print "IslandsSystem_v._getIslandIndexFromTitle()"
		--format "TEST: %\n" ((filterString list_item " ")[1] as Number)

		(filterString list_item " ")[1] as Number
	),


	/** Remove selected islands
	 */
	function removeSelectedIslands =
	(
		format "\n"; print "IslandsSystem_v.removeSelectedIslands()"

		selected_islands = ( this.getSelectedIslandsFromListBox() )

		format "SELECTED_ISLANDS: %\n" selected_islands

		if ( islands_props_data = getUserPropVal obj "ISLANDS_DATA" ) != undefined then
		(
			format "islands_props_data.count: %\n" islands_props_data.count

			for i = islands_props_data.count to 1 by -1 where selected_islands[i] do
				deleteItem islands_props_data i
			--for island_data in islands_props_data do
				--format "island_data: %\n" island_data

			setUserPropVal obj "ISLANDS_DATA" islands_props_data
		)
	),

	/** Update island selection by radiobuttons state
	 */
	function updateIslandSelectionByRadiobuttonsState =
	(
		format "\n"; print "IslandsSystem_v.updateIslandSelectionByRadiobuttonsState()"

		states = #( #NEW_ISLAND, #LOWEST_VERT, #WHOLE_ISLAND )

		this.selectVertsOfIslands ( states[DIALOG_island_manager.RB_slider_mode.state +1] )
	),


	private

	/** Get verts of selected islands from listbox
	 */
	function _getVertsOfSelectedIslands selected_islands =
	(
		--format "\n"; print "IslandsSystem_v.getVertsOfSelectedIslands()"
		/* FLIP INDEX - first item == last siland */

		verts = #{1..(getNumVerts obj.mesh)} * #{}

		for layer_index in selected_islands do
			verts += this.getVertsFromIslandData (islands_data[layer_index])

		verts --return
	),
	--/** Set islands data
	-- */
	--function setIslandsData =
	--(
	--	--format "\n"; print "IslandsSystem_v.setIslandsData()"
	--
	--),

	/**
	 */
	on create do
	(
		--format "\n"; print "IslandsSystem.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
