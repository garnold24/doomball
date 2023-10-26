local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local React = require(ReplicatedStorage.Packages.React)

return function()
	local GameController = require(ReplicatedStorage.Shared.Controllers.GameController)

	local active, setActive = React.useState(false)
	local gameState, setGameState = React.useState("Waiting")
	local timer, setTimer = React.useState(os.time())
	local players, setPlayers = React.useState({})

	React.useEffect(function()
		-- observe the game's state from an observer probably from a controller
		GameController:getGameStateReplicator("Active"):Observe(function(newActive)
			setActive(newActive)
		end)
		GameController:getGameStateReplicator("GameState"):Observe(function(newGameState)
			setGameState(newGameState)
		end)
		GameController:getGameStateReplicator("Timer"):Observe(function(newTimer)
			setTimer(newTimer)
		end)
		GameController:getGameStateReplicator("Players"):Observe(function(newPlayers)
			setPlayers(newPlayers)
		end)
	end, {})

	return active, gameState, timer, players
end
