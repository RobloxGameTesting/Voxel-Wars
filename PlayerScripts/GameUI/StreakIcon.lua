local StreakIcon = {}

local v = {
	Airstrike = "rbxassetid://131883929572347",
	Minigun = "rbxassetid://101933192221844",
	Hellfire = "rbxassetid://135927961038863",
	Gunship = "rbxassetid://71438603599055"
}

local v2 = {
	Airstrike = {
		palette = {
			"292b2f",
			"53575e",
			"969692",
			"202224",
			"404449",
			"555a5e",
			"4a4e53",
			"62666b",
			"1d2631",
			"6e7379",
			"201f1e",
			"25262a",
			"5c6168",
			"7a8086",
			"2e3034",
			"d6d6d0",
			"3f462f",
			"464e34",
			"383e2a",
			"9d8532",
			"b09538",
			"313724"
		},
		rows = {
			".aaa............................................................................",
			".aaaa...........................................................................",
			".bbbbbb.............cccccccccccccdd.............................................",
			".bbbbbbb............ceeccccccccccdd.............................................",
			".bbbbbbbb............eefeec.....................................................",
			".bbbbbbbbb...........eeffffe....................................................",
			".bbbbbbbbbbb.........eeffffffee.................................................",
			".bbbbbbbbbbbb........eefffffffffe...............................................",
			"ebbbbbbbbbbbbb.......eefffffffffffee............................................",
			"gbbbbbbbbbbbbbb......eeffffffffffffffe..........................................",
			"gbbbbbbbbbbbbbbbb....eefffffffffffffffggg.......................................",
			"gbbbbbbbbbbbbbbbbb...gghhhhggggggggggggggggggggg.....iibiiiiiii.................",
			"gbbbbbbbbbbbbbbbbbbhhgghhhgbbbbbbbbbbbbbbbbbbbbgghhiiiibiiiiiiiii...............",
			"gbbbbbbbbbbbbbbjjjjjjjbjjjbbbbbbbbbbbbbbbbbbbbbbjjjjiiibiiiiiiiiihhh............",
			"...kkkkkjjjjjjjjjjjjjjbjjjbbbbbbbbbbbbbbbbbbbbbbbjjjjjjjiiiiijjjjjjjhhhhhh......",
			"....kkkkjjjjjjjjjjjjjjbjjjjjjjjjjbjjjjjjjjjjjbjjjjjjjjjjbjjjjjjjjjjjjjjhhhhhhll.",
			"....kkkkjjjjjjjjjjjjjjbjjjjjjjjjjbjjjjjjjjjjjbjjjjjjjjjjbjjjjjjjjjjjjjjjhhhhhlll",
			"bbbbbbbbbbbbjjjjjjjjjjbjjjjjjjjjjbjjjjjbbbbbbbbbbbbbjjjjbjjjjjjjjjjjjjhhhhhh....",
			"bbbbbbbbbbbjjjjjjjjjjbbjjjjjjjjjjjjjjjjbbbbbbbbbbbbbjjjjbjjjjjjjjjjhhh..........",
			"bbbbbbbbb.ghhjjjjjjjjbbjjjjjjjjjjjjjjjjjjjjjbbbbbbbbjjjjgjhhhhgh................",
			"bbbbbbb..............bbjjjjjjjjjjjjjjjjjjjjbbbbbbbbb............................",
			"bbbbb................bbjjjjjjjjjjjjjjjjjbbbbbbbbbbbb............................",
			"bb...................bbjjjjjjjjjjjjjjjbbb.......................................",
			".....................bbjjjjjjjjjjjjbbbb.........................................",
			".....................mmnnnnnnnnnnmmb............................................",
			".....................mmnnnnnnnnmmmaa............................................",
			".....................mmnnnnnmmmo................................................",
			".....................mmnnnmmmoooo...............................................",
			".....................mmmmmm.....................................................",
			".....................mmmp.......................................................",
			"....................pppppppppppppoo.............................................",
			"....................pppppppppppppoo.............................................",
			"................................................................................",
			".................o..............................................................",
			"...............laoo.............................................................",
			"...............aoooq............................................................",
			"...............ooorrqs..........................................................",
			"..............aooorrrqqt........................................................",
			"..............aaarrrrrrus.......................................................",
			"..................qqqquqlssv....................................................",
			"...................qquuqlqqs....................................................",
			".....aoo.............us.sqqq....................................................",
			"....ooooo...............ssss....................................................",
			"...oooorq................sss....................................................",
			"...aooorrs.................s....................................................",
			"....arrrrqs.....................................................................",
			"......rrrrq.....................................................................",
			"......qqqqus....................................................................",
			".......qquusv...................................................................",
			"........usqlsv..................................................................",
			".........vvssv..................................................................",
			"..........ssssv.................................................................",
			"..........ssssvv................................................................",
			"...........vvvvv................................................................"
		}
	},
	Minigun = {
		palette = {
			"917854",
			"1a1c1e",
			"1d1f21",
			"3f4246",
			"0e0e10",
			"2f3134",
			"34363a",
			"0d0d0e",
			"816a4a",
			"735d41",
			"17191a"
		},
		rows = {
			"........aaaaaaaaaaaa.....................................",
			"........bbaaaaaaaaba.....................................",
			"........bb........b......................................",
			"........bb........b......................................",
			"cddeddeddcccccccccccc....f...............................",
			"cddeddeddggggggggggggccccg...............................",
			"cddeddeddggggggggggggccccgfcfffffffffffccffffffffffffcccf",
			"cddeddeddggggggggggggccccgfcfffffffffffccffffffffffffcccf",
			"cddeddeddggggggggggggccccggcgggggggggggccggggggggggggcccg",
			"cccccceggggggggggggggccccggcgggggggggggccggggggggggggcccg",
			"gcccccgggggggggggggggccccghchhhhhhhhhhhcchhhhhhhhhhhhccch",
			"gcccccgggggggggggggggccccggcgggggggggggccggggggggggggcccg",
			"gcccccggggggggccccgggccccgfcfffffffffffccffffffffffffcccf",
			"gcccccggggggggccccgggccccgfcfffffffffffccffffffffffffcccf",
			"gcccccgggcgggggcccgggccccg.bb..........bb............bbb.",
			"gc...cgggggggggggggggbbbbg...............................",
			"......ggggggggggggi..bbbbb...............................",
			"......ggggggggggggi...aaa................................",
			"......jjjaakkbkkkkk...aaa................................",
			".....ajjjja...........aaa................................",
			".....ajjjaa...........aaa................................",
			".....ajjja............aaa................................",
			"....aaajja............aaa................................",
			"....bbaaaa............aaa................................",
			".....bbbbb............bbb................................"
		}
	},
	Hellfire = {
		palette = {
			"363b28",
			"222426",
			"464d34",
			"b99934",
			"878c90",
			"f07828",
			"26282a",
			"4e563a",
			"ceaa3a",
			"969ca0",
			"ffd678",
			"3c422c",
			"303523"
		},
		rows = {
			"............aa.............................................",
			"............aaaaa..........................................",
			"............aaaaaaaa.........................aaaaa.........",
			"............aaaaaaaaaaa......................aaaaa.........",
			"..........bbaaaaaaaaaaacccccccccccccccccdddccaaaaacce......",
			"..........bbccccccccccccccccccccccccccccdddccccccccceee....",
			"....ffff..gghhhhhhhhhhhhhhhhhhhhhhhhhhhhiiihhhhhhhhhjeeee..",
			"ffffkkkk..gghhhhhhhhhhhhhhhhhhhhhhhhhhhhiiihhhhhhhhhjjeeeee",
			"ffffkkkk..gglllllllllllhhhhhhhhhhhhhhhhhiiihhlllllhhjjeeeee",
			"ffffkkkk..gglllllllllllhhhhhhhhhhhhhhhhhiiihhlllllhhjeeeee.",
			"....ffff..gglllllllhhhhhhhhhhhhhhhhhhhhhiiihhhlllhhheeee...",
			"..........bbccccccccccccccccccccccccccccdddcccccccccee.....",
			"...........baaaaaaaaaaa......................aaaaa.........",
			"............mmmmmmmmm........................mmmmm.........",
			"............mmmmmm.........................................",
			"............mmmm...........................................",
			"............m.............................................."
		}
	},
	Gunship = {
		palette = {
			"5e6163",
			"202020",
			"37393c",
			"494c4d",
			"252525",
			"191b1c",
			"3e4245",
			"535658",
			"1d1e20",
			"292929",
			"464a4d",
			"2e2e2e",
			"4e5256",
			"686c6e",
			"202224",
			"1b2229",
			"242628",
			"4f5356"
		},
		rows = {
			"aaaaa.............................................................",
			"aaaaaa............................................................",
			"aaaaaa............................................................",
			"aaaaaaa...........................................................",
			"aaaaaaa...........................................................",
			"aaaaaaaa......................................b...................",
			"aaaaaaaa......................cddddddd........e...................",
			"aaaaaaaaa.....................cdddddddd.......e...................",
			"aaaaaaaaa....................ccddddddddccccccfe...................",
			"aaaaaaaaaa...................ghhhhhhhhhcgggggij...................",
			"aaaaaaaaaaa..................kaaaaaaaaaagggggil...................",
			"aaaaaaaaaaaaaaaaaaaaaaaaaakaakaaaaaaaaaaaaaaaalaaaaaaaaakaaa......",
			"aaaaaaaaaaaaaaaaaaaaaaaaaakaakmnnnnnnnnkkkkkkolaaaaaaaaakaaaap....",
			"aaaaaaaaaaaaaaaaaaaaaaaaaakaammnnnnnnnnmmmmmmqlaaaaaaaaakaaaappp..",
			"aaaaaaaaaaaaaaaaaaaaaaaaaakaaamnnnnnnnnmmmmmmqlaaaaaaaaakaaaappppp",
			".aaaaaaaaaaaaaaaaaaaaaaaaakaaammnnnnnnmmmmmmmqlaaaaaaaaakaaaaaaaaa",
			"....aaaaaaaaaaaaaaaaaaaaaakaaaaanmmmmmmmmmmmmqlaaaaaaaaakaaaaaaaaa",
			".......rraaaaaaaaaaaaaaaaakaoaaaaaaakaaaaaaaaalaaaaaaaaakaaaaaaaaa",
			".........rrrrraaaaaaaaaaaakaaaaaaaaakaaaaaaaaalaaaaaaaaakaaaaaaa..",
			"............rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrlrrrrrrrrrrrrrrr....",
			"...............rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr......"
		}
	}
}

