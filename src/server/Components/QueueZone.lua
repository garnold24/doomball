local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local ComponentService = require(ReplicatedStorage.Shared.Services.ComponentService)
local GameService = require(ServerScriptService.Server.Services.GameService)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Zone = require(ReplicatedStorage.Packages.Zone)

local WAIT_TIME = 5
local NEEDED_PLAYERS = 1

local QueueZone = {}
QueueZone.__index = QueueZone

function QueueZone.new(instance: Instance)
	local self = setmetatable({
		_instance = instance,
		_players = {},
		_trove = Trove.new(),
		_zone = Zone.new(instance),
		_playersInZone = 0,
		_startTime = -1,
	}, QueueZone)

	self._trove:Add(
		self._zone.playerEntered:Connect(function(player)
			self._players[player] = true
			self._playersInZone += 1
			if self._playersInZone == NEEDED_PLAYERS then self._startTime = tick() + WAIT_TIME end
		end),
		"Disconnect"
	)

	self._trove:Add(
		self._zone.playerExited:Connect(function(player)
			self._players[player] = false
			self._playersInZone -= 1
			if self._playersInZone < NEEDED_PLAYERS then self._startTime = -1 end
		end),
		"Disconnect"
	)

	self._trove:Add(self._zone, "destroy")
	self._trove:Add(RunService.Heartbeat:Connect(function(_dt)
		if self._playersInZone == 0 then return end
		if self._startTime == -1 then return end
		if tick() < self._startTime then return end
		print("zone game request")

		self._startTime = -1
		GameService:requestGameStart(Sift.Set.toArray(self._players))
	end))

	return self
end

function QueueZone:destroy()
	self._trove:Clean()
end

return ComponentService:registerComponentClass("QueueZone", QueueZone)
