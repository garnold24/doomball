local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local GameClass = require(ServerScriptService.Server.Classes.GameClass)
local Loader = require(ReplicatedStorage.Shared.Loader)
local Trove = require(ReplicatedStorage.Packages.Trove)

local GameService = {}
GameService.className = "GameService"
GameService.priority = 0

function GameService:_endGame()
	if not self._gameTrove then return end
	self._gameTrove:Clean()
	self._gameTrove = nil
end

function GameService:_initGame(players: { Players })
	if self._gameTrove then return end
	self._gameTrove = Trove.new()

	self._activeGame = GameClass.new(players)
	self:setGameState("Active", true)

	self._gameTrove:Add(function()
		if not self._activeGame then return end
		self._activeGame:destroy()
		self._activeGame = nil
		self:setGameState("Active", false)
	end)
end

function GameService:getActiveGame()
	return self._activeGame
end

function GameService:requestGameStart(players: { Players })
	if self._gameTrove then
		warn("GameService.requestGameStart() | Cannot start a game as there's already one running.")
		return
	end
	self:_initGame(players)
end

function GameService:setGameState(prop, val)
	local replicator = self._replicators[prop]
	if not replicator then return end
	replicator:Set(val)
end

function GameService:init()
	self._gameTrove = nil
	self._activeGame = nil
end

function GameService:start()
	self._comm = Comm.ServerComm.new(ReplicatedStorage, "GameService")

	self._replicators = {
		Active = self._comm:CreateProperty("Active", false),
		GameState = self._comm:CreateProperty("GameState", "Waiting"),
		Timer = self._comm:CreateProperty("Timer", os.time()),
		Players = self._comm:CreateProperty("Players", {}),
	}

	game:GetService("RunService").Heartbeat:Connect(function(_delta)
		-- if there's a game running, then step it
		if not self._activeGame then return end
		local complete = self._activeGame:step()

		-- if game has completed, then end it
		if not complete then return end
		self:_endGame()
	end)
end

return Loader:registerSingleton(GameService)
