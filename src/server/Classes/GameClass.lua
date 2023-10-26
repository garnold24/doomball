local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)

export type GameState = "Loading" | "Starting" | "InProgress" | "Ending" | "Ended"

local PLAYER_WALKSPEED = 32
local STARTING_PERIOD = 10
local GAMEPLAY_PERIOD = 60
local ENDING_PERIOD = 5

local ARENA = ReplicatedStorage.AssetStorage.Arenas.Arena1

local GameClass = {
	_endTime = math.huge,
	_loaded = false,
	_gameState = "Loading",
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

function GameClass:_loadGameAsync(): boolean
	-- load map, spawn gameplay components
	-- map has it's own tagged components so they'll initialize upon parenting to workspace
	local newArena = self._trove:Clone(ARENA)
	newArena.Parent = workspace

	-- load players
	local spawns = getSpawns(newArena, #self._players)
	if not spawns then return false end

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
		local char = player.Character
		char:PivotTo(spawn)
		char.Humanoid.WalkSpeed = PLAYER_WALKSPEED

		-- remove players from game once they die
		self._trove:Add(char.Humanoid.Died:Connect(function()
			if self._gameState ~= "InProgress" then return end
			local index = table.find(self._players, player)
			table.remove(self._players, index)
		end))
	end

	-- clean up characters after end of match
	self._trove:Add(function()
		for _, player in self._players do
			player:LoadCharacter()
		end
	end)

	-- game loaded successfully
	return true
end

function GameClass:getGameState(): GameState
	return self._gameState
end

function GameClass:getPlayers(): { Players }
	return Sift.Array.copy(self._players)
end

function GameClass:step(): boolean
	if self._gameState == "Ended" then return true end
	if self._gameState == "Ending" then return false end

	-- check if end conditions have been met, and if so, start ending sequence
	Promise.new(function(resolve, _reject)
		if #self._players == 0 then
			print("game has ended due to lack of players")
			resolve(true)
		elseif tick() >= self._endTime then
			print("game has ended due to time")
			resolve(true)
		else
			resolve(false)
		end
	end):andThen(function(didEnd)
		if not didEnd then return end
		self._gameState = "Ending"
		Promise.delay(ENDING_PERIOD):andThen(function()
			self._gameState = "Ended"
		end)
	end)

	return false
end

function GameClass.new(initialPlayers: { Players })
	local self = setmetatable({}, GameClass)

	self._trove = Trove.new()
	self._players = Sift.Array.copy(initialPlayers)
	self._gameState = "Loading"

	self._trove
		:AddPromise(Promise.new(function(resolve, _reject)
			resolve(self:_loadGameAsync())
		end))
		:andThen(function(didLoad)
			if not didLoad then
				warn("Game did not load, look into spawns.")
				self._gameState = "Ending"
				return
			end

			-- start the game loop
			print("Game Loaded")
			self._gameState = "Starting"
			return Promise.delay(STARTING_PERIOD):andThen(function()
				print("Game started")
				self._endTime = tick() + GAMEPLAY_PERIOD
				self._gameState = "InProgress"
			end)
		end)

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
