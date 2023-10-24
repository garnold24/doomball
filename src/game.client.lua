local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Shared.Loader)

-- register services
Loader:addSource(ReplicatedStorage.Shared.Controllers)
Loader:addSource(ReplicatedStorage.Shared.Services)

-- register components
Loader:addSource(ReplicatedStorage.Shared.ClientComponents)
Loader:addSource(ReplicatedStorage.Shared.SharedComponents)

-- initialize/start services
Loader:load()
