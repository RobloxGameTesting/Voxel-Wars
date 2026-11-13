--!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VoxelCore = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("VoxelCore"))

local v = VoxelCore.CHUNK * 2
local parent = script.Parent
local done = parent:WaitForChild("Done")
local buf = buffer.create(v * v * v)
local v2 = {}

local buf2 = buffer.create(131072)
local buf3 = buffer.create(256)
local flag = false
local function pairsFor(buf4: buffer)
	if flag then
		local flag2 = true

		for i = 0, 252, 4 do
			if buffer.readu32(buf4, i) ~= buffer.readu32(buf3, i) then
				flag2 = false
				break
			end
		end

		if flag2 then
			return
		end
	end

	buffer.copy(buf3, 0, buf4)

	for i = 0, 255 do
		local v3 = i == 0 and 0 or buffer.readu8(buf4, i)

		for j = 0, 255 do
			local v4 = j == 0 and 0 or buffer.readu8(buf4, j)
			buffer.writeu16(buf2, (j + i * 256) * 2, v4 + v3 * 256)
		end
	end

	flag = true
end

parent:WaitForChild("Job").Event:ConnectParallel(function(p: number, p2: number, buf4: buffer, buf5: buffer?)
	if buffer.len(buf4) ~= v * v * v then
		error("[MeshWorker] a block is " .. v .. " cells a side")
	end

	if buf5 then
		pairsFor(buf5)
		local readu32 = buffer.readu32
		local readu16 = buffer.readu16
		local writeu16 = buffer.writeu16
		local band = bit32.band
		local rshift = bit32.rshift

		for i = 0, v * v * v - 4, 4 do
			local v3 = readu32(buf4, i)

			if v3 == 0 then
				continue
			end

			writeu16(buf4, i, (readu16(buf2, band(v3, 65535) * 2)))
			writeu16(buf4, i + 2, (readu16(buf2, rshift(v3, 16) * 2)))
		end
	end

	local greedy = VoxelCore.greedy(buf4, v, v, v, buf, v2)
	local buf6 = buffer.create(greedy * 7)

	for i = 0, greedy * 7 - 1 do
		buffer.writeu8(buf6, i, v2[i + 1])
	end

	task.synchronize()
	done:Fire(p, p2, buf6, greedy)
end)
parent:SetAttribute("Ready", true)