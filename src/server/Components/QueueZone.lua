local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComponentService = require(ReplicatedStorage.Shared.Services.ComponentService)
local QueueZone = {}
QueueZone.__index = QueueZone

function QueueZone.new(instance: Instance)
	local self = setmetatable({
		_instance = instance,
	}, QueueZone)

	return self
end

function QueueZone:destroy() end

return ComponentService:registerComponentClass("QueueZone", QueueZone)