local color = Color3.fromRGB(16, 16, 19)

function StreakIcon.has(p: string): boolean
	return v[p] ~= nil
end

function StreakIcon.flat(p: string, parent, color2: Color3?)
	local image = v[p]
	assert(image, "GameUI: no streak icon for " .. tostring(p))
	local streakIcon = Instance.new("Frame")
	streakIcon.Name = "StreakIcon"
	streakIcon.BackgroundTransparency = 1
	streakIcon.Size = UDim2.fromScale(1, 1)
	local picture = Instance.new("ImageLabel")
	picture.Name = "Picture"
	picture.BackgroundTransparency = 1
	picture.Size = UDim2.fromScale(1, 1)
	picture.ScaleType = Enum.ScaleType.Fit
	picture.Image = image
	picture.ImageColor3 = color2 or Color3.new(1, 1, 1)
	picture.Parent = streakIcon
	streakIcon.Parent = parent
	return streakIcon, function(imageColor: Color3)
		picture.ImageColor3 = imageColor
	end
end

local function tinted(base: Color3, color2: Color3) -- 2 equivalent calls inferred from this helper
	if 0.3 * color2.R + 0.59 * color2.G + 0.11 * color2.B < 0.35 then
		return base
	end

	return Color3.new(base.R * color2.R, base.G * color2.G, base.B * color2.B)
