local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Loader = require(ReplicatedStorage.Shared.Loader)
Loader:addSource(ServerScriptService.Server.Services)
Loader:addSource(ReplicatedStorage.Shared.Services)
Loader:load()
