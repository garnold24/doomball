local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Loader = require(ReplicatedStorage.Shared.Loader)

-- register services
Loader:addSource(ServerScriptService.Server.Services)
Loader:addSource(ReplicatedStorage.Shared.Services)

-- register components
Loader:addSource(ServerScriptService.Server.Components)
Loader:addSource(ReplicatedStorage.Shared.SharedComponents)

-- initialize/start services
Loader:load()