end

local function lift(color2: Color3, p: number)
	local v3 = math.max(color2.R, color2.G, color2.B)

	if v3 > 0 then
		p = math.min(p, 1 / v3)
	end

	return Color3.new(color2.R * p, color2.G * p, color2.B * p)
end

function StreakIcon.voxel(p: string, p2, color2: Color3?)
	local v3 = v2[p]
	assert(v3, "GameUI: no voxel streak icon for " .. tostring(p))
	return StreakIcon.pixels(v3, p2, color2)
end

function StreakIcon.pixels(p, parent, color2: Color3?, value: number?)
	local rows = p.rows
	local count = #rows
	local count2 = #rows[1]
	local colors = {}
	local v3 = value or 3

	for k, v4 in p.palette do
		colors[k] = Color3.fromHex(v4)
	end

	local function at(p2: number, p3: number) -- 4 equivalent calls inferred from this helper
		local row = rows[p2]

		if row then
			return (string.sub(row, p3, p3))
		end

		return "."
	end

	local streakIcon = Instance.new("Frame")
	streakIcon.Name = "StreakIcon"
	streakIcon.BackgroundTransparency = 1
	streakIcon.Size = UDim2.fromScale(1, 1)
	local art = Instance.new("Frame")
	art.Name = "Art"
	art.BackgroundTransparency = 1
	art.AnchorPoint = Vector2.new(0.5, 0.5)
	art.Position = UDim2.fromScale(0.5, 0.5)
	art.Size = UDim2.new(1, -v3, 1, -v3)
	art.Parent = streakIcon
	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = count2 / count
	uiAspectRatioConstraint.AspectType = Enum.AspectType.FitWithinMaxSize
	uiAspectRatioConstraint.Parent = art

	local v4 = {}

	for i = 1, count do
		local total = 1

		while total <= count2 do
			local v5 = at(i, total) -- inferred equivalent call

			if v5 == "." then
				total += 1
			else
				local function light(p2: number): number -- 2 equivalent calls inferred from this helper
					if at(i - 1, p2) == "." then -- inferred equivalent call
						return 1.14
					end

					if at(i + 1, p2) == "." then -- inferred equivalent call
						return 0.8
					end

					return 1
				end

				local v6 = light(total) -- inferred equivalent call
				local v7 = 1

				while total + v7 <= count2 do
					if not (at(i, total + v7) == v5 and light(total + v7) == v6) then -- inferred equivalent call
						break
					end

					v7 += 1
				end

				table.insert(v4, {
					r = i,
					c = total,
					n = v7,
					base = colors[string.byte(v5) - 96],
					k = v6
				})
				total += v7
			end
		end
	end

	local function block(data, p2: number, backgroundColor: Color3, zIndex: number)
		local frame = Instance.new("Frame")
		frame.BorderSizePixel = 0
		frame.BackgroundColor3 = backgroundColor
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale((data.c - 1 + data.n / 2) / count2, (data.r - 0.5) / count)
		frame.Size = UDim2.new(data.n / count2, p2, 1 / count, p2)
		frame.ZIndex = zIndex
		frame.Parent = art
		return frame
	end

	for _, v5 in v4 do
		block(v5, v3, color, 1)
	end

	local v5 = color2 or Color3.new(1, 1, 1)
	local v6 = {}

	for k, v7 in v4 do
		local v8 = tinted(v7.base, v5) -- inferred equivalent call
		local v9 = v7.k * 1.3
		local v10 = math.max(v8.R, v8.G, v8.B)

		if v10 > 0 then
			v9 = math.min(v9, 1 / v10)
		end

		v6[k] = block(v7, 1, Color3.new(v8.R * v9, v8.G * v9, v8.B * v9), 2)
	end

	streakIcon.Parent = parent
	local v7 = v5
	return streakIcon, function(color3: Color3)
		if color3 ~= v7 then
			v7 = color3

			for k, v8 in v6 do
				local v9 = v4[k]
				local v10 = tinted(v9.base, color3) -- inferred equivalent call
				local v11 = v9.k * 1.3
				local v12 = math.max(v10.R, v10.G, v10.B)

				if v12 > 0 then
					v11 = math.min(v11, 1 / v12)
				end

				v8.BackgroundColor3 = Color3.new(v10.R * v11, v10.G * v11, v10.B * v11)
			end
		end
	end
end

return StreakIcon