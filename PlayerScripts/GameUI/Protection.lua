local Style = require(script.Parent:WaitForChild("Style"))

local function segment(color: Color3) -- 1 equivalent call inferred from this helper
	local tape = Instance.new("Part")
	tape.Name = "Tape"
	tape.Size = Vector3.new(1.05, 0.12, 0.26)
	tape.Color = color
	tape.Material = Enum.Material.SmoothPlastic
	tape.Anchored = true
	tape.CanCollide = false
	tape.CanQuery = false
	tape.CanTouch = false
	tape.CastShadow = false
	tape.TopSurface = Enum.SurfaceType.Smooth
	tape.BottomSurface = Enum.SurfaceType.Smooth
	return tape
end

return {
	mount = function(p)
		local spawnRings = Instance.new("Folder")
		spawnRings.Name = "SpawnRings"
		spawnRings.Parent = workspace

		local states = {}
		local v = {}
		local segments = {}
		local v2 = {}

		local function acquire()
			local v3 = table.remove(states)

			if v3 then
				return v3
			end

			local segments2 = {}

			for i = 1, 16 do
				local v4

				if i % 2 == 0 then
					v4 = Style.INK
				else
					v4 = Style.HAZARD
				end

				segments2[i] = segment(v4) -- inferred equivalent call
			end

			return {
				segments = segments2,
				character = nil,
				root = nil,
				t0 = 0,
				ending = nil,
				parts = {},
				ghost = nil
			}
		end

		local function ghost(state, p2: number) -- 2 equivalent calls inferred from this helper
			if state.ghost == p2 then
				return
			end

			state.ghost = p2

			for _, part in state.parts do
				part.LocalTransparencyModifier = p2
			end
		end

		local function release(k, state) -- 2 equivalent calls inferred from this helper
			v[k] = nil
			ghost(state, 0) -- inferred equivalent call
			state.ghost = nil
			table.clear(state.parts)

			for _, segment2 in state.segments do
				segment2.Parent = nil
			end

			state.root = nil
			state.character = nil
			table.insert(states, state)
		end

		local function step(_, p2): boolean
			table.clear(segments)
			table.clear(v2)

			for k, v3 in v do
				local root = v3.root

				if root and root:IsDescendantOf(workspace) then
					local v4

					if v3.ending then
						v4 = 1 - math.clamp((p2 - v3.ending) / 0.2, 0, 1)

						if v4 <= 0 then
							release(k, v3) -- inferred equivalent call
							continue
						end
					else
						v4 = Style.pop((p2 - v3.t0) / 0.2)
					end

					local v5 = math.max(v4, 0.05) * 2.6
					local v6 = CFrame.new(root.Position - Vector3.new(0, 2.9, 0)) * CFrame.Angles(0, p2 * 0.6, 0)

					for k2, segment2 in v3.segments do
						local v7 = (k2 - 1) / 16 * 3.141592653589793 * 2
						table.insert(segments, segment2)
						table.insert(v2, v6 * CFrame.Angles(0, -v7, 0) * CFrame.new(0, 0, -v5))
					end

					if k ~= p.player.Character then
						ghost(v3, math.round(math.clamp(v4, 0, 1) * 2) * 0.35 / 2) -- inferred equivalent call
					end
				else
					release(k, v3) -- inferred equivalent call
				end
			end

			if #segments > 0 then
				workspace:BulkMoveTo(segments, v2, Enum.BulkMoveMode.FireCFrameChanged)
			end

			return next(v) ~= nil
		end

		local function update(folder)
			local protected = folder:GetAttribute("Protected") == true
			local v3 = v[folder]

			if protected then
				if v3 and not v3.ending then
					return
				end

				if not v3 then
					v3 = acquire()
					v[folder] = v3
				end

				v3.character = folder
				v3.root = folder:FindFirstChild("HumanoidRootPart")
				v3.t0 = os.clock()
				v3.ending = nil
				v3.ghost = nil
				table.clear(v3.parts)

				for _, part in folder:GetDescendants() do
					if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
						table.insert(v3.parts, part)
					end
				end

				for _, segment2 in v3.segments do
					segment2.Size = Vector3.new(1.0005972, 0.12, 0.26)
					segment2.Parent = spawnRings
				end

				Style.animate(v, step)
			elseif v3 and not v3.ending then
				v3.ending = os.clock()
			end
		end

		p.eachCharacter(function(instance)
			instance:GetAttributeChangedSignal("Protected"):Connect(function()
				update(instance)
			end)
			instance:WaitForChild("HumanoidRootPart", 10)
			update(instance)
		end)

		local object = setmetatable({}, { __mode = "k" })
		local function watchRig(model)
			if not model:IsA("Model") then
				return
			end

			if not object[model] then
				object[model] = true
				model:GetAttributeChangedSignal("Protected"):Connect(function()
					update(model)
				end)
			end

			if model:GetAttribute("Protected") == true then
				update(model)
			end
		end
		task.spawn(function()
			local botRigs = workspace:WaitForChild("BotRigs")
			botRigs.ChildAdded:Connect(watchRig)

			for _, child in botRigs:GetChildren() do
				watchRig(child)
			end
		end)
	end
}