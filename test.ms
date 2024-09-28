/* ISLANDS VIA VERTS */
clearListener(); print("Cleared in:\n"+getSourceFileName())

--mod_name = #DRAIN_WIDTH
--
--_objects = for obj in selection where obj.modifiers[mod_name] != undefined collect obj
--
--objects_by_mods	=  Dictionary #STRING -- KEY:"modifier pointer" VALUE:#(objects with same instance of modifier )
--
--
--for obj in _objects do
--(
--	mod_pointer = (getHandleByAnim obj.modifiers[mod_name]) as string
--	--format "mod_pointer: %\n" mod_pointer
--
--	if objects_by_mods[mod_pointer] == undefined then
--		objects_by_mods[mod_pointer] = #()
--
--	append objects_by_mods[mod_pointer] obj
--)
--
--
--
--for mod_pointer in objects_by_mods.keys do
--(
--	objects_with_mod = objects_by_mods[mod_pointer]
--
--	_wirecolor = orange
--
--	_wirecolor.hue = ( random 0 255 )
--	_wirecolor.saturation = ( random 128 255 )
--
--	for obj in objects_with_mod do
--		obj.wirecolor = _wirecolor
--)

	my_selection = selection as array
	mode = 1	-- *** 1 = accending | 2 = decending ***

	fn sort_z v1 v2 = (

		if (mode == 1) then result = v1.position.z - v2.position.z
		else if (mode == 2) then result = v2.position.z - v1.position.z
	)

	qsort my_selection sort_z

	--for i in my_selection do print i

	select my_selection