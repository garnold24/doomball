local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComponentService = require(ReplicatedStorage.Shared.Services.ComponentService)
local Trove = require(ReplicatedStorage.Packages.Trove)
local BallSpawn = {}
BallSpawn.__index = BallSpawn

function BallSpawn:_spawnBall(location: CFrame)
	self._trove = Trove.new()
	local doomBall = self._trove:Add(Instance.new("Part"))
	doomBall.Name = "DoomBall"
	doomBall.Shape = Enum.PartType.Ball
	doomBall.Size = Vector3.new(35, 35, 35)
	doomBall.CFrame = location
	doomBall.Parent = workspace

	local decal = Instance.new("Decal", doomBall)
	decal.Texture = "rbxassetid://131807492"

	local componentInstance = ComponentService:tagObjectAs(doomBall, "Doomball")

	return componentInstance, doomBall
end

function BallSpawn.new(instance: BasePart)
	local self = setmetatable({
		_instance = instance,
	}, BallSpawn)

	local _ballCompInstance, ballModel = self:_spawnBall(instance.CFrame)

	-- upon removal of the spawner, remove the spawned ball
	self._trove:Add(function()
		ballModel:Destroy()
	end)

	return self
end

function BallSpawn:destroy()
	self._trove:Clean()
end

return ComponentService:registerComponentClass("BallSpawn", BallSpawn)
