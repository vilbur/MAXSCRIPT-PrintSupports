/* ISLANDS VIA VERTS */
clearListener(); print("Cleared in:\n"+getSourceFileName())



/** Select inner upper verts
 */
function selectInnerUpperVerts mode =
(
	--format "\n"; print ".selectInnerUpperVerts()"
	gc light:true

	obj	= selection[1]

	rmgi = RayMeshGridIntersect()

	rmgi.initialize 10
	rmgi.addNode obj
	rmgi.buildGrid()

	direction = point3 0 0 1

	offset = point3 0 0 0.1

	--max modify mode

	subObjectLevel = 1

	if mode == #INNER then
		PolyToolsSelect.Normal 3 15 false

	vertex_sel	= getVertSelection obj.mesh
	--format "vertex_sel.numberSet: %\n" vertex_sel.numberSet

	format "\n\nESTIMATED TIME of processing % vertices: % seconds\n" vertex_sel.numberSet ((vertex_sel.numberSet / 100) as integer )


	vertex_count = getNumVerts obj.mesh

	verts_all = #{1..vertex_count}

	verts_pos = in coordsys world meshop.getVerts obj.mesh verts_all node:obj

	processed = copy verts_all * #{}

	result = #{}

	timer_get_verts = timeStamp()

	for vert in vertex_sel do
	(
		hits = rmgi.intersectRay ( verts_pos[vert] + offset ) direction true
		if( mode == #INNER and hits == 0 ) or ( mode != #INNER and hits > 0 ) then
			result[vert] = true

		--hits = intersectRay obj ( Ray ( verts_pos[vert] + offset ) direction )
		--if( mode == #INNER and hits != undefined ) or ( mode != #INNER and hits == undefined ) then
			--result[vert] = true
	)

	obj.EditablePoly.SetSelection #Vertex #{}
	obj.EditablePoly.SetSelection #Vertex result

)


--selectInnerUpperVerts #INNER
selectInnerUpperVerts #OUTTER
