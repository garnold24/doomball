local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Shared.Loader)

local ComponentService = {}
ComponentService.className = "ComponentService"
ComponentService.priority = 0

-- static properties
local yieldedRegistrations = {}

function ComponentService:_initObjAsClass(obj: Instance, class)
	local existing = self._instancedComponents[obj]
	if not existing then
		existing = {}
		self._instancedComponents[obj] = existing
		self._instanceRemovedConnections[obj] = {}
	end

	if existing[class] then return existing[class] end
	if not obj:IsDescendantOf(workspace) then return end

	local new = class.new(obj)
	existing[class] = new
	self._instanceRemovedConnections[obj][class] = obj.AncestryChanged:Connect(function(_, _parent)
		if obj:IsDescendantOf(workspace) then return end
		self._instanceRemovedConnections[obj][class]:Disconnect()
		self._instanceRemovedConnections[obj][class] = nil

		existing[class] = nil
		if self._instancedComponents[obj] then self._instancedComponents[obj] = nil end
		new:destroy()
	end)
	return new
end

function ComponentService:getComponent(obj: Instance, tag: string)
	local componentClass = self._classes[tag]
	assert(componentClass, `ComponentService.getComponent() | Invalid tag: {tag}`)

	local objectComponents = self._instancedComponents[obj]
	return objectComponents and objectComponents[componentClass]
end

-- tag obj and return the instance
function ComponentService:tagObjectAs(obj: Instance, tag: string)
	local componentClass = self._classes[tag]
	assert(componentClass, `ComponentService.tagObjectAs() | Invalid tag: {tag}`)

	local objectComponents = self._instancedComponents[obj]
	local existingInstance = objectComponents and objectComponents[componentClass]
	if existingInstance then
		warn(`ComponentService.tagObjectAs() | Object was already tagged as '{tag}', returning existing instance`)
		return existingInstance
	end

	if componentClass then
		-- not everything that's tagged needs to have a class associated with it
		self:_initObjAsClass(obj, componentClass)
	end

	-- add tag to obj
	CollectionService:AddTag(obj, tag)

	return self._instancedComponents[obj]
end

function ComponentService:registerComponentClass(name: string, class)
	task.spawn(function()
		if not self._initialized then -- yield until end of initialization
			local thread = coroutine.running()
			table.insert(yieldedRegistrations, thread)
			coroutine.yield()
		end

		pcall(function()
			self._classes[name] = class
		end)
	end)

	return class
end

function ComponentService:init()
	self._classes = {}
	self._tagAddedConnections = {}
	self._tagRemovedConnections = {}
	self._instanceRemovedConnections = {}
	self._instancedComponents = {}

	self._initialized = true

	for _, thread in yieldedRegistrations do
		coroutine.resume(thread)
	end
end

function ComponentService:start()
	-- bind existing items to their tag class
	for tag, class in self._classes do
		local currentTagged = CollectionService:GetTagged(tag)
		for i = 1, #currentTagged do
			task.spawn(function()
				self:_initObjAsClass(currentTagged[i], class)
			end)
		end

		-- bind new items to their tag class
		self._tagAddedConnections[tag] = CollectionService:GetInstanceAddedSignal(tag):Connect(function(obj: Instance)
			self:_initObjAsClass(obj, class)
		end)

		-- bind new items to their tag class
		self._tagRemovedConnections[tag] = CollectionService:GetInstanceRemovedSignal(tag):Connect(function(obj: Instance)
			if self._instancedComponents[obj][class] then
				if self._instanceRemovedConnections[obj][class] then
					self._instanceRemovedConnections[obj][class]:Disconnect()
					self._instanceRemovedConnections[obj][class] = nil
				end
				self._instancedComponents[obj][class]:destroy()
				self._instancedComponents[obj][class] = nil
			end
		end)
	end
end

return Loader:registerSingleton(ComponentService)
