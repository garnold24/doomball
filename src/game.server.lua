local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local GameService = require(ServerScriptService.Server.Services.GameService)
local Loader = require(ReplicatedStorage.Shared.Loader)

-- register services
Loader:addSource(ServerScriptService.Server.Services)
Loader:addSource(ReplicatedStorage.Shared.Services)

-- register components
Loader:addSource(ServerScriptService.Server.Components)
Loader:addSource(ReplicatedStorage.Shared.SharedComponents)

-- initialize/start services
Loader:load()

-- test game
wait(5)
print("starting game")
GameService:requestGameStart(game.Players:GetChildren())
