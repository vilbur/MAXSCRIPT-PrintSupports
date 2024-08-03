clearListener(); print("Cleared in:"+getSourceFileName())




obj	= selection[1]


verts = #{1..(getNumVerts obj.mesh)}
--verts	= getVertSelection obj.mesh


timer_polyop = timeStamp()
verts_pos_polyop = in coordsys world polyop.getVerts obj verts node:obj
format "polyop: % ms\n" (( timeStamp()) - timer_polyop)


timer_meshop = timeStamp()
verts_process_pos = in coordsys world meshop.getVerts obj.mesh verts node:obj
format "meshop: % ms\n" (( timeStamp()) - timer_meshop)
