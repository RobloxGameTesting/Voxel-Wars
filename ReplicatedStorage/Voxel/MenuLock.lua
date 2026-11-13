local MenuLock = {}
MenuLock.held = false
MenuLock.open = false
local v = {}

function MenuLock.set(held: boolean)
	if held == MenuLock.held then
		return
	end

	MenuLock.held = held

	for _, callback in v do
		task.spawn(callback, held)
	end
end

function MenuLock.onChange(callback)
	table.insert(v, callback)
end

return MenuLock