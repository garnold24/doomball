local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local ComponentService = require(ReplicatedStorage.Shared.Services.ComponentService)
local GameService = require(ServerScriptService.Server.Services.GameService)
local QueueZoneUI = require(ReplicatedStorage.Shared.React.Components.QueueZone.QueueZoneUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Zone = require(ReplicatedStorage.Packages.Zone)

local WAIT_TIME = 5
local NEEDED_PLAYERS = 1

local QueueZone = {}
QueueZone.__index = QueueZone

function QueueZone.new(instance: Model)
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
		end),
		"Disconnect"
	)

	self._trove:Add(
		self._zone.playerExited:Connect(function(player)
			self._players[player] = false
			self._playersInZone -= 1
		end),
		"Disconnect"
	)

	self._trove:Add(self._zone, "destroy")
	self._trove:Add(RunService.Heartbeat:Connect(function(_dt)
		if self._playersInZone < NEEDED_PLAYERS then
			-- reset start time
			self._startTime = -1
			return
		end
		if self._startTime == -1 then
			if GameService:getActiveGame() then return end
			-- if there's not already an active game, start the timer
			self._startTime = os.time() + WAIT_TIME
			return
		end

		if os.time() < self._startTime then return end

		self._startTime = -1
		GameService:requestGameStart(Sift.Set.toArray(self._players))
	end))

	-- render queue zone hud
	local root = ReactRoblox.createRoot(Instance.new("Folder"))
	root:render(ReactRoblox.createPortal(
		React.createElement(QueueZoneUI, {
			target = instance.PrimaryPart,
			neededPlayers = NEEDED_PLAYERS,
			getLaunchTime = function()
				return self._startTime
			end,
			getCurrentPlayers = function()
				return self._playersInZone
			end,
		}),
		instance,
		"HudApp"
	))
	return self
end

function QueueZone:destroy()
	self._trove:Clean()
end

return ComponentService:registerComponentClass("QueueZone", QueueZone)
