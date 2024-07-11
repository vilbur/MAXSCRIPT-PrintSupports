clearListener(); print("Cleared in:"+getSourceFileName())



rollout test "Test"
   (
		spinner ball_radius "Ball radius" range:[0,1000,1]

on ball_radius buttonup   inCancel do
--format "inSpin_arg: %\n" inSpin_arg
format "inCancel: %\n" inCancel



  )
   createDialog test