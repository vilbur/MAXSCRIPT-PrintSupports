
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

	/** Select islands of verts
	 */
	function selectIslandsOfVerts =
	(
		--format "\n"; print "IslandsSystem_v.selectIslandsOfVerts()"
		selected_islands = ( this.getSelectedIslandsFromListBox() ) as Array

		verts = this._getVertsOfSelectedIslands(selected_islands)

		/* SLECT VERTS OF SELECTED ISLANDS */
		this.selectIslandsVerts (verts)

		selected_islands --return
	),

	/** Select first verts
	 */
	function selectVertsOfIslands vertex_type =
	(
		format "\n"; print ".selectVertsOfIslands()"
		format "vertex_type: %\n" (classOf vertex_type)
		_listbox = DIALOG_island_manager.ML_island_listbox

		selected_islands = this.getSelectedIslandsFromListBox()

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

		if verts.numberSet > 0 then
			this.selectIslandsVerts( verts as BitArray )
	),

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

	/** Get layer of island
	 */
	function getLayerOfClosestIsland layer_current increment =
	(
		format "\n"; print "SlicerCallbacks_v.getLayerOfClosestIsland()"
		format "layer_current: %\n" layer_current
		islands_layers = (for item in DIALOG_island_manager.ML_island_listbox.items collect (filterString item " ")[1] as integer ) as BitArray -- get list items strings to bitarray
		format "ISLANDS_LAYERS: %\n" islands_layers
		--format "islands_layers.count: %\n" islands_layers.count


		layer_next = layer_current + increment

		if layer_next < 1 then layer_next = 1

		--format "layer_current: %\n" layer_current
		--format "layer_next: %\n" layer_next
		--format "TEST: %\n" (increment > 0 and layer_current < islands_layers.count)
		--format "islands_layers[layer_next]: %\n" islands_layers[layer_next]


		if islands_layers[layer_next] == false then
		(
			/* GO ISLAND UP */
			if increment > 0 and layer_current < islands_layers.count then
				for i = layer_next to islands_layers.count while not islands_layers[i] do
					layer_next = i + 1

			/* GO ISLAND DOWN */
			else if increment < 0 and layer_current > 1  then
				for i = layer_next to 1 by -1 while not islands_layers[i]  do
					layer_next = i - 1

		)

		format "LAYER_NEXT: %\n" layer_next
		--format "LAYER_NEXT: %\n" layer_next
		--
		--if DIALOG_island_manager != undefined and layer_next > 0 then
		--	this.selectIslandByLayerInListbox (layer_next)

		layer_next
	),

	--/** Select all islands in listbox
	-- */
	--function selectAllIslandsInListbox =
	--(
	--	--format "\n"; print "IslandsSystem_v.selectAllIslandsInListbox()"
	--	DIALOG_island_manager.ML_island_listbox.selection = #{1..DIALOG_island_manager.ML_island_listbox.items.count}
	--
	--	this.updateIslandSelectionByRadiobuttonsState()
	--),

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
			all_verts = #{1..(getNumVerts obj.mesh)}

			hidden_verts =	( polyop.getHiddenVerts obj ) - verts

			/* HIDE HIDDEN VERTS OR ISOALTE ONLY SELECTED */
			if hidden_verts.numberSet > 0 or isolate then
			(
				polyop.unHideAllVerts obj

				hidden_verts = if isolate == 1 then (all_verts - verts)

				polyop.setHiddenVerts obj hidden_verts
			)

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
			verts_base_hidden	= polyop.getHiddenVerts obj.baseobject

			/* GET EDIT POLY VERTS */
			if verts_base_all.numberSet != verts_mesh_all.numberSet then
				verts = getVertsByBaseobject(obj)(verts)(verts_mesh_all)

			if not isolate then
			(
				actionMan.executeAction 0 "40021"  -- Selection: Select All

				visible_verts	= (getVertSelection obj.mesh) + verts

				_mod.ButtonOp #UnhideAllVertex

				_mod.SetSelection #VERTEX #{}

				_mod.Select #VERTEX visible_verts

				_mod.ButtonOp #HideUnselectedVertex

				_mod.SetSelection #VERTEX #{}

				_mod.Select #VERTEX verts
			)
			else /* UNHIDE ONLY SELECTED VERTS */
			(
				_mod.ButtonOp #UnhideAllVertex

				_mod.SetSelection #VERTEX #{}

				_mod.Select #VERTEX verts

				_mod.ButtonOp #HideUnselectedVertex

			)
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

		items = this._getIslandByLayer (layer_indexes)
		--format "ITEMS: %\n" items
		--format "TICKS: %\n" (DIALOG_island_manager.SLIDER_island_select.ticks )
		--format "items.count: %\n" items.count


		DIALOG_island_manager.ML_island_listbox.selection = items

		if ( slider_value = DIALOG_island_manager.ML_island_listbox.items.count - items.count  ) > 0 then
			DIALOG_island_manager.SLIDER_island_select.value = slider_value
	),

	/** Select islands by size
	 */
	function selectIslandsBySize size =
	(
		format "\n"; print "IslandsSystem_v.selectIslandsBySize()"

		/** Is island matchin size
		 */
		function isIslandMatchinSize island_size size size_min size_max =
		(
			--format "\n"; print ".isIslandMatchinSize()"
			--format "island_size: %\n" island_size
			--format "size: %\n" size

			if island_size == undefined and size == #SMALL then
				true --return

			else if island_size != undefined then
			(
				case size of
				(
					(#SMALL):	island_size.x <= size_min or  island_size.y <= size_min
					(#MEDIUM):	(island_size.x > size_min and island_size.x < size_max) or (island_size.y > size_min and island_size.y < size_max)
					(#BIG):	island_size.x >= size_max or  island_size.y >= size_max
				)
			)
		)

		--islands_by_size = for i = islands_data.count to 1 by -1 where islands_data[i][#SIZE] != undefined and  islands_data[i][#SIZE] > 2 collect i
		size_min = DIALOG_island_manager.SPIN_island_size_min.value
		size_max = DIALOG_island_manager.SPIN_island_size_max.value

		/* GET ISLANDS MATHING SIZE */
		islands_by_size = (for i = 1 to islands_data.count where isIslandMatchinSize islands_data[i][#SIZE] size size_min size_max collect i) as BitArray

		DIALOG_island_manager.ML_island_listbox.selection = this._getListboxItemsByIslandsIndex (islands_by_size)

		this.updateListboxCallback()
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

			setUserPropVal obj "ISLANDS_DATA" islands_props_data
		)

		--selected_items = DIALOG_island_manager.ML_island_listbox.selection as Array

		macros.run "maxtoprint" "maxtoprint_islands_dialog"
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
