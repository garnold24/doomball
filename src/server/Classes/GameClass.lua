local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)

local ARENA = ReplicatedStorage.AssetStorage.Arenas.Arena1

local GameClass = {
	_loaded = false,
}
GameClass.__index = GameClass

local function getSpawns(arena: Model, amt: number): { CFrame }?
	-- get all points in a radius around the center of the model
	local main = arena.PrimaryPart :: BasePart
	assert(main, "Arena must have a primary part")

	local spawns = {}
	local center = main.Position
	local radius = 50
	local angle = 360 / amt
	for i = 1, amt do
		local x = center.X + radius * math.cos(math.rad(angle * i))
		local z = center.Z + radius * math.sin(math.rad(angle * i))
		local y = center.Y + 50
		table.insert(spawns, CFrame.new(x, y, z))
	end
	return spawns
end

function GameClass:_loadGame()
	-- load map, spawn gameplay components
	-- map has it's own tagged components so they'll initialize upon parenting to workspace
	local newArena = self._trove:Clone(ARENA)
	newArena.Parent = workspace

	-- load players
	local spawns = getSpawns(newArena, #self._players)
	if not spawns then return end

	-- respawn all characters and wait for them to load
	Promise.all(Sift.Array.map(self._players, function(player: Player)
		return Promise.new(function(resolve, _reject)
			player:LoadCharacter()
			resolve()
		end)
	end)):await()

	-- pivot all characters to their spawn points
	for i, player in self._players do
		local spawn = spawns[i]
		if not spawn then spawn = spawns[1] end
		player.Character:PivotTo(spawn)
	end

	-- clean up characters after end of match
	self._trove:Add(function()
		for _, player in self._players do
			player:LoadCharacter()
		end
	end)
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
