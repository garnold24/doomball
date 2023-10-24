local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)
local GameClass = {
	_loaded = false,
}
GameClass.__index = GameClass

function GameClass:_loadGame()
	-- load map, spawn gameplay components
end

function GameClass:step(): boolean
	return false
end

function GameClass.new(initialPlayers: { Players })
	local self = setmetatable({}, GameClass)

	self._trove = Trove.new()
	self._players = Sift.Array.copy(initialPlayers)

	self._trove:AddPromise(Promise.new(function(resolve, _reject)
		self:_loadGame()
		resolve()
	end))

	self._trove:Add(Players.PlayerRemoving:Connect(function(player: Player)
		local playerIndex = table.find(self._players, player)
		if not playerIndex then return end
		table.remove(self._players, playerIndex)
	end))

	return self
end

function GameClass:destroy()
	-- clean trove
	self._trove:Clean()
	self._trove = nil
end

return GameClass
