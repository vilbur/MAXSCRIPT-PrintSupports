clearListener(); print("Cleared in:"+getSourceFileName())


	_objects = selection as Array

	source_objects = SUPPORT_MANAGER.getObjectsByType ( _objects ) type:#SOURCE -- hierarchy:shift

	format "source_objects: %\n" source_objects


	supports = SUPPORT_MANAGER.getObjectsByType _objects type:#SUPPORT

	format "supports: %\n" supports

	SourceObjects = SUPPORT_MANAGER.getSourceObjects source_objects

	for SourceObject in SourceObjects do
	(
		--format "SourceObject: %\n" SourceObject
		indexes =( for index in SourceObject.Supports.keys where SourceObject.Supports[index].support_obj.isSelected collect index) as BitArray

		format "indexes: %\n" indexes

		obj = SourceObject.obj.baseobject

		max modify mode

		verts_hidden = polyop.getHiddenVerts obj

		polyop.setHiddenVerts obj (verts_hidden - indexes )

		obj.SetSelection #VERTEX indexes

	)

	if SourceObjects.count == 1 then
	(
		select SourceObjects[1].obj

		subObjectLevel = 1
	)
	else if SourceObjects.count > 1 then
		select ( 	for SourceObject in SourceObjects collect SourceObject.obj )
