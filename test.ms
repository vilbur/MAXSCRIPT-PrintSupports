clearListener(); print("Cleared in:"+getSourceFileName())


temp = #(#{21..24}, #{21..22, 140..141}, #{139..140, 142..143}, #{67, 133, 181}, #{67, 140, 143, 181}, #{21, 24, 133, 181}, #{62, 139..140, 190}, #{140..141, 165, 190}, #{57, 96, 98}, #{22..23, 90..91}, #{22, 91, 141}, #{21, 140, 181})


function _mergeBitArraysbySharedBits bitarrays =
(
	--format "\n"; print "VertSelector_v._mergeBitArraysbySharedBits()"

	for x = bitarrays.count to 1 by -1 do
	(
		--format "x: %\n" x
		merged = false

		bitarrays_x = bitarrays[x]
		--for y = bitarrays.count to 1 by -1 while where x != y and not ( bitarrays_x * bitarrays[y] ).isEmpty do
		--for y = bitarrays.count to 1 by -1 where x != y and not ( bitarrays_x * bitarrays[y] ).isEmpty do

		--for y = bitarrays.count to 1 by -1 where x != y and ( bitarrays_x * bitarrays[y] ).numberSet > 1 do
		--for y = bitarrays.count to 1 by -1 while not merged where x != y and ( bitarrays_x * bitarrays[y] ).numberSet > 1 do

		--for y = bitarrays.count to 1 by -1 while not merged where x != y and ( bitarrays_x * bitarrays[y] ).numberSet > 0 do
		for y = bitarrays.count to 1 by -1 where x != y and ( bitarrays_x * bitarrays[y] ).numberSet > 0 do
		(
			bitarrays[y] += bitarrays[x]

			merged = true

			--gc light:true
		)

		if merged then
			deleteItem bitarrays x
	)

	bitarrays --return
)

--result = _mergeBitArraysbySharedBits (temp)

haystack = #{1..10}
needle = #{11}

/** Bitarrays match
 */
function _bitarraysMatch haystack needle =
(
	--format "\n"; print "VertIslandFinder_v.bitarraysMatch()"
	found = false

	for vert in needle while not found where haystack[vert] do found = true

	found --return
)

format "test: %\n" (_bitarraysMatch haystack needle)
