local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComponentService = require(ReplicatedStorage.Shared.Services.ComponentService)
local Doomball = {}
Doomball.__index = Doomball

function Doomball.new(instance: Instance)
	local self = setmetatable({
		_instance = instance,
	}, Doomball)
	return self
end

function Doomball:destroy() end

return ComponentService:registerComponentClass("Doomball", Doomball)
