local StreakIcon = require(script.Parent.StreakIcon)
local VehicleIcon = require(script.Parent.VehicleIcon)

local v = {
	Tank = {
		palette = { "212121", "292929", "525a3a", "3a4231", "4a523a", "313131", "636b42", "526342" },
		rows = {
			".......a...............bbbbbaaa............................",
			"......aaccc......bbbbbaaaaadddd............................",
			"...eeeefeggeeeeeeebbbbbeeeeeeeef...........................",
			".bcchhhfhghhhhhhhhfffffhhhhhhhhheeee...........eeee.....ee.",
			".fgghhhhhhhhhhhhhhhhhhhhhhhhhhhhheeeebeeeeebeeeeeeeeebeeeeb",
			".fffhhhhhhhhhhhhhhhhhhhhhhffhhhhheeeebeeeeebeeeeeeeeebeeeeb",
			".fffhhhfhhhhhhhhhfhhhhhhhhhhhhhhhheeddd........eeee........",
			"ffffhhhfffffffffffhhhhhhhhhhhhhhhhhaeeaddd.................",
			"ehhhhhhfhfhfhfhhhhhhhhhhhhhhhhhhhhhehebeedddd..............",
			"hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhheeeddd............",
			"hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhheeee...........",
			"hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh...........",
			"hhhhfhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh...........",
			".hhffhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh............",
			"..ffhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhff.............",
			"..ffhhffffffffffffffffffffffffffffffffffffhhff.............",
			"..ffhhbbaaabbbbbbbaaabbbbbbaaabbbbbbbaaabbhbff.............",
			"..fff.....................................fff..............",
			"...fffffffffffffffffffffffffffffffffffffffff..............."
		}
	},
	Bradley = {
		palette = {
			"4a523a",
			"292929",
			"212121",
			"424a31",
			"313131",
			"525a3a",
			"526342",
			"636b42",
			"3a4231",
			"942119",
			"efe6c5"
		},
		rows = {
			"......................aaa..................",
			"..............bcbbbddaaaab.................",
			".............aeeeeeaaaaaaaa................",
			"..........bffggeeeegggggggaaaaa..........bb",
			"..........ehhggggggggggggggabbbbbbbbbbbbbbb",
			".........eeeeggggggggggegggaaaa..........bb",
			"aaaaaaaaaaeegggggggggggggggaaaaaa..........",
			"gggggggggggggggggggggggggggggegegffi.......",
			"ggggggggggggggggggggggggggggggggghffii.....",
			"gggggggggggggggggggggggggggggggggggfffi....",
			"jhhehhhhehhhhehhhhehhhheheeeehhhhegghff....",
			"ghhehhhhehhhhehhhhehhhheheeeehhhheggggaa...",
			"ghhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhgggggg...",
			"gggggggggggggggggggggggggggggggggggggggk...",
			"eggeeeegggggegggggegggggegggggeggggggggg...",
			"egeeegegggggegggggegggggegggggegggggggg....",
			"egeeggegggggegggggegggggegggggegggggee.....",
			"e.eeggeeeeeeeeeeeeeeeeeeeeeeeeeeeeegee.....",
			"..eeggggcccggcccggcccgggcccggcccgggeee.....",
			"...ee.............................eee......",
			"....eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee......."
		}
	},
	Humvee = {
		palette = { "525a3a", "636b42", "637384", "424a31", "7b8c94", "212121" },
		rows = {
			"............aaaaaaaaa.......................",
			"......aaaaaaabbbbbbbaaaaa...................",
			".....ccbbbbbbbbbbbbbbbbbbd..................",
			"....ccbbbbbbbbbbbbbbbbbbbb..................",
			"ddddcbbbbbbbeeeeebbeeeeebbdaaaaaaaaaaad.....",
			"aaaabbbbbbbbeeeeebbeeeeebbabbbbbbbbbbaaddd..",
			"bbbbbbbbbbbbbaaaaabbaaaabbbbbbbbbbbbbbbaaad.",
			"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbba.",
			"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb.",
			"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbba",
			"bbbbbfffbbbbbbbbbbbbbbbbbbbbbbbbbbfffbbbbbba",
			"bbbbfffffbbbbbbbbbbbbbbbbbbbbbbbbfffffbbbbba",
			"bbbfffffffbbbbbbbbbbbbbbbbbbbbbbfffffffbbbbb",
			"bbbffbbbbffbbbbbbbbbbbbbbbbbbbbbffbbbbffbbbb",
			"bbbffbbbbffbbbbbbbbbbbbbbbbbbbbbffbbbbffbbbb",
			"...ffbbbbff.....................ffbbbbff....",
			"...ffbbbfff.....................ffbbbfff....",
			"....ffffff.......................ffffff.....",
			".....ffff.........................ffff......"
		}
	}
}
return {
	voxel = function(p: string, p2, color: Color3?)
		local v2 = v[p]

		if v2 then
			return StreakIcon.pixels(v2, p2, color, 5)
		end

		return VehicleIcon.voxel(p, p2, color)
	end
}