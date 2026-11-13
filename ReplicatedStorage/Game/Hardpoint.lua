local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MapSelect = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("MapSelect"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local WorldConfig = require(ReplicatedStorage2:WaitForChild("Voxel"):WaitForChild("WorldConfig"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local Breakthrough = require(ReplicatedStorage3:WaitForChild("Game"):WaitForChild("Breakthrough"))

local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local Game = ReplicatedStorage4:WaitForChild("Game")

local v = {}
local v2 = {
	ironfield = {
		scoring = "majority",
		tick = 1,
		main = 1,
		points = {
			{
				id = "",
				letter = "CP",
				name = "COMMAND POST",
				center = Vector3.new(0, 17.5, 0),
				halfX = 30,
				halfZ = 16,
				yMin = 10,
				yMax = 42,
				marker = Vector3.new(0, 60, 0)
			}
		}
	},
	sandline = {
		scoring = "owned",
		tick = 4,
		main = 2,
		points = {
			{
				id = "A",
				letter = "A",
				name = "PUMP STATION",
				center = Vector3.new(-210, 0, -140),
				halfX = 25,
				halfZ = 20,
				yMin = -20,
				yMax = 40,
				marker = Vector3.new(-210, 50, -140)
			},
			{
				id = "B",
				letter = "B",
				name = "OLD TOWN BRIDGE",
				center = Vector3.new(0, 0, 0),
				halfX = 28,
				halfZ = 28,
				yMin = -20,
				yMax = 40,
				marker = Vector3.new(0, 50, 0)
			},
			{
				id = "C",
				letter = "C",
				name = "RADAR STATION",
				center = Vector3.new(210, 0, 140),
				halfX = 25,
				halfZ = 20,
				yMin = -20,
				yMax = 40,
				marker = Vector3.new(210, 50, 140)
			}
		}
	},
	saltpan = {
		scoring = "owned",
		tick = 5,
		main = 2,
		points = {
			{
				id = "A",
				letter = "A",
				name = "TANK FARM",
				center = Vector3.new(-276, 0, -159),
				halfX = 39,
				halfZ = 34,
				yMin = -20,
				yMax = 45,
				marker = Vector3.new(-276, 50, -159)
			},
			{
				id = "B",
				letter = "B",
				name = "PUMPING PLANT",
				center = Vector3.new(0, 0, 0),
				halfX = 39,
				halfZ = 45,
				yMin = -20,
				yMax = 45,
				marker = Vector3.new(0, 70, 0)
			},
			{
				id = "C",
				letter = "C",
				name = "CONSTRUCTION YARD",
				center = Vector3.new(276, 0, 159),
				halfX = 39,
				halfZ = 34,
				yMin = -20,
				yMax = 45,
				marker = Vector3.new(276, 50, 159)
			}
		},
		onePoint = {
			scoring = "majority",
			tick = 1,
			main = 1,
			points = {
				{
					id = "",
					letter = "PP",
					name = "PUMPING PLANT",
					center = Vector3.new(0, 9, 0),
					halfX = 39,
					halfZ = 45,
					yMin = -20,
					yMax = 45,
					marker = Vector3.new(0, 70, 0)
				}
			}
		}
	},
	frostmill = {
		scoring = "owned",
		tick = 5,
		main = 2,
		points = {
			{
				id = "A",
				letter = "A",
				name = "RAIL DEPOT",
				center = Vector3.new(-284, 0, -177),
				halfX = 40,
				halfZ = 50,
				yMin = -20,
				yMax = 45,
				marker = Vector3.new(-284, 56, -177)
			},
			{
				id = "B",
				letter = "B",
				name = "THE DAM",
				center = Vector3.new(0, 0, 0),
				halfX = 66,
				halfZ = 60,
				yMin = -20,
				yMax = 45,
				marker = Vector3.new(0, 70, 0)
			},
			{
				id = "C",
				letter = "C",
				name = "SAWMILL",
				center = Vector3.new(284, 0, 177),
				halfX = 40,
				halfZ = 50,
				yMin = -20,
				yMax = 45,
				marker = Vector3.new(284, 56, 177)
			}
		},
		onePoint = {
			scoring = "majority",
			tick = 1,
			main = 1,
			points = {
				{
					id = "",
					letter = "DM",
					name = "DAM",
					center = Vector3.new(0, 18.5, 0),
					halfX = 66,
					halfZ = 60,
					yMin = -20,
					yMax = 45,
					marker = Vector3.new(0, 70, 0)
				}
			}
		}
	},
	highcrag = {
		scoring = "owned",
		tick = 5,
		main = 2,
		points = {
			{
				id = "A",
				letter = "A",
				name = "WEST SHOULDER",
				center = Vector3.new(-300, 0, -80),
				halfX = 39,
				halfZ = 34,
				yMin = 15,
				yMax = 80,
				marker = Vector3.new(-300, 80, -80)
			},
			{
				id = "B",
				letter = "B",
				name = "THE CROWN",
				center = Vector3.new(0, 0, 0),
				halfX = 46,
				halfZ = 27,
				yMin = 48,
				yMax = 105,
				marker = Vector3.new(0, 118, 0)
			},
			{
				id = "C",
				letter = "C",
				name = "EAST SHOULDER",
				center = Vector3.new(300, 0, 80),
				halfX = 39,
				halfZ = 34,
				yMin = 15,
				yMax = 80,
				marker = Vector3.new(300, 80, 80)
			}
		},
		onePoint = {
			scoring = "majority",
			tick = 1,
			main = 1,
			points = {
				{
					id = "",
					letter = "CR",
					name = "CROWN",
					center = Vector3.new(0, 58, 0),
					halfX = 46,
					halfZ = 27,
					yMin = 48,
					yMax = 105,
					marker = Vector3.new(0, 118, 0)
				}
			}
		}
	},
	drywell = {
		scoring = "owned",
		tick = 5,
		main = 2,
		points = {
			{
				id = "A",
				letter = "A",
				name = "WEST WORKS",
				center = Vector3.new(-272, 0, -128),
				halfX = 39,
				halfZ = 34,
				yMin = -20,
				yMax = 45,
				marker = Vector3.new(-272, 50, -128)
			},
			{
				id = "B",
				letter = "B",
				name = "PUMP HALL",
				center = Vector3.new(0, 0, 0),
				halfX = 52,
				halfZ = 32,
				yMin = -6,
				yMax = 45,
				marker = Vector3.new(0, 60, 0)
			},
			{
				id = "C",
				letter = "C",
				name = "EAST WORKS",
				center = Vector3.new(272, 0, 128),
				halfX = 39,
				halfZ = 34,
				yMin = -20,
				yMax = 45,
				marker = Vector3.new(272, 50, 128)
			}
		},
		onePoint = {
			scoring = "majority",
			tick = 1,
			main = 1,
			points = {
				{
					id = "",
					letter = "PH",
					name = "PUMP HALL",
					center = Vector3.new(0, -1.5, 0),
					halfX = 52,
					halfZ = 32,
					yMin = -6,
					yMax = 45,
					marker = Vector3.new(0, 60, 0)
				}
			}
		}
	},
	deepworks = {
		scoring = "owned",
		tick = 5,
		main = 2,
		points = {
			{
				id = "A",
				letter = "A",
				name = "WEST PIT",
				center = Vector3.new(-190, 2, -131),
				halfX = 34,
				halfZ = 30,
				yMin = 0,
				yMax = 30,
				floor = 2.5,
				marker = Vector3.new(-190, 34, -131)
			},
			{
				id = "B",
				letter = "B",
				name = "THE GREAT CAVERN",
				center = Vector3.new(0, -4, 0),
				halfX = 46,
				halfZ = 30,
				yMin = -6,
				yMax = 30,
				floor = -3.5,
				marker = Vector3.new(0, 30, 0)
			},
			{
				id = "C",
				letter = "C",
				name = "EAST PIT",
				center = Vector3.new(190, 2, 131),
				halfX = 34,
				halfZ = 30,
				yMin = 0,
				yMax = 30,
				floor = 2.5,
				marker = Vector3.new(190, 34, 131)
			}
		}
	},
	pinewold = {
		scoring = "owned",
		tick = 5,
		main = 2,
		points = {
			{
				id = "A",
				letter = "A",
				name = "RELAY STATION",
				center = Vector3.new(-141.4, 0, -198),
				halfX = 24,
				halfZ = 22,
				yMin = 0,
				yMax = 60,
				marker = Vector3.new(-141.4, 58, -198)
			},
			{
				id = "B",
				letter = "B",
				name = "THE DEPOT",
				center = Vector3.new(0, 0, 0),
				halfX = 30,
				halfZ = 30,
				yMin = 16,
				yMax = 34,
				floor = 20,
				marker = Vector3.new(0, 30, 0)
			},
			{
				id = "C",
				letter = "C",
				name = "BRICKWORKS",
				center = Vector3.new(141.4, 0, 198),
				halfX = 24,
				halfZ = 22,
				yMin = 0,
				yMax = 60,
				marker = Vector3.new(141.4, 58, 198)
			}
		},
		onePoint = {
			scoring = "majority",
			tick = 1,
			main = 1,
			points = {
				{
					id = "",
					letter = "DP",
					name = "DEPOT",
					center = Vector3.new(0, 20, 0),
					halfX = 30,
					halfZ = 30,
					yMin = 16,
					yMax = 34,
					floor = 20,
					marker = Vector3.new(0, 30, 0)
				}
			}
		}
	}
}
local Hardpoint = {}

for k, v3 in Breakthrough.SECTORS do
	local points = {}

	for _, point in v3.points do
		table.insert(points, {
			id = point.id,
			letter = point.id,
			name = point.name,
			center = Vector3.new(point.x, point.y, point.z),
			halfX = point.radius,
			halfZ = point.radius,
			yMin = point.y - 15,
			yMax = point.y + 45,
			marker = Vector3.new(point.x, point.y + 45, point.z)
		})
	end

	v[k] = { scoring = "owned", tick = 1, main = 1, points = points }
end

v2[Breakthrough.MAP] = v[1]

Hardpoint.POINTS = {}
Hardpoint.SCORING = ""
Hardpoint.MAIN = 1
Hardpoint.NAME = ""
Hardpoint.SHORT = ""
Hardpoint.CENTER = Vector3.new(0, 0, 0)
Hardpoint.HALF_X = 0
Hardpoint.HALF_Z = 0
Hardpoint.Y_MIN = 0
Hardpoint.Y_MAX = 0
Hardpoint.MARKER = Vector3.new(0, 0, 0)
Hardpoint.TICK = 1

local function setOf(p: string) -- 2 equivalent calls inferred from this helper
	if p == Breakthrough.MAP then
		return v[Breakthrough.sectorAt(WorldConfig.ORIGIN.Z)]
	end

	local v3 = v2[p]
	assert(v3, "[Hardpoint] no points for map " .. tostring(p))

	if Game:GetAttribute("OnePoint") == true and v3.onePoint then
		return v3.onePoint
	end

	return v3
end

local v3 = nil
local function adopt(name: string)
	local v4 = setOf(name) -- inferred equivalent call
	v3 = v4
	table.clear(Hardpoint.POINTS)
	table.move(v4.points, 1, #v4.points, 1, Hardpoint.POINTS)
	Hardpoint.SCORING = v4.scoring

	local v5 = Hardpoint.POINTS[v4.main]
	Hardpoint.MAIN = v4.main
	Hardpoint.NAME = #Hardpoint.POINTS > 1 and "THE POINTS" or v5.name
	Hardpoint.SHORT = v5.letter
	Hardpoint.CENTER = v5.center
	Hardpoint.HALF_X = v5.halfX
	Hardpoint.HALF_Z = v5.halfZ
	Hardpoint.Y_MIN = v5.yMin
	Hardpoint.Y_MAX = v5.yMax
	Hardpoint.MARKER = v5.marker
	Hardpoint.TICK = v4.tick
end
adopt(MapSelect.name)
MapSelect.onChange(adopt, 4)

local v4 = {}
function Hardpoint.onPointsChange(callback)
	table.insert(v4, callback)
end
local function flagChanged() -- 1 equivalent call inferred from this helper
	if setOf(MapSelect.name) == v3 then -- inferred equivalent call
		return
	end

	adopt(MapSelect.name)

	for _, v5 in v4 do
		v5()
	end
end
Game:GetAttributeChangedSignal("OnePoint"):Connect(flagChanged)
WorldConfig.onOrigin(flagChanged)
function Hardpoint.hasOnePoint(p: string): boolean
	return v2[p] ~= nil and v2[p].onePoint ~= nil
end

function Hardpoint.isOnePoint(): boolean
	return Game:GetAttribute("OnePoint") == true
end

function Hardpoint.setOnePoint(flag: boolean)
	Game:SetAttribute("OnePoint", flag and true or nil)
	flagChanged() -- inferred equivalent call
end

Hardpoint.CAPTURE_TIME = 10
Hardpoint.MAX_SPEED = 3
Hardpoint.POINTS_PER_TICK = 1
Hardpoint.TARGET = 300
Hardpoint.ROUND_TIME = 900
Hardpoint.COUNTDOWN = 20
Hardpoint.INTERMISSION = 30
Hardpoint.WORK_EVERY = 1
Hardpoint.DEFEND_EVERY = 2

Hardpoint.TEAMS = { "Reds", "Blues" }

function Hardpoint.containsIn(p: number, vector3: Vector3): boolean
	local v5 = Hardpoint.POINTS[p]
	local v6 = vector3 - v5.center
	return math.abs(v6.X) <= v5.halfX and math.abs(v6.Z) <= v5.halfZ and vector3.Y >= v5.yMin and vector3.Y <= v5.yMax
end

function Hardpoint.pointAt(vector3: Vector3)
	for k in Hardpoint.POINTS do
		if Hardpoint.containsIn(k, vector3) then
			return k
		end
	end

	return nil
end

function Hardpoint.contains(vector3: Vector3): boolean
	return Hardpoint.pointAt(vector3) ~= nil
end

function Hardpoint.attr(p: string, p2: number)
	return p .. Hardpoint.POINTS[p2].id
end

function Hardpoint.other(p: string): string
	return if p == "Reds" then "Blues" else "Reds"
end

return Hardpoint