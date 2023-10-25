local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComponentService = require(ReplicatedStorage.Shared.Services.ComponentService)
local Trove = require(ReplicatedStorage.Packages.Trove)
local BallSpawn = {}
BallSpawn.__index = BallSpawn

function BallSpawn.new(instance: BasePart)
	local self = setmetatable({
		_instance = instance,
	}, BallSpawn)

	self._trove = Trove.new()
	local doomBall = self._trove:Add(Instance.new("Part"))
	doomBall.Name = "DoomBall"
	doomBall.Shape = Enum.PartType.Ball
	doomBall.Size = Vector3.new(20, 20, 20)
	doomBall.CFrame = instance.CFrame
	doomBall.Parent = workspace

	self._trove:Add(RunService.Heartbeat:Connect(function()
		doomBall.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
	end))

	return self
end

function BallSpawn:destroy()
	self._trove:Clean()
end

return ComponentService:registerComponentClass("BallSpawn", BallSpawn)
