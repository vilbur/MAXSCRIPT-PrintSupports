/** Islands callbacks
 */
struct IslandsCallbacks_v
(
	/* construct */


	/* required */


	/* properties */


	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Slider changed
	 */
	function onSliderChanged slider_val =
	(
		format "\n"; print "IslandsCallbacks_v.sliderChanged()"
		format "slider_val: %\n" slider_val
		_listbox = this._listbox()

		item = _listbox.items.count - slider_val


		--_listbox.selection =	 #{1.._listbox.items.count}
		_listbox.selection = #{item}

		--select_whole_island = DIALOG_island_manager.RB_slider_mode.state
		--
		--island_data = islands_data[item]
		--
		--if island_data[#NEW_ISLAND] != undefined then
		--(
		--	--verts = islands_data[#WHOLE_ISLAND]
		--	--verts = islands_data[#NEW_ISLAND]
		--	verts = this.getVertsFromIslandData (island_data)
		--
		--	if keyboard.shiftPressed then
		--		verts += polyop.getVertSelection obj
		--
		--	--format "VERTS: %\n" verts
		--	this.selectIslandsVerts (verts)
		--
		--)

		--this.selectIslandByLayerInListbox (item)
	),

	/** On listbox item selected
	 */
	function onListboxSelectionEnd =
	(
		format "\n"; print "IslandsCallbacks_v.onListboxSelectionEnd()"
		format "EventFired	= % \n" EventFired

		selected_islands = ISLANDS_SYSTEM.selectIslandsOfVerts()

		/* UPDATE SLIDER */
		if selected_islands.count > 0 then
			DIALOG_island_manager.SLIDER_island_select.value = selected_islands[selected_islands.count] - 1
	),


	/** Update island selection by radiobuttons state
	 */
	function updateIslandSelectionByRadiobuttonsState =
	(
		format "\n"; print "IslandsCallbacks_v.updateIslandSelectionByRadiobuttonsState()"

		islands_states = #( #NEW_ISLAND, #LOWEST_VERT, #WHOLE_ISLAND )

		ISLANDS_SYSTEM.selectVertsOfIslands ( islands_states[DIALOG_island_manager.RB_slider_mode.state +1] )
	),


	/** Select all islands in listbox
	 */
	function selectAllIslandsInListbox =
	(
		--format "\n"; print "IslandsCallbacks_v.selectAllIslandsInListbox()"
		_listbox = this._listbox()

		_listbox.selection = #{1.._listbox.items.count}

		ISLANDS_SYSTEM.updateIslandSelectionByRadiobuttonsState()
	),

	private

	/** Get selected islands from list box
	 */
	function _getSelectedIslandsFromListBox =
	(
		--format "\n"; print "._getSelectedIslandsFromListBox()"
		selected_islands = #{}

		if DIALOG_island_manager != undefined then
		(
			_listbox = this._listbox()

			list_items = _listbox.items
			items_count = _listbox.items.count
			items_sel = _listbox.selection

			/* FLIP INDEX - first item == last siland */

			selected_islands = ( for i = 1 to list_items.count where items_sel[i] collect this._getIslandIndexFromTitle(list_items[i])) as BitArray
			--format "SELECTED_ISLANDS: %\n" selected_islands
		)

		selected_islands --return
	),

	/** Listbox
	 */
	function _listbox =
	(
		--format "\n"; print "IslandsCallbacks_v._listbox()"
		DIALOG_island_manager.ML_island_listbox --return
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "IslandsCallbacks.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
