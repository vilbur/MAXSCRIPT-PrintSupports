/** Islands rc menu callbacks
 */
struct IslandsRcMenuCallbacks_v
(
	/* construct */

	/* required */

	/* properties */

	/* private */
	/* dependency */
	/* reference */
	/* inhered */
	/** Select all islands in listbox
	 */
	function selectAllIslandsInListbox =
	(
		--format "\n"; print "IslandsSystem_v.selectAllIslandsInListbox()"
		DIALOG_island_manager.ML_island_listbox.selection = #{1..DIALOG_island_manager.ML_island_listbox.items.count}

		::IslandsCallbacks_v.updateIslandSelectionByRadiobuttonsState()
	),

	/** Select islands by verts
	 */
	function selectIslandsByVerts =
	(
		--format "\n"; print "IslandsRcMenuCallbacks_v.selectIslandsByVerts()"
		verts_sel = getVertSelection selection[1].mesh

		islands_data = ISLANDS_SYSTEM.islands_data

		verts_of_islands = #{}

		islands_of_verts = ( for i = 1 to islands_data.count where not (islands_data[i][#NEW_ISLAND] * verts_sel ).isEmpty collect i) as BitArray

		for index in islands_of_verts do verts_of_islands += islands_data[index][#NEW_ISLAND]


		if classOf (_mod = modPanel.getCurrentObject()) == Edit_Poly then
			_mod.Select #VERTEX verts_of_islands

		else if classOf _mod  == Editable_Poly then
			_mod.SetSelection #VERTEX verts_of_islands


		DIALOG_island_manager.ML_island_listbox.selection = ISLANDS_SYSTEM.getListboxItemsByIslandsIndex (islands_of_verts)
	),

	/** Select islands by size
	 */
	function selectIslandsBySize size =
	(
		--format "\n"; print "IslandsRcMenuCallbacks_v.selectIslandsBySize()"
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
			else
				false -- return fallback
		)

		islands_data = ISLANDS_SYSTEM.islands_data
		--islands_by_size = for i = islands_data.count to 1 by -1 where islands_data[i][#SIZE] != undefined and  islands_data[i][#SIZE] > 2 collect i
		size_min = DIALOG_island_manager.SPIN_island_size_min.value
		size_max = DIALOG_island_manager.SPIN_island_size_max.value

		/* GET ISLANDS MATHING SIZE */
		islands_by_size = (for i = 1 to islands_data.count where isIslandMatchinSize islands_data[i][#SIZE] size size_min size_max collect i) as BitArray

		DIALOG_island_manager.ML_island_listbox.selection = ISLANDS_SYSTEM.getListboxItemsByIslandsIndex (islands_by_size)

		--::IslandsCallbacks_v.updateIslandSelectionByRadiobuttonsState()

		::IslandsCallbacks_v.onListboxSelectionEnd()
	),

	/** Select verts of islands
	 */
	function selectVertsOfIslands vertex_type =
	(
		--format "\n"; print "IslandsRcMenuCallbacks_v.selectVertsOfIslands()"

		format "vertex_type: %\n" (classOf vertex_type)
		islands_data = ISLANDS_SYSTEM.islands_data

		selected_islands = ISLANDS_SYSTEM.getSelectedIslandsFromListBox()

		_listbox = DIALOG_island_manager.ML_island_listbox

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
			ISLANDS_SYSTEM.selectIslandsVerts( verts as BitArray )
	),

	/** Isolate slected islands
	 */
	function isolateSlectedIslands state =
	(
		format "\n"; print "IslandsSystem_v.isolateSlectedIslands()"
		--format "state: %\n" state
		obj	= selection[1]

		if state then
		(
			selected_islands = ( ISLANDS_SYSTEM.getSelectedIslandsFromListBox() ) as Array

			verts = ISLANDS_SYSTEM.getVertsOfIslands(selected_islands)

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

	/** Invert selection
	 */
	function invertSelection =
	(
		--format "\n"; print "IslandsCallbacks_v.invertSelection()"

		_listbox = DIALOG_island_manager.ML_island_listbox

		_listbox.selection = -_listbox.selection
	),

	/** Remove selected islands
	 */
	function removeSelectedIslands =
	(
		--format "\n"; print "IslandsRcMenuCallbacks_v.removeSelectedIslands()"
		format "\n"; print "IslandsSystem_v.removeSelectedIslands()"
		obj	= selection[1]

		selected_islands = ( ISLANDS_SYSTEM.getSelectedIslandsFromListBox() )

		if selected_islands.numberSet > 0 and queryBox ("REMOVE SELECTED ISALNDS FROM OBJECT ?\n\n"+obj.name) title:"REMOVE ISLANDS" then
		(


			if ( islands_props_data = getUserPropVal obj "ISLANDS_DATA" ) != undefined then
			(
				format "islands_props_data.count: %\n" islands_props_data.count

				for i = islands_props_data.count to 1 by -1 where selected_islands[i] do
					deleteItem islands_props_data i

				setUserPropVal obj "ISLANDS_DATA" islands_props_data
			)

			--selected_items = DIALOG_island_manager.ML_island_listbox.selection as Array

			macros.run "maxtoprint" "maxtoprint_islands_dialog"
		)
	),

	/** Slice at island
	 */
	function sliceAtIsland =
	(
		format "\n"; print "IslandsCallbacks_v.sliceAtIsland()"
		_listbox = DIALOG_island_manager.ML_island_listbox
		--format "_listbox.items: %\n" _listbox.items
		islands_layers = (for item in _listbox.items collect (filterString item " ")[1] as integer ) --as BitArray -- get list items strings to bitarray

		--format "islands_layers: %\n" islands_layers
		--format "_listbox.selection.count: %\n" _listbox.selection.count
		layer_of_island = (islands_layers)[( _listbox.selection as Array )[1] ]

		SLICER_SYSTEM.setSlicePlaneModifier (#SLICE_PLANE_TOP) (#TRUE) (layer_of_island) (true)
		--format "LAYER_OF_ISLAND: %\n" layer_of_island
	),

	--/** Create island manager dialog only selected islands
	-- */
	--function createIslandManagerDialogOnlySelectedIslands =
	--(
	--	--format "\n"; print "IslandsRcMenuCallbacks_v.createIslandManagerDialogOnlySelectedIslands()"
	--	selected_islands = ISLANDS_SYSTEM.getSelectedIslandsFromListBox()
	--
	--	islands_to_show = case of
	--	(
	--		(relaunch and selected_islands.numberSet >  1):	selected_islands                     -- SHOW ONLY SELECTED ITEMS ON RELAUNCH
	--		(relaunch and selected_islands.numberSet == 1):	#{(ISLANDS_SYSTEM.getFirstIslandFromListbox())..(selected_islands as Array )[1]} -- SHOW ISLANDS UP TO SELECTED ITEM ON RELAUNCH IF ONLY SINGLE ISLAND IS SELECTED
	--		default:	#{1..ISLANDS_SYSTEM.islands_data.count}             -- SHOW ALL ISLANDS
	--	)
	--
	--	createIslandManagerDialog islands_to_show:(ISLANDS_SYSTEM.getIslandsToShowBySlection())
	--),

	private


	/**
	 */
	on create do
	(
		--format "\n"; print "IslandsRcMenuCallbacks.onCreate()"
		--for prop in #(  ) where getProperty ISLANDS_SYSTEM prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of ISLANDS_SYSTEM struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof ISLANDS_SYSTEM as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
