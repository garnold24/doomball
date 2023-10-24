local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComponentService = require(ReplicatedStorage.Shared.Services.ComponentService)
local BallSpawn = {}
BallSpawn.__index = BallSpawn

function BallSpawn.new(instance: Instance)
	local self = setmetatable({
		_instance = instance,
	}, BallSpawn)

	return self
end

function BallSpawn:destroy() end

return ComponentService:registerComponentClass("BallSpawn", BallSpawn)
