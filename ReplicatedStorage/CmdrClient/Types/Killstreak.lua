return function(registry)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local v = {}

	for k, v2 in require(ReplicatedStorage.Game.ShopData).ITEMS do
		if v2.slot == "streak" then
			table.insert(v, k)
		end
	end

	table.sort(v)
	registry:RegisterType("killstreak", registry.Cmdr.Util.MakeEnumType("Killstreak", v))
end