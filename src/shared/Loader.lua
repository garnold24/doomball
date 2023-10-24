local Loader = {
	modules = {},
}

-- constants
local SINGLETON_TOKEN
do
	SINGLETON_TOKEN = newproxy(true)
	getmetatable(SINGLETON_TOKEN).__tostring = function()
		return "[Singleton Token]"
	end
end

export type Singleton = {
	className: string,

	init: () -> nil,
	start: () -> nil,
	priority: number,
}

local function getModules(root: Instance)
	local desc = root:GetDescendants()
	local modules = {}
	for _, instance in desc do
		if not instance:IsA("ModuleScript") then continue end
		table.insert(modules, require(instance))
	end

	return modules
end

function Loader:registerSingleton<T>(val: T)
	assert(typeof(val) == "table", `{val}: Singleton must be a table`)
	assert(typeof(val.className) == "string", `{val} - Singleton className must be a string`)
	assert(typeof(val.init) == "function", `{val.className}:init() must be a function`)
	assert(typeof(val.start) == "function", `{val.className}:start() must be a function`)

	val[SINGLETON_TOKEN] = true
	return val :: T & Singleton
end

function Loader:addSource(root: Instance)
	local modules = getModules(root)
	for _, module in modules do
		table.insert(self.modules, module)
	end
end

function Loader:load(): ()
	local modules = self.modules

	table.sort(modules, function(a, b)
		return (a.priority or 0) < (b.priority or 0)
	end)

	for _, module in modules do
		if not module[SINGLETON_TOKEN] then continue end
		module:init()
	end
	for _, module in modules do
		if not module[SINGLETON_TOKEN] then continue end
		task.spawn(function()
			module:start()
		end)
	end
end

return Loader
