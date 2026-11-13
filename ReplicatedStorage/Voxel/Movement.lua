local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local Crouch = require(script.Parent:WaitForChild("Crouch"))
local MenuLock = require(script.Parent:WaitForChild("MenuLock"))

local function notStarted()
	error("Movement not started")
end

local Movement = {
	state = {
		sprinting = false,
		sliding = false,
		slideAlpha = 0,
		crouching = false,
		crouchAlpha = 0
	},
	weaponScale = 1,
	blockSprint = false,
	eyeDrop = 0,
	jobScale = 1,
	autoSprint = false,
	touchJump = false,
	SPRINT_SPEED = 25,
	fovOffset = 0,
	fovApplied = 0,
	weaponFov = false,
	toggleSprint = notStarted,
	slide = notStarted,
	sprintHeld = notStarted
}

Movement.FIELD_OF_VIEW = 80

local v = false

function Movement.start()
	assert(not v, "Movement already started")
	v = true
	local localPlayer = Players.LocalPlayer
	local state = Movement.state
	workspace.CurrentCamera.FieldOfView = 80

	local v2 = false
	local v3 = false
	local v4 = 0
	local flag = false
	local v5 = Vector3.new(0, 0, 0)
	local total = 0
	local lastTime = -1e999
	local v6 = 16
	local v7 = false
	local v8 = false
	local v9 = false
	local v10 = false
	local crouch = nil
	local v11 = nil
	local v12 = nil
	local hipHeight = nil
	local flag2 = false
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local v13 = { nil, nil }

	local v14 = nil
	local v15 = Vector3.new(0, 0, 0)

	local function onSprint(_, p, p2)
		if p2.UserInputType == Enum.UserInputType.Touch then
			if p == Enum.UserInputState.Begin then
				v2 = not v2
			end
		elseif p2.KeyCode == Enum.KeyCode.ButtonL3 then
			if p ~= Enum.UserInputState.Begin or MenuLock.held then
				return Enum.ContextActionResult.Pass
			end

			v2 = not v2
			v3 = v2
			v4 = 0
		else
			v2 = p == Enum.UserInputState.Begin
			v3 = false
		end

		if v2 then
			v7 = false
		end

		return Enum.ContextActionResult.Pass
	end

	local function onSlide(_, p)
		if p == Enum.UserInputState.Begin then
			flag = true
			v8 = true
		else
			v8 = false
		end

		return Enum.ContextActionResult.Pass
	end

	local v16 = Enum.ContextActionPriority.High.Value + 50
	ContextActionService:BindActionAtPriority(
		"VoxelSprint",
		onSprint,
		false,
		v16,
		Enum.KeyCode.LeftShift,
		Enum.KeyCode.ButtonL3
	)
	ContextActionService:BindActionAtPriority(
		"VoxelSlide",
		onSlide,
		false,
		v16,
		Enum.KeyCode.C,
		Enum.KeyCode.LeftControl,
		Enum.KeyCode.ButtonB
	)
	function Movement.toggleSprint()
		v2 = not v2

		if v2 then
			v7 = false
		end
	end
	function Movement.slide()
		flag = true
		v9 = true
	end
	function Movement.sprintHeld()
		return v2
	end

	local function endSlide() -- 3 equivalent calls inferred from this helper
		state.sliding = false
	end

	localPlayer.CharacterAdded:Connect(function()
		endSlide() -- inferred equivalent call
		v2 = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
		v3 = false
		v6 = 16
		state.sprinting = false
		state.slideAlpha = 0
		v7 = false
		v10 = false
		v8 = UserInputService:IsKeyDown(Enum.KeyCode.C) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
		state.crouching = false
		state.crouchAlpha = 0
		v11 = nil
		v12 = nil
		hipHeight = nil
		flag2 = false
	end)

	local v17 = nil
	local humanoid = nil
	local humanoidRootPart = nil
	local connection = nil
	local function findBody(character)
		if character ~= v17 then
			if connection then
				connection:Disconnect()
			end

			v17 = character
			humanoid = nil
			humanoidRootPart = nil
			local v18

			if character then
				v18 = character.ChildRemoved:Connect(function()
					humanoid = nil
					humanoidRootPart = nil
				end)
			end

			connection = v18
		end

		if character and not (humanoid and humanoidRootPart) then
			humanoid = character:FindFirstChildOfClass("Humanoid")
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end

		return humanoid, humanoidRootPart
	end

	RunService:BindToRenderStep("VoxelMovement", Enum.RenderPriority.Input.Value + 1, function(p)
		local character = localPlayer.Character
		local body, v18 = findBody(character)

		if body and v18 and not (body.Health <= 0) then
			if v12 ~= character then
				v11 = nil
				v12 = character
				hipHeight = nil
				flag2 = false
			end

			local currentCamera = workspace.CurrentCamera
			local lookVector = currentCamera.CFrame.LookVector
			local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)
			local v19 = not (vector3.Magnitude > 0.001) and Vector3.new(0, 0, 1) or vector3.Unit
			local moveDirection = body.MoveDirection
			local v20 = body.FloorMaterial ~= Enum.Material.Air

			if Movement.touchJump then
				body.Jump = true
			end

			local v21 = moveDirection.Magnitude > 0.1
			local v22 = 25

			if Movement.autoSprint then
				state.sprinting = not Movement.blockSprint and v21

				if v21 then
					v22 = (math.clamp(moveDirection.Unit:Dot(v19), 0, 1) * 0.15000000000000002 + 0.85) * 25
				end
			else
				local v23 = v21 and moveDirection:Dot(v19) > 0.35

				if v3 then
					v4 = v23 and 0 or v4 + p

					if v4 >= 0.3 then
						v2 = false
						v3 = false
					end
				end

				state.sprinting = v2 and not Movement.blockSprint and v23
			end

			if state.crouching then
				state.sprinting = false
			end

			if flag then
				flag = false

				if state.sliding or not (state.sprinting and v20 and os.clock() - lastTime > 0.45) then
					if not state.sliding and v9 then
						v7 = not v7
					end
				else
					state.sliding = true
					total = 0
					lastTime = os.clock()
					v5 = Vector3.new(moveDirection.X, 0, moveDirection.Z).Unit
					v7 = false
				end

				v9 = false
			end

			local crouching = v7 or v8 and not state.sliding

			if body.Jump then
				v7 = false
				crouching = false
			end

			if not crouching and state.crouching then
				local head = character:FindFirstChild("Head")

				if head then
					if v13[1] ~= character or v13[2] ~= currentCamera then
						v13[1] = character
						v13[2] = currentCamera
						raycastParams.ExcludeInstances = { character, currentCamera }
					end

					local v23 = (not v11 and 0 or Crouch.depth(v11, state.crouchAlpha)) + 0.3
					crouching = workspace:Raycast(
							head.Position,
							Vector3.new(0, head.Size.Y * 0.5 + v23, 0),
							raycastParams
						)
						and true
						or crouching
				end
			end

			state.crouching = crouching

			if v11 and not Crouch.current(v11, character) then
				v11 = nil

				if flag2 then
					hipHeight = nil
					flag2 = false
				end
			end

			if crouching and not v11 and Crouch.ready(character) then
				v11 = Crouch.rig(character)
			end

			if crouching ~= v10 then
				v10 = crouching

				if not crouch then
					local remotes = script.Parent:FindFirstChild("Remotes")
					crouch = remotes and remotes:FindFirstChild("Crouch")
					assert(crouch, "[Movement] ReplicatedStorage.Voxel.Remotes.Crouch is missing")
				end

				crouch:FireServer(crouching)
			end

			if state.sliding then
				total += p
				local v23 = total / 0.8
				v6 = (1 - (1 - v23) * (1 - v23)) * -26 + 40
				body:Move(v5, false)
				local magnitude = Vector3.new(v18.AssemblyLinearVelocity.X, 0, v18.AssemblyLinearVelocity.Z).Magnitude

				if v23 >= 1 or body.Jump or total > 0.15 and magnitude < 6 then
					endSlide() -- inferred equivalent call
					v6 = math.max((v2 or Movement.autoSprint) and 25 or 16, (math.min(v6, 25)))
				end
			else
				if not state.sprinting then
					v22 = not state.crouching and 16 or Crouch.WALK
				end

				v6 += (v22 - v6) * (1 - math.exp(-14 * p))

				if math.abs(v22 - v6) < 0.01 then
					v6 = v22
				end
			end

			body.WalkSpeed = v6 * (state.sliding and 1 or Movement.weaponScale * Movement.jobScale)

			local slideAlpha2 = state.sliding and 1 or 0
			state.slideAlpha += (slideAlpha2 - state.slideAlpha) * (1 - math.exp(-14 * p))

			if math.abs(slideAlpha2 - state.slideAlpha) < 0.001 then
				state.slideAlpha = slideAlpha2
			end

			local slideAlpha = state.slideAlpha
			local vector3_2 = Vector3.new(
				0,
				-1.7 * slideAlpha * slideAlpha * (3 - 2 * slideAlpha) - Movement.eyeDrop,
				0
			)

			if body ~= v14 or vector3_2 ~= v15 then
				v14 = body
				v15 = vector3_2
				body.CameraOffset = vector3_2
			end

			state.crouchAlpha = Crouch.ease(state.crouchAlpha, state.crouching, p)

			if state.crouchAlpha <= 0 then
				if flag2 and hipHeight then
					body.HipHeight = hipHeight
					flag2 = false
				end

				hipHeight = body.HipHeight
			else
				hipHeight = hipHeight or body.HipHeight

				if v11 then
					body.HipHeight = hipHeight - Crouch.depth(v11, state.crouchAlpha)
					flag2 = true
				end
			end

			if not Movement.weaponFov and (Movement.fovOffset ~= 0 or Movement.fovApplied ~= 0) then
				Movement.fovApplied = Movement.fovOffset
				currentCamera.FieldOfView = 80 + Movement.fovOffset
			end
		else
			endSlide() -- inferred equivalent call
			flag = false
		end
	end)
end

return Movement