/* ISLANDS VIA VERTS */
clearListener(); print("Cleared in:\n"+getSourceFileName())

(
 Event_v type:#rightClick params:"" code:"" callback:Dictionary #name code:"execute "

 struct EventFired_v(Type,Roll,Control, function get prop = ( if hasProperty this ( prop as name ) then getProperty this ( prop as name ) else false  ))"
	 global EventFired = EventFired_v Type:#rightClick Roll:ROLLOUT_subrollout Control:ROLLOUT_subrollout.CBX_checkbox_value
CallbackNoParam();EventFired = undefined" arguments:#()  toolTip:"" autorun:false


)
onCreate() HEIGHT: unsupplied
